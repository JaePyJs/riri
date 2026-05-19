---
name: run-injection-suite
description: "Run a defensive adversarial input suite against the local Gemini Nano integration and log outputs for analysis."
argument-hint: "Provide input file, command, and log path"
---

# Run Injection Suite

## When to Use

- Collecting defensive robustness data for thesis experiments
- Running a fixed input suite against local inference code

## Safety Rules

- Inputs must be for defensive evaluation only.
- Do not use this skill to bypass restrictions or generate exploit payloads.

## Procedure

1. Prepare a newline-delimited input file (one input per line).
2. Provide a command that reads the input from `RIRI_INPUT` env var.
3. Run the script to execute the suite and write a JSONL log.

## Run

- Script: [run_injection_suite.py](./scripts/run_injection_suite.py)

Example:

```bash
python .github/skills/run-injection-suite/scripts/run_injection_suite.py \
  --inputs ./data/inputs.txt \
  --command "python ./scripts/run_infer.py" \
  --log ./data/injection-results.jsonl
```
