import { AuthError } from "../util/errors.js";

export function requireAuth(req: any): string {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    throw new AuthError("Missing or invalid authorization header");
  }

  // TODO: Validate JWT token here
  const token = authHeader.substring(7);
  if (!token) {
    throw new AuthError("Invalid token");
  }

  return token; // Return user ID after validation
}
