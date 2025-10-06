import { describe, it, expect } from "@jest/globals";
import { themes } from "../themes";

describe("Markdown to PDF Themes", () => {
  it("should have all required themes defined", () => {
    expect(themes).toHaveProperty("github");
    expect(themes).toHaveProperty("clean");
    expect(themes).toHaveProperty("academic");
  });

  it("should have non-empty theme CSS", () => {
    expect(themes.github.length).toBeGreaterThan(0);
    expect(themes.clean.length).toBeGreaterThan(0);
    expect(themes.academic.length).toBeGreaterThan(0);
  });

  it("should include body styles in all themes", () => {
    expect(themes.github).toContain("body {");
    expect(themes.clean).toContain("body {");
    expect(themes.academic).toContain("body {");
  });

  it("should include heading styles in all themes", () => {
    expect(themes.github).toContain("h1");
    expect(themes.clean).toContain("h1");
    expect(themes.academic).toContain("h1");
  });

  it("should include code styles in all themes", () => {
    expect(themes.github).toContain("code {");
    expect(themes.clean).toContain("code {");
    expect(themes.academic).toContain("code {");
  });
});
