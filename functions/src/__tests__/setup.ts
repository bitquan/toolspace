// Global test setup
import { beforeAll, afterAll, jest, describe, it, expect } from "@jest/globals";

beforeAll(() => {
  // Setup test environment
  jest.setTimeout(10000);
});

afterAll(() => {
  // Cleanup
});

// Add a basic test to make Jest happy
describe("Test setup", () => {
  it("should have proper test environment", () => {
    expect(true).toBe(true);
  });
});
