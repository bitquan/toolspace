const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { getAuth } = require('firebase-admin/auth');

// Initialize Firebase Admin
const app = initializeApp({
  projectId: 'toolspace-beta'
});

const db = getFirestore(app);
const auth = getAuth(app);

async function updateRecentUserToPro() {
  try {
    console.log('🔍 Finding recent users and billing profiles...');
    
    // Get recent users from Firebase Auth
    const userRecords = await auth.listUsers(20);
    console.log(`Found ${userRecords.users.length} total users`);
    
    // Sort by creation time (most recent first)
    const recentUsers = userRecords.users
      .sort((a, b) => new Date(b.metadata.creationTime).getTime() - new Date(a.metadata.creationTime).getTime())
      .slice(0, 10);
    
    console.log('\n📋 Most recent users:');
    recentUsers.forEach((user, index) => {
      console.log(`${index + 1}. ${user.uid.substring(0, 8)}... | Created: ${new Date(user.metadata.creationTime).toLocaleString()} | Last Sign In: ${new Date(user.metadata.lastSignInTime).toLocaleString()}`);
    });
    
    // Get billing profiles
    const billingSnapshot = await db.collection('billingProfiles').get();
    const billingProfiles = new Map();
    
    billingSnapshot.forEach(doc => {
      const data = doc.data();
      billingProfiles.set(doc.id, {
        plan: data.plan || 'free',
        status: data.status || 'inactive',
        updatedAt: data.updatedAt?.toDate() || new Date(0),
        email: data.email || 'unknown'
      });
    });
    
    console.log(`\n💳 Found ${billingProfiles.size} billing profiles`);
    
    // Find the most recently active user who might need upgrading
    let targetUserId = null;
    
    // Strategy 1: Find most recent user with no billing profile or free plan
    for (const user of recentUsers) {
      const billing = billingProfiles.get(user.uid);
      if (!billing || billing.plan === 'free' || billing.plan === 'Free') {
        targetUserId = user.uid;
        console.log(`\n🎯 Selected user: ${user.uid.substring(0, 8)}... (${billing ? `plan: ${billing.plan}` : 'no billing profile'})`);
        break;
      }
    }
    
    // Strategy 2: If no free users found, use the most recent user
    if (!targetUserId && recentUsers.length > 0) {
      targetUserId = recentUsers[0].uid;
      console.log(`\n🎯 Using most recent user: ${targetUserId.substring(0, 8)}...`);
    }
    
    if (targetUserId) {
      console.log(`\n🚀 Updating user ${targetUserId.substring(0, 8)}... to Pro plan...`);
      
      const updateData = {
        plan: 'pro',
        planDisplayName: 'Pro Plan',
        status: 'active',
        updatedAt: new Date(),
        subscriptionId: `manual_update_${Date.now()}`,
        priceId: 'price_1Q8QFNKH9qhDPyF8xTlgONJW', // Pro plan price ID
        manualUpdate: true,
        manualUpdateReason: 'Webhook signature verification failed - manual Pro plan activation'
      };
      
      await db.collection('billingProfiles').doc(targetUserId).set(updateData, { merge: true });
      
      console.log('✅ Plan updated successfully!');
      console.log('🎉 User should now have Pro plan access. Please refresh your app!');
      console.log(`\n📝 Updated user: ${targetUserId}`);
      
    } else {
      console.log('❌ Could not find a suitable user to update');
    }
    
  } catch (error) {
    console.error('❌ Error updating plan:', error.message);
    if (error.message.includes('credentials')) {
      console.log('\n💡 Try running: gcloud auth application-default login');
      console.log('Or set GOOGLE_APPLICATION_CREDENTIALS environment variable');
    }
  }
  
  process.exit(0);
}

updateRecentUserToPro();