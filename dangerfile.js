// Surface `make lint` (checkmake) findings as PR failures.
// The lint step writes its full output to lint.txt and always exits 0 in CI,
// so this dangerfile is the single source of truth for whether to comment.
// `fail()` makes Danger exit non-zero, which fails the workflow and blocks merge.
const fs = require("fs");

const LINT_OUTPUT = "lint.txt";

function checkmakeReport() {
  if (!fs.existsSync(LINT_OUTPUT)) return null;
  const raw = fs.readFileSync(LINT_OUTPUT, "utf8").trim();
  if (raw.length === 0) return null;

  // checkmake exits 0 with no output when clean.
  // If only the "==>" banner from `make lint` is present, treat as clean.
  const looksClean =
    /^==>\s/.test(raw) &&
    !/\b(error|warning|issue)\b/i.test(raw) &&
    !/\|\s*\d+\s*\|/.test(raw);
  return looksClean ? null : raw;
}

const report = checkmakeReport();
if (report) {
  fail(
    [
      "**Makefile lint** (`make lint` / checkmake) で以下を検出しました。",
      "マージ前に修正してください。",
      "",
      "```",
      report,
      "```",
    ].join("\n"),
  );
}
