import tseslint from "@typescript-eslint/eslint-plugin";
import parser from "@typescript-eslint/parser";

export default [
  {
    files: ["src/**/*.ts"],
    languageOptions: {
      parser: parser,
      ecmaVersion: 2022,
      sourceType: "module",
      parserOptions: {
        project: "./tsconfig.json",
      },
    },
    plugins: {
      "@typescript-eslint": tseslint,
    },
    rules: {
      "no-unused-vars": "off",
      "@typescript-eslint/no-unused-vars": ["error", { argsIgnorePattern: "^_" }],
    },
  },
  {
    ignores: [
      "lib/**/*",
      "node_modules/**/*",
      "*.js",
      "src/**/__tests__/**",
      "src/**/*.test.ts",
      "src/tools/file_merger/**",
      "src/tools/image_resizer/**",
      "src/tools/md_to_pdf/**",
      "src/tools/url-short/**",
    ],
  },
];
