import {
  initializeTestEnvironment,
  RulesTestEnvironment,
  assertFails,
  assertSucceeds,
} from "@firebase/rules-unit-testing";
import {
  doc,
  getDoc,
  setDoc,
  updateDoc,
  deleteDoc,
  collection,
  getDocs,
} from "firebase/firestore";

let testEnv: RulesTestEnvironment;

// Test user IDs
const ALICE_UID = "alice123";
const BOB_UID = "bob456";
const UNAUTHORIZED_UID = "unauthorized789";

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: "toolspace-test",
    firestore: {
      rules: require("fs").readFileSync("../../firestore.rules", "utf8"),
      host: "localhost",
      port: 8080,
    },
  });
});

afterAll(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
});

describe("Firestore Security Rules", () => {
  describe("Users Collection", () => {
    test("should allow authenticated user to read their own user document", async () => {
      const aliceDb = testEnv.authenticatedContext(ALICE_UID).firestore();
      const userDoc = doc(aliceDb, "users", ALICE_UID);

      await assertSucceeds(
        setDoc(userDoc, { name: "Alice", email: "alice@example.com" })
      );
      await assertSucceeds(getDoc(userDoc));
    });

    test("should allow authenticated user to write their own user document", async () => {
      const aliceDb = testEnv.authenticatedContext(ALICE_UID).firestore();
      const userDoc = doc(aliceDb, "users", ALICE_UID);

      await assertSucceeds(
        setDoc(userDoc, { name: "Alice", email: "alice@example.com" })
      );
      await assertSucceeds(updateDoc(userDoc, { name: "Alice Smith" }));
    });

    test("should deny authenticated user access to other users documents", async () => {
      const aliceDb = testEnv.authenticatedContext(ALICE_UID).firestore();
      const bobUserDoc = doc(aliceDb, "users", BOB_UID);

      await assertFails(getDoc(bobUserDoc));
      await assertFails(setDoc(bobUserDoc, { name: "Bob Hacker" }));
    });

    test("should deny unauthenticated access to user documents", async () => {
      const unauthDb = testEnv.unauthenticatedContext().firestore();
      const userDoc = doc(unauthDb, "users", ALICE_UID);

      await assertFails(getDoc(userDoc));
      await assertFails(setDoc(userDoc, { name: "Anonymous Hacker" }));
    });
  });

  describe("User Billing Subcollections", () => {
    test("should allow user to access their own billing documents", async () => {
      const aliceDb = testEnv.authenticatedContext(ALICE_UID).firestore();
      const billingDoc = doc(
        aliceDb,
        "users",
        ALICE_UID,
        "billing",
        "subscription"
      );

      await assertSucceeds(
        setDoc(billingDoc, {
          plan: "premium",
          status: "active",
          stripeCustomerId: "cus_123",
        })
      );
      await assertSucceeds(getDoc(billingDoc));
    });

    test("should deny access to other users billing documents", async () => {
      const aliceDb = testEnv.authenticatedContext(ALICE_UID).firestore();
      const bobBillingDoc = doc(
        aliceDb,
        "users",
        BOB_UID,
        "billing",
        "subscription"
      );

      await assertFails(getDoc(bobBillingDoc));
      await assertFails(setDoc(bobBillingDoc, { plan: "hacked" }));
    });

    test("should deny unauthenticated access to billing documents", async () => {
      const unauthDb = testEnv.unauthenticatedContext().firestore();
      const billingDoc = doc(
        unauthDb,
        "users",
        ALICE_UID,
        "billing",
        "subscription"
      );

      await assertFails(getDoc(billingDoc));
      await assertFails(setDoc(billingDoc, { plan: "free" }));
    });
  });

  describe("User Usage Subcollections", () => {
    test("should allow user to access their own usage documents", async () => {
      const aliceDb = testEnv.authenticatedContext(ALICE_UID).firestore();
      const usageDoc = doc(aliceDb, "users", ALICE_UID, "usage", "monthly");

      await assertSucceeds(
        setDoc(usageDoc, {
          filesMerged: 10,
          qrCodesGenerated: 5,
          lastUpdated: new Date(),
        })
      );
      await assertSucceeds(getDoc(usageDoc));
    });

    test("should deny access to other users usage documents", async () => {
      const aliceDb = testEnv.authenticatedContext(ALICE_UID).firestore();
      const bobUsageDoc = doc(aliceDb, "users", BOB_UID, "usage", "monthly");

      await assertFails(getDoc(bobUsageDoc));
      await assertFails(setDoc(bobUsageDoc, { filesMerged: 999999 }));
    });
  });

  describe("User Settings Subcollections", () => {
    test("should allow user to manage their own settings", async () => {
      const aliceDb = testEnv.authenticatedContext(ALICE_UID).firestore();
      const settingsDoc = doc(
        aliceDb,
        "users",
        ALICE_UID,
        "settings",
        "preferences"
      );

      await assertSucceeds(
        setDoc(settingsDoc, {
          theme: "dark",
          notifications: true,
          language: "en",
        })
      );
      await assertSucceeds(getDoc(settingsDoc));
      await assertSucceeds(updateDoc(settingsDoc, { theme: "light" }));
    });

    test("should deny access to other users settings", async () => {
      const aliceDb = testEnv.authenticatedContext(ALICE_UID).firestore();
      const bobSettingsDoc = doc(
        aliceDb,
        "users",
        BOB_UID,
        "settings",
        "preferences"
      );

      await assertFails(getDoc(bobSettingsDoc));
      await assertFails(setDoc(bobSettingsDoc, { theme: "hacked" }));
    });
  });

  describe("User Analytics Subcollections", () => {
    test("should allow user to access their own analytics", async () => {
      const aliceDb = testEnv.authenticatedContext(ALICE_UID).firestore();
      const analyticsDoc = doc(
        aliceDb,
        "users",
        ALICE_UID,
        "analytics",
        "events"
      );

      await assertSucceeds(
        setDoc(analyticsDoc, {
          toolsUsed: ["file-merger", "qr-maker"],
          sessionsCount: 25,
          lastLogin: new Date(),
        })
      );
      await assertSucceeds(getDoc(analyticsDoc));
    });

    test("should deny access to other users analytics", async () => {
      const aliceDb = testEnv.authenticatedContext(ALICE_UID).firestore();
      const bobAnalyticsDoc = doc(
        aliceDb,
        "users",
        BOB_UID,
        "analytics",
        "events"
      );

      await assertFails(getDoc(bobAnalyticsDoc));
      await assertFails(setDoc(bobAnalyticsDoc, { sessionsCount: 0 }));
    });
  });

  describe("Unknown Collections", () => {
    test("should deny access to any unknown collection", async () => {
      const aliceDb = testEnv.authenticatedContext(ALICE_UID).firestore();
      const unknownDoc = doc(aliceDb, "unknown-collection", "some-doc");

      await assertFails(getDoc(unknownDoc));
      await assertFails(setDoc(unknownDoc, { data: "hacked" }));
    });

    test("should deny reading any unknown collection", async () => {
      const aliceDb = testEnv.authenticatedContext(ALICE_UID).firestore();
      const unknownCollection = collection(aliceDb, "unknown-collection");

      await assertFails(getDocs(unknownCollection));
    });
  });

  describe("Cross-User Access Prevention", () => {
    test("should completely isolate user data between users", async () => {
      // Alice creates her data
      const aliceDb = testEnv.authenticatedContext(ALICE_UID).firestore();
      await assertSucceeds(
        setDoc(doc(aliceDb, "users", ALICE_UID), { name: "Alice" })
      );
      await assertSucceeds(
        setDoc(doc(aliceDb, "users", ALICE_UID, "billing", "sub"), {
          plan: "premium",
        })
      );

      // Bob tries to access Alice's data
      const bobDb = testEnv.authenticatedContext(BOB_UID).firestore();
      await assertFails(getDoc(doc(bobDb, "users", ALICE_UID)));
      await assertFails(
        getDoc(doc(bobDb, "users", ALICE_UID, "billing", "sub"))
      );

      // Bob can only access his own data
      await assertSucceeds(
        setDoc(doc(bobDb, "users", BOB_UID), { name: "Bob" })
      );
      await assertSucceeds(getDoc(doc(bobDb, "users", BOB_UID)));
    });
  });

  describe("Unauthenticated User Lockout", () => {
    test("should completely block all unauthenticated access", async () => {
      const unauthDb = testEnv.unauthenticatedContext().firestore();

      // Try accessing various collections
      await assertFails(getDoc(doc(unauthDb, "users", ALICE_UID)));
      await assertFails(
        getDoc(doc(unauthDb, "users", ALICE_UID, "billing", "sub"))
      );
      await assertFails(
        getDoc(doc(unauthDb, "users", ALICE_UID, "usage", "monthly"))
      );
      await assertFails(getDoc(doc(unauthDb, "unknown-collection", "doc")));

      // Try writing to various collections
      await assertFails(
        setDoc(doc(unauthDb, "users", ALICE_UID), { hacked: true })
      );
      await assertFails(
        setDoc(doc(unauthDb, "users", ALICE_UID, "billing", "sub"), {
          plan: "free",
        })
      );
    });
  });
});
