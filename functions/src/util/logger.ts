export const logger = {
  info: (message: string, data?: any) =>
    console.log(`[INFO] ${message}`, data || ""),
  warn: (message: string, data?: any) =>
    console.warn(`[WARN] ${message}`, data || ""),
  error: (message: string, data?: any) =>
    console.error(`[ERROR] ${message}`, data || ""),
};
