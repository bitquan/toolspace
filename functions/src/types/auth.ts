import { DecodedIdToken } from "firebase-admin/auth";
import { Request } from "express";

/**
 * Extended request interface with Firebase auth information
 */
export interface AuthenticatedRequest extends Request {
  user?: DecodedIdToken;
  uid?: string;
  userId?: string;
}

/**
 * Type guard to check if request is authenticated
 */
export function isAuthenticatedRequest(
  req: Request
): req is AuthenticatedRequest {
  return "uid" in req && typeof (req as any).uid === "string";
}
