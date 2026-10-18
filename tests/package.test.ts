import { execFileSync } from "node:child_process";
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import { expect, test } from "vitest";

const root = fileURLToPath(new URL("../", import.meta.url));

test("the packed package supports ESM and strict TypeScript consumers", () => {
  const directory = mkdtempSync(join(tmpdir(), "stdlib-consumer-"));
  try {
    execFileSync("npm", ["run", "build"], { cwd: root });
    const result = execFileSync(
      "npm",
      ["pack", "--ignore-scripts", "--json", "--pack-destination", directory],
      { cwd: root, encoding: "utf8" },
    );
    const packed = JSON.parse(result) as Record<string, { filename: string }>;
    const archive = packed["@visiblelightio/stdlib"];
    if (!archive) throw new Error("npm pack produced no archive");
    writeFileSync(
      join(directory, "package.json"),
      JSON.stringify({ private: true, type: "module" }),
    );
    execFileSync(
      "npm",
      ["install", "--ignore-scripts", "--no-audit", "--no-fund", join(directory, archive.filename)],
      { cwd: directory },
    );
    const output = execFileSync(
      process.execPath,
      [
        "--input-type=module",
        "--eval",
        'import * as stdlib from "@visiblelightio/stdlib"; console.log(JSON.stringify(Object.keys(stdlib)));',
      ],
      { cwd: directory, encoding: "utf8" },
    );
    expect(JSON.parse(output)).toEqual([]);
    const metadata = JSON.parse(
      readFileSync(join(directory, "node_modules/@visiblelightio/stdlib/package.json"), "utf8"),
    ) as { dependencies?: Record<string, string> };
    expect(metadata.dependencies ?? {}).toEqual({});
    writeFileSync(
      join(directory, "consumer.mts"),
      `
import * as stdlib from "@visiblelightio/stdlib";
const empty: Record<string, never> = stdlib;
// @ts-expect-error No utilities are public yet.
import { add } from "@visiblelightio/stdlib";
// @ts-expect-error Internal source paths are not public exports.
import "@visiblelightio/stdlib/src/index.ts";
void empty;
`,
    );
    writeFileSync(
      join(directory, "tsconfig.json"),
      JSON.stringify({
        compilerOptions: {
          target: "ES2025",
          module: "NodeNext",
          strict: true,
          noUncheckedIndexedAccess: true,
          exactOptionalPropertyTypes: true,
          noImplicitOverride: true,
          noUncheckedSideEffectImports: true,
          noEmit: true,
          types: [],
          lib: ["ES2025"],
        },
        include: ["consumer.mts"],
      }),
    );
    execFileSync(
      join(root, "node_modules/.bin/tsc"),
      ["--project", join(directory, "tsconfig.json")],
      { cwd: directory },
    );
    expect(() =>
      execFileSync(
        process.execPath,
        ["--input-type=module", "--eval", 'import "@visiblelightio/stdlib/src/index.ts";'],
        { cwd: directory, stdio: "pipe" },
      ),
    ).toThrow();
  } finally {
    rmSync(directory, { recursive: true, force: true });
  }
}, 60_000);
