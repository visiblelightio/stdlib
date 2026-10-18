import { defineConfig } from "tsdown";

export default defineConfig({
  entry: ["src/index.ts"],
  format: "esm",
  target: "es2025",
  unbundle: true,
  exports: false,
  clean: true,
  sourcemap: true,
  dts: { oxc: {}, sourcemap: true },
});
