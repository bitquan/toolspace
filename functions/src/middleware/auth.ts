import { requireAuth } from "../util/guards.js";
import { AuthError } from "../util/errors.js";

export function authMiddleware(req: any, res: any, next: any): void {
  try {
    const userId = requireAuth(req);
    // Attach user ID to request for downstream handlers
    (req as any).userId = userId;
    next();
  } catch (error) {
    if (error instanceof AuthError) {
      res.status(401).json({ error: error.message });
    } else {
      res.status(500).json({ error: "Internal server error" });
    }
  }
}
