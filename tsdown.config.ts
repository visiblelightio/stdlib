import { defineConfig } from "tsdown";

export default defineConfig({
  entry: ["src/index.ts"],
  format: "esm",
  target: "baseline-widely-available",
  unbundle: true,
  exports: false,
  clean: true,
  sourcemap: true,
  dts: { oxc: {}, sourcemap: true },
});
