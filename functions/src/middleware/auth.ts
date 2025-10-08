import { requireAuth } from "../util/guards.js";
import { AuthError } from "../util/errors.js";

export async function authMiddleware(
  req: any,
  res: any,
  next: any
): Promise<void> {
  try {
    const userId = await requireAuth(req);
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
