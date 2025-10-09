/**
 * Firestore Security Rules Tests
 *
 * Tests that enforce:
 * - Deny all read/write without authentication
 * - Allow owner-only access to user documents
 * - Deny cross-user access
 */

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  RulesTestEnvironment,
} from "@firebase/rules-unit-testing";
import { describe, test, beforeAll, afterAll, beforeEach } from "@jest/globals";
import { doc, getDoc, setDoc, updateDoc, deleteDoc } from "firebase/firestore";
import * as fs from "fs";
import * as path from "path";

let testEnv: RulesTestEnvironment;

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: "toolspace-test",
    firestore: {
      rules: fs.readFileSync(
        path.resolve(__dirname, "../../firestore.rules"),
        "utf8"
      ),
      host: "127.0.0.1",
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

describe("Firestore Security Rules - Users Collection", () => {
  const aliceUID = "alice-uid-123";
  const bobUID = "bob-uid-456";

  test("❌ DENY: Unauthenticated users cannot read user documents", async () => {
    const unauthedDb = testEnv.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(unauthedDb, "users", aliceUID)));
  });

  test("❌ DENY: Unauthenticated users cannot write user documents", async () => {
    const unauthedDb = testEnv.unauthenticatedContext().firestore();
    await assertFails(
      setDoc(doc(unauthedDb, "users", aliceUID), { name: "Alice" })
    );
  });

  test("✅ ALLOW: Authenticated users can read their own document", async () => {
    const aliceDb = testEnv.authenticatedContext(aliceUID).firestore();
    await assertSucceeds(getDoc(doc(aliceDb, "users", aliceUID)));
  });

  test("✅ ALLOW: Authenticated users can write their own document", async () => {
    const aliceDb = testEnv.authenticatedContext(aliceUID).firestore();
    await assertSucceeds(
      setDoc(doc(aliceDb, "users", aliceUID), { name: "Alice" })
    );
  });

  test("❌ DENY: Users cannot read other users' documents", async () => {
    const aliceDb = testEnv.authenticatedContext(aliceUID).firestore();
    await assertFails(getDoc(doc(aliceDb, "users", bobUID)));
  });

  test("❌ DENY: Users cannot write to other users' documents", async () => {
    const aliceDb = testEnv.authenticatedContext(aliceUID).firestore();
    await assertFails(
      setDoc(doc(aliceDb, "users", bobUID), { name: "Evil Alice" })
    );
  });

  test("❌ DENY: Users cannot delete other users' documents", async () => {
    const bobDb = testEnv.authenticatedContext(bobUID).firestore();
    // First create Alice's document as system
    const adminDb = testEnv
      .authenticatedContext(aliceUID, { admin: true })
      .firestore();
    await setDoc(doc(adminDb, "users", aliceUID), { name: "Alice" });

    // Bob tries to delete
    await assertFails(deleteDoc(doc(bobDb, "users", aliceUID)));
  });
});

describe("Firestore Security Rules - Billing Collection", () => {
  const aliceUID = "alice-uid-123";
  const bobUID = "bob-uid-456";

  test("❌ DENY: Unauthenticated users cannot read billing profiles", async () => {
    const unauthedDb = testEnv.unauthenticatedContext().firestore();
    await assertFails(
      getDoc(doc(unauthedDb, "users", aliceUID, "billing", "profile"))
    );
  });

  test("✅ ALLOW: Users can read their own billing profile", async () => {
    const aliceDb = testEnv.authenticatedContext(aliceUID).firestore();
    await assertSucceeds(
      getDoc(doc(aliceDb, "users", aliceUID, "billing", "profile"))
    );
  });

  test("❌ DENY: Users cannot read other users' billing profiles", async () => {
    const aliceDb = testEnv.authenticatedContext(aliceUID).firestore();
    await assertFails(
      getDoc(doc(aliceDb, "users", bobUID, "billing", "profile"))
    );
  });

  test("❌ DENY: Users cannot directly write to billing profiles (webhook-only)", async () => {
    const aliceDb = testEnv.authenticatedContext(aliceUID).firestore();
    await assertFails(
      setDoc(doc(aliceDb, "users", aliceUID, "billing", "profile"), {
        planId: "pro",
      })
    );
  });
});

describe("Firestore Security Rules - Usage Collection", () => {
  const aliceUID = "alice-uid-123";
  const bobUID = "bob-uid-456";
  const today = new Date().toISOString().split("T")[0];

  test("✅ ALLOW: Users can read their own usage records", async () => {
    const aliceDb = testEnv.authenticatedContext(aliceUID).firestore();
    await assertSucceeds(
      getDoc(doc(aliceDb, "users", aliceUID, "usage", today))
    );
  });

  test("✅ ALLOW: Users can increment their own usage", async () => {
    const aliceDb = testEnv.authenticatedContext(aliceUID).firestore();
    await assertSucceeds(
      setDoc(doc(aliceDb, "users", aliceUID, "usage", today), {
        heavyOps: 1,
        lightOps: 5,
      })
    );
  });

  test("❌ DENY: Users cannot read other users' usage records", async () => {
    const aliceDb = testEnv.authenticatedContext(aliceUID).firestore();
    await assertFails(getDoc(doc(aliceDb, "users", bobUID, "usage", today)));
  });

  test("❌ DENY: Users cannot modify other users' usage", async () => {
    const aliceDb = testEnv.authenticatedContext(aliceUID).firestore();
    await assertFails(
      updateDoc(doc(aliceDb, "users", bobUID, "usage", today), {
        heavyOps: 999,
      })
    );
  });
});

describe("Firestore Security Rules - URLs Collection (URL Shortener)", () => {
  const aliceUID = "alice-uid-123";
  const bobUID = "bob-uid-456";

  test("✅ ALLOW: Users can create their own URLs", async () => {
    const aliceDb = testEnv.authenticatedContext(aliceUID).firestore();
    await assertSucceeds(
      setDoc(doc(aliceDb, "users", aliceUID, "urls", "url1"), {
        originalUrl: "https://example.com",
        shortCode: "abc123",
        createdAt: new Date(),
        userId: aliceUID,
      })
    );
  });

  test("✅ ALLOW: Users can read their own URLs", async () => {
    const aliceDb = testEnv.authenticatedContext(aliceUID).firestore();
    await assertSucceeds(
      getDoc(doc(aliceDb, "users", aliceUID, "urls", "url1"))
    );
  });

  test("❌ DENY: Users cannot access other users' URLs", async () => {
    const aliceDb = testEnv.authenticatedContext(aliceUID).firestore();
    await assertFails(getDoc(doc(aliceDb, "users", bobUID, "urls", "url1")));
  });

  test("❌ DENY: Unauthenticated users cannot create URLs", async () => {
    const unauthedDb = testEnv.unauthenticatedContext().firestore();
    await assertFails(
      setDoc(doc(unauthedDb, "users", "anon", "urls", "url1"), {
        originalUrl: "https://example.com",
      })
    );
  });
});
