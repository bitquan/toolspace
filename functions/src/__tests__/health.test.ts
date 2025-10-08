import { health } from "../api/health.js";

describe("Health endpoint", () => {
  it("should return health status", () => {
    const mockRequest = {} as any;
    const mockResponse = {
      json: jest.fn(),
    } as any;

    health(mockRequest, mockResponse);

    expect(mockResponse.json).toHaveBeenCalledWith({
      ok: true,
      ts: expect.any(Number),
    });
  });
});
