import { AuthError } from "../util/errors.js";
import { admin } from "../admin.js";

export async function requireAuth(req: any): Promise<string> {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    throw new AuthError("Missing or invalid authorization header");
  }

  // Extract and verify Firebase ID token
  const token = authHeader.substring(7);
  if (!token) {
    throw new AuthError("Invalid token");
  }

  try {
    // Verify the Firebase ID token
    const decodedToken = await admin.auth().verifyIdToken(token);

    // Attach decoded token to request for downstream use
    (req as any).user = decodedToken;
    (req as any).uid = decodedToken.uid;

    return decodedToken.uid;
  } catch (error) {
    // Log the error for debugging but don't expose details
    console.error("Token verification failed:", error);
    throw new AuthError("Invalid or expired token");
  }
}

/**
 * Assert that the requesting user is the owner of the resource
 * @param requestUid The UID from the authenticated request
 * @param resourceUid The UID of the resource owner
 */
export function assertOwner(requestUid: string, resourceUid: string): void {
  if (requestUid !== resourceUid) {
    throw new AuthError("Access denied: not resource owner");
  }
}

/**
 * Extract Bearer token from request headers
 * @param req Express request object
 * @returns The extracted token string
 */
export function extractBearerToken(req: any): string {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    throw new AuthError("Missing or invalid authorization header");
  }

  const token = authHeader.substring(7);
  if (!token) {
    throw new AuthError("Invalid token");
  }

  return token;
}
