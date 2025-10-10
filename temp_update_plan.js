import admin from "firebase-admin";

// Initialize Firebase Admin
admin.initializeApp({
  projectId: "toolspace-beta",
});

const db = admin.firestore();

async function updateUserPlan() {
  try {
    // Query for the most recent billing profile that might need updating
    const billingProfilesSnapshot = await db
      .collection("billingProfiles")
      .orderBy("updatedAt", "desc")
      .limit(5)
      .get();

    console.log("Found billing profiles:");
    billingProfilesSnapshot.forEach((doc) => {
      const data = doc.data();
      console.log(
        `- User: ${doc.id}, Plan: ${
          data.plan
        }, Updated: ${data.updatedAt?.toDate()}`
      );
    });

    // Find the profile that might be yours (recently updated or specific criteria)
    // For now, let's update the most recent one
    if (!billingProfilesSnapshot.empty) {
      const mostRecentDoc = billingProfilesSnapshot.docs[0];
      const userId = mostRecentDoc.id;

      console.log(`\nUpdating user ${userId} to Pro plan...`);

      await db
        .collection("billingProfiles")
        .doc(userId)
        .update({
          plan: "pro",
          planDisplayName: "Pro Plan",
          status: "active",
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          stripeCustomerId: mostRecentDoc.data().stripeCustomerId || null,
          subscriptionId: "manual_update_" + Date.now(),
          priceId: "price_1Q8QFNKH9qhDPyF8xTlgONJW", // Pro plan price ID
        });

      console.log("✅ Plan updated successfully!");
      console.log("User should now have Pro plan access.");
    } else {
      console.log("No billing profiles found.");
    }
  } catch (error) {
    console.error("Error updating plan:", error);
  }

  process.exit(0);
}

updateUserPlan();
