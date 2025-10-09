module.exports = {
  preset: "ts-jest",
  testEnvironment: "node",
  testMatch: ["**/test/security/**/*.test.ts"],
  moduleFileExtensions: ["ts", "tsx", "js", "jsx", "json"],
  transform: {
    "^.+\\.tsx?$": [
      "ts-jest",
      {
        tsconfig: {
          esModuleInterop: true,
          allowSyntheticDefaultImports: true,
        },
      },
    ],
  },
  collectCoverage: true,
  coverageDirectory: "coverage/security",
  coverageReporters: ["text", "lcov", "html"],
  testTimeout: 30000,
  maxWorkers: 1, // Run tests sequentially for emulator
};
