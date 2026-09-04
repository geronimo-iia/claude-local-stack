
This session is a quality evaluation. Work normally — tool use, file reads, edits — as you would for a real coding task.

## Task

Pick any small Rust project or file in the current working directory and do the following:

1. **Explore** — use file/grep tools to understand the structure. Find a module with at least one function.
2. **Add a unit test** — write a meaningful test for an existing function (not trivial, cover an edge case).
3. **Spot a real issue** — identify one thing that could be improved (correctness, performance, ergonomics). Explain the specific problem, not generic advice.
4. **Fix it** — implement the fix with a proper edit.
5. **Self-review** — after editing, re-read the changed file and confirm the fix is correct.

## What to observe (report at the end)

- Did tool calls (file read, grep, edit) work without parser errors?
- Did the model produce correct Rust (types, lifetimes, borrow checker awareness)?
- Did it hallucinate APIs or crate names?
- Did the unit test actually test something meaningful?
- Overall: would you trust this model for daily Rust coding?

Write a short verdict (3-5 sentences) at the end of the session.

## Constraints

- Rust only
- No new dependencies
- Do not ask clarifying questions — pick whatever target looks interesting and proceed
