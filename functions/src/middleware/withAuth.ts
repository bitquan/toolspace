import { admin } from "../admin";
import { AuthError } from "../util/errors";
import { extractBearerToken, assertOwner } from "../util/guards";

/**
 * Middleware to verify Firebase ID tokens and attach user info to request
 */
export async function withAuth(req: any, res: any, next: any): Promise<void> {
  try {
    const token = extractBearerToken(req);
    const decodedToken = await admin.auth().verifyIdToken(token);

    // Attach user info to request
    req.user = decodedToken;
    req.uid = decodedToken.uid;
    req.userId = decodedToken.uid; // For backward compatibility

    next();
  } catch (error) {
    console.error("Auth middleware error:", error);
    res.status(401).json({ error: "Unauthorized" });
  }
}

/**
 * Middleware to verify user ownership of a resource
 * Expects resourceUid in req.params.uid or req.body.uid
 */
export async function withOwnership(
  req: any,
  res: any,
  next: any
): Promise<void> {
  try {
    const requestUid = req.uid || req.userId;
    if (!requestUid) {
      throw new AuthError("User not authenticated");
    }

    // Check for resource UID in params or body
    const resourceUid =
      req.params.uid || req.params.userId || req.body.uid || req.body.userId;
    if (!resourceUid) {
      throw new AuthError("Resource owner not specified");
    }

    assertOwner(requestUid, resourceUid);
    next();
  } catch (error) {
    if (error instanceof AuthError) {
      res.status(403).json({ error: error.message });
    } else {
      console.error("Ownership middleware error:", error);
      res.status(500).json({ error: "Internal server error" });
    }
  }
}

/**
 * Combined auth + ownership middleware
 */
export function withAuthAndOwnership(req: any, res: any, next: any): void {
  withAuth(req, res, (error?: any) => {
    if (error) return;
    withOwnership(req, res, next);
  });
}

/**
 * Middleware to require email verification
 */
export async function withEmailVerification(
  req: any,
  res: any,
  next: any
): Promise<void> {
  try {
    if (!req.user) {
      throw new AuthError("User not authenticated");
    }

    if (!req.user.email_verified) {
      res.status(403).json({
        error: "Email verification required",
        code: "email-not-verified",
      });
      return;
    }

    next();
  } catch (error) {
    console.error("Email verification middleware error:", error);
    res.status(500).json({ error: "Internal server error" });
  }
}

/**
 * Optional auth middleware - attaches user if token present but doesn't require it
 */
export async function withOptionalAuth(
  req: any,
  res: any,
  next: any
): Promise<void> {
  try {
    const authHeader = req.headers.authorization;
    if (authHeader && authHeader.startsWith("Bearer ")) {
      const token = authHeader.substring(7);
      if (token) {
        const decodedToken = await admin.auth().verifyIdToken(token);
        req.user = decodedToken;
        req.uid = decodedToken.uid;
        req.userId = decodedToken.uid;
      }
    }
    next();
  } catch (error) {
    // For optional auth, we continue even if token is invalid
    console.warn("Optional auth failed:", error);
    next();
  }
}
