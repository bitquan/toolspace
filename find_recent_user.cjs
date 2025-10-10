const fs = require("fs");

// Read the user data
const userData = JSON.parse(fs.readFileSync("recent_users.json", "utf8"));

// Convert timestamps and sort by most recent sign-in
const users = userData.users
  .map((user) => ({
    uid: user.localId,
    lastSignedIn: new Date(parseInt(user.lastSignedInAt)),
    created: new Date(parseInt(user.createdAt)),
  }))
  .sort((a, b) => b.lastSignedIn.getTime() - a.lastSignedIn.getTime());

console.log("🕐 Most recent users by last sign-in:");
users.slice(0, 10).forEach((user, index) => {
  console.log(
    `${index + 1}. ${user.uid.substring(
      0,
      8
    )}... | Last Sign In: ${user.lastSignedIn.toLocaleString()}`
  );
});

// The most recent user is likely you
const mostRecentUser = users[0];
console.log(`\n🎯 Most recent user: ${mostRecentUser.uid}`);
console.log(
  `📅 Last signed in: ${mostRecentUser.lastSignedIn.toLocaleString()}`
);

// Create a Firebase CLI command to update this user's billing profile
const updateCommand = `firebase firestore:set billingProfiles/${mostRecentUser.uid} pro_plan_update.json --project toolspace-beta`;

console.log(`\n🚀 To update this user to Pro plan, run:`);
console.log(updateCommand);

// Also save just the user ID for manual use
fs.writeFileSync("target_user_id.txt", mostRecentUser.uid);
console.log(`\n💾 Saved user ID to target_user_id.txt: ${mostRecentUser.uid}`);
