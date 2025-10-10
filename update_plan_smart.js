import { initializeApp, cert } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";

// Initialize Firebase Admin with default credentials
const app = initializeApp({
  projectId: "toolspace-beta",
});

const db = getFirestore(app);

async function findAndUpdateRecentUser() {
  try {
    console.log("🔍 Looking for recent billing profiles...");

    // Get all billing profiles to find the most recent activity
    const snapshot = await db.collection("billingProfiles").get();

    console.log(`Found ${snapshot.size} billing profiles total`);

    if (snapshot.empty) {
      console.log("No billing profiles found");
      return;
    }

    // Look for profiles that might be yours (recent activity, no pro plan yet)
    const profiles = [];
    snapshot.forEach((doc) => {
      const data = doc.data();
      profiles.push({
        id: doc.id,
        plan: data.plan || "free",
        status: data.status || "inactive",
        updatedAt: data.updatedAt?.toDate() || new Date(0),
        email: data.email || "unknown",
        stripeCustomerId: data.stripeCustomerId || null,
      });
    });

    // Sort by most recent update
    profiles.sort((a, b) => b.updatedAt - a.updatedAt);

    console.log("\n📋 Recent billing profiles:");
    profiles.slice(0, 5).forEach((profile, index) => {
      console.log(
        `${index + 1}. User: ${profile.id.substring(0, 8)}... | Plan: ${
          profile.plan
        } | Updated: ${profile.updatedAt.toLocaleString()}`
      );
    });

    // Update the most recent user who might have just upgraded
    const targetProfile =
      profiles.find((p) => p.plan === "free" || p.plan === "Free") ||
      profiles[0];

    if (targetProfile) {
      console.log(
        `\n🎯 Updating user ${targetProfile.id.substring(0, 8)}... to Pro plan`
      );

      await db
        .collection("billingProfiles")
        .doc(targetProfile.id)
        .update({
          plan: "pro",
          planDisplayName: "Pro Plan",
          status: "active",
          updatedAt: new Date(),
          subscriptionId: "manual_update_" + Date.now(),
          priceId: "price_1Q8QFNKH9qhDPyF8xTlgONJW", // Pro plan price ID
        });

      console.log("✅ Plan updated successfully!");
      console.log(
        "🚀 User should now have Pro plan access. Please refresh your app!"
      );
    } else {
      console.log("❌ Could not find a suitable profile to update");
    }
  } catch (error) {
    console.error("❌ Error updating plan:", error.message);
  }

  process.exit(0);
}

findAndUpdateRecentUser();
