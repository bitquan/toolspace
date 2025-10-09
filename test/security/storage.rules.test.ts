/**
 * Firebase Storage Security Rules Tests
 *
 * Tests that enforce:
 * - Deny all read/write without authentication
 * - Allow owner-only access to user files
 * - Enforce file size limits
 */

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  RulesTestEnvironment,
} from "@firebase/rules-unit-testing";
import { describe, test, beforeAll, afterAll, beforeEach } from "@jest/globals";
import { ref, uploadBytes, getBytes, deleteObject } from "firebase/storage";
import * as fs from "fs";
import * as path from "path";

let testEnv: RulesTestEnvironment;

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: "toolspace-test",
    storage: {
      rules: fs.readFileSync(
        path.resolve(__dirname, "../../storage.rules"),
        "utf8"
      ),
      host: "127.0.0.1",
      port: 9199,
    },
  });
});

afterAll(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  // Clear storage between tests if needed
});

describe("Storage Security Rules - User Files", () => {
  const aliceUID = "alice-uid-123";
  const bobUID = "bob-uid-456";

  test("❌ DENY: Unauthenticated users cannot upload files", async () => {
    const unauthedStorage = testEnv.unauthenticatedContext().storage();
    const fileRef = ref(unauthedStorage, `users/${aliceUID}/files/test.txt`);
    const testFile = new Uint8Array([1, 2, 3]);

    await assertFails(uploadBytes(fileRef, testFile));
  });

  test("❌ DENY: Unauthenticated users cannot read files", async () => {
    const unauthedStorage = testEnv.unauthenticatedContext().storage();
    const fileRef = ref(unauthedStorage, `users/${aliceUID}/files/test.txt`);

    await assertFails(getBytes(fileRef));
  });

  test("✅ ALLOW: Users can upload to their own directory", async () => {
    const aliceStorage = testEnv.authenticatedContext(aliceUID).storage();
    const fileRef = ref(aliceStorage, `users/${aliceUID}/files/test.txt`);
    const testFile = new Uint8Array([1, 2, 3]);

    await assertSucceeds(uploadBytes(fileRef, testFile));
  });

  test("✅ ALLOW: Users can read from their own directory", async () => {
    const aliceStorage = testEnv.authenticatedContext(aliceUID).storage();
    const fileRef = ref(aliceStorage, `users/${aliceUID}/files/test.txt`);

    // First upload
    const testFile = new Uint8Array([1, 2, 3]);
    await uploadBytes(fileRef, testFile);

    // Then read
    await assertSucceeds(getBytes(fileRef));
  });

  test("❌ DENY: Users cannot upload to other users' directories", async () => {
    const aliceStorage = testEnv.authenticatedContext(aliceUID).storage();
    const fileRef = ref(aliceStorage, `users/${bobUID}/files/test.txt`);
    const testFile = new Uint8Array([1, 2, 3]);

    await assertFails(uploadBytes(fileRef, testFile));
  });

  test("❌ DENY: Users cannot read from other users' directories", async () => {
    const bobStorage = testEnv.authenticatedContext(bobUID).storage();
    const fileRef = ref(bobStorage, `users/${aliceUID}/files/test.txt`);

    await assertFails(getBytes(fileRef));
  });

  test("❌ DENY: Users cannot delete other users' files", async () => {
    const aliceStorage = testEnv.authenticatedContext(aliceUID).storage();
    const bobStorage = testEnv.authenticatedContext(bobUID).storage();

    // Alice uploads a file
    const aliceFileRef = ref(aliceStorage, `users/${aliceUID}/files/test.txt`);
    const testFile = new Uint8Array([1, 2, 3]);
    await uploadBytes(aliceFileRef, testFile);

    // Bob tries to delete Alice's file
    const bobFileRef = ref(bobStorage, `users/${aliceUID}/files/test.txt`);
    await assertFails(deleteObject(bobFileRef));
  });

  test("✅ ALLOW: Users can delete their own files", async () => {
    const aliceStorage = testEnv.authenticatedContext(aliceUID).storage();
    const fileRef = ref(aliceStorage, `users/${aliceUID}/files/test.txt`);

    // Upload
    const testFile = new Uint8Array([1, 2, 3]);
    await uploadBytes(fileRef, testFile);

    // Delete own file
    await assertSucceeds(deleteObject(fileRef));
  });
});

describe("Storage Security Rules - File Size Limits", () => {
  const aliceUID = "alice-uid-123";

  test("❌ DENY: Files larger than 200MB should be rejected", async () => {
    const aliceStorage = testEnv.authenticatedContext(aliceUID).storage();
    const fileRef = ref(aliceStorage, `users/${aliceUID}/files/large.bin`);

    // Create a 201MB file (exceeds limit)
    const largeFile = new Uint8Array(201 * 1024 * 1024);

    await assertFails(uploadBytes(fileRef, largeFile));
  });

  test("✅ ALLOW: Files under 200MB should be accepted", async () => {
    const aliceStorage = testEnv.authenticatedContext(aliceUID).storage();
    const fileRef = ref(aliceStorage, `users/${aliceUID}/files/ok.bin`);

    // Create a 10MB file
    const okFile = new Uint8Array(10 * 1024 * 1024);

    await assertSucceeds(uploadBytes(fileRef, okFile));
  });
});

describe("Storage Security Rules - Temp Upload Directory", () => {
  const aliceUID = "alice-uid-123";

  test("✅ ALLOW: Users can upload to temp directory", async () => {
    const aliceStorage = testEnv.authenticatedContext(aliceUID).storage();
    const fileRef = ref(aliceStorage, `temp/${aliceUID}/upload.bin`);
    const testFile = new Uint8Array([1, 2, 3]);

    await assertSucceeds(uploadBytes(fileRef, testFile));
  });

  test("❌ DENY: Users cannot access other users' temp files", async () => {
    const aliceStorage = testEnv
      .authenticatedContext("alice-uid-123")
      .storage();
    const bobUID = "bob-uid-456";
    const fileRef = ref(aliceStorage, `temp/${bobUID}/upload.bin`);

    await assertFails(getBytes(fileRef));
  });
});
