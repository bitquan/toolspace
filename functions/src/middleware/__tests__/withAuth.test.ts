import {
  describe,
  beforeEach,
  afterEach,
  test,
  expect,
  jest,
} from "@jest/globals";
import {
  withAuth,
  withOwnership,
  withEmailVerification,
} from "../middleware/withAuth";
import { admin } from "../admin";

// Mock Firebase Admin
jest.mock("../admin", () => ({
  admin: {
    auth: jest.fn(() => ({
      verifyIdToken: jest.fn(),
    })),
  },
}));

const mockVerifyIdToken = admin.auth()
  .verifyIdToken as jest.MockedFunction<any>;

describe("Auth Middleware", () => {
  let mockReq: any;
  let mockRes: any;
  let mockNext: jest.MockedFunction<any>;

  beforeEach(() => {
    mockReq = {
      headers: {},
      params: {},
      body: {},
    };

    mockRes = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn(),
    };

    mockNext = jest.fn();

    // Reset mocks
    jest.clearAllMocks();
  });

  describe("withAuth middleware", () => {
    test("should authenticate user with valid token", async () => {
      const mockDecodedToken = {
        uid: "user123",
        email: "test@example.com",
        email_verified: true,
      };

      mockReq.headers.authorization = "Bearer valid-token";
      mockVerifyIdToken.mockResolvedValue(mockDecodedToken);

      await withAuth(mockReq, mockRes, mockNext);

      expect(mockVerifyIdToken).toHaveBeenCalledWith("valid-token");
      expect(mockReq.user).toEqual(mockDecodedToken);
      expect(mockReq.uid).toBe("user123");
      expect(mockReq.userId).toBe("user123");
      expect(mockNext).toHaveBeenCalled();
      expect(mockRes.status).not.toHaveBeenCalled();
    });

    test("should reject request without authorization header", async () => {
      await withAuth(mockReq, mockRes, mockNext);

      expect(mockRes.status).toHaveBeenCalledWith(401);
      expect(mockRes.json).toHaveBeenCalledWith({ error: "Unauthorized" });
      expect(mockNext).not.toHaveBeenCalled();
    });

    test("should reject request with invalid authorization format", async () => {
      mockReq.headers.authorization = "Invalid format";

      await withAuth(mockReq, mockRes, mockNext);

      expect(mockRes.status).toHaveBeenCalledWith(401);
      expect(mockRes.json).toHaveBeenCalledWith({ error: "Unauthorized" });
      expect(mockNext).not.toHaveBeenCalled();
    });

    test("should reject request with invalid token", async () => {
      mockReq.headers.authorization = "Bearer invalid-token";
      mockVerifyIdToken.mockRejectedValue(new Error("Invalid token"));

      await withAuth(mockReq, mockRes, mockNext);

      expect(mockRes.status).toHaveBeenCalledWith(401);
      expect(mockRes.json).toHaveBeenCalledWith({ error: "Unauthorized" });
      expect(mockNext).not.toHaveBeenCalled();
    });

    test("should handle empty token", async () => {
      mockReq.headers.authorization = "Bearer ";

      await withAuth(mockReq, mockRes, mockNext);

      expect(mockRes.status).toHaveBeenCalledWith(401);
      expect(mockRes.json).toHaveBeenCalledWith({ error: "Unauthorized" });
      expect(mockNext).not.toHaveBeenCalled();
    });
  });

  describe("withOwnership middleware", () => {
    beforeEach(() => {
      mockReq.uid = "user123";
    });

    test("should allow access when user owns resource (params)", async () => {
      mockReq.params.uid = "user123";

      await withOwnership(mockReq, mockRes, mockNext);

      expect(mockNext).toHaveBeenCalled();
      expect(mockRes.status).not.toHaveBeenCalled();
    });

    test("should allow access when user owns resource (body)", async () => {
      mockReq.body.uid = "user123";

      await withOwnership(mockReq, mockRes, mockNext);

      expect(mockNext).toHaveBeenCalled();
      expect(mockRes.status).not.toHaveBeenCalled();
    });

    test("should deny access when user does not own resource", async () => {
      mockReq.params.uid = "other-user";

      await withOwnership(mockReq, mockRes, mockNext);

      expect(mockRes.status).toHaveBeenCalledWith(403);
      expect(mockRes.json).toHaveBeenCalledWith({
        error: "Access denied: not resource owner",
      });
      expect(mockNext).not.toHaveBeenCalled();
    });

    test("should deny access when no resource UID specified", async () => {
      await withOwnership(mockReq, mockRes, mockNext);

      expect(mockRes.status).toHaveBeenCalledWith(403);
      expect(mockRes.json).toHaveBeenCalledWith({
        error: "Resource owner not specified",
      });
      expect(mockNext).not.toHaveBeenCalled();
    });

    test("should deny access when user not authenticated", async () => {
      delete mockReq.uid;

      await withOwnership(mockReq, mockRes, mockNext);

      expect(mockRes.status).toHaveBeenCalledWith(403);
      expect(mockRes.json).toHaveBeenCalledWith({
        error: "User not authenticated",
      });
      expect(mockNext).not.toHaveBeenCalled();
    });
  });

  describe("withEmailVerification middleware", () => {
    test("should allow access for verified email", async () => {
      mockReq.user = {
        uid: "user123",
        email: "test@example.com",
        email_verified: true,
      };

      await withEmailVerification(mockReq, mockRes, mockNext);

      expect(mockNext).toHaveBeenCalled();
      expect(mockRes.status).not.toHaveBeenCalled();
    });

    test("should deny access for unverified email", async () => {
      mockReq.user = {
        uid: "user123",
        email: "test@example.com",
        email_verified: false,
      };

      await withEmailVerification(mockReq, mockRes, mockNext);

      expect(mockRes.status).toHaveBeenCalledWith(403);
      expect(mockRes.json).toHaveBeenCalledWith({
        error: "Email verification required",
        code: "email-not-verified",
      });
      expect(mockNext).not.toHaveBeenCalled();
    });

    test("should deny access when user not authenticated", async () => {
      await withEmailVerification(mockReq, mockRes, mockNext);

      expect(mockRes.status).toHaveBeenCalledWith(500);
      expect(mockNext).not.toHaveBeenCalled();
    });
  });

  describe("Integration Tests", () => {
    test("should handle complete auth flow", async () => {
      const mockDecodedToken = {
        uid: "user123",
        email: "test@example.com",
        email_verified: true,
      };

      mockReq.headers.authorization = "Bearer valid-token";
      mockReq.params.uid = "user123";
      mockVerifyIdToken.mockResolvedValue(mockDecodedToken);

      // Test auth + ownership + email verification flow
      await withAuth(mockReq, mockRes, async () => {
        await withOwnership(mockReq, mockRes, async () => {
          await withEmailVerification(mockReq, mockRes, mockNext);
        });
      });

      expect(mockReq.user).toEqual(mockDecodedToken);
      expect(mockNext).toHaveBeenCalled();
      expect(mockRes.status).not.toHaveBeenCalled();
    });

    test("should fail at ownership check for wrong user", async () => {
      const mockDecodedToken = {
        uid: "user123",
        email: "test@example.com",
        email_verified: true,
      };

      mockReq.headers.authorization = "Bearer valid-token";
      mockReq.params.uid = "other-user"; // Different user
      mockVerifyIdToken.mockResolvedValue(mockDecodedToken);

      await withAuth(mockReq, mockRes, async () => {
        await withOwnership(mockReq, mockRes, async () => {
          await withEmailVerification(mockReq, mockRes, mockNext);
        });
      });

      expect(mockRes.status).toHaveBeenCalledWith(403);
      expect(mockNext).not.toHaveBeenCalled();
    });
  });
});
