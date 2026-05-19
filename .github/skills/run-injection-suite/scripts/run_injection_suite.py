import argparse
import json
import os
import subprocess
import time
from datetime import datetime
from pathlib import Path


def load_inputs(path: Path) -> list[str]:
    lines = path.read_text(encoding="utf-8").splitlines()
    return [line for line in lines if line.strip()]


def run_command(command: str, input_text: str) -> dict:
    env = os.environ.copy()
    env["RIRI_INPUT"] = input_text

    start = time.time()
    result = subprocess.run(
        command,
        shell=True,
        capture_output=True,
        text=True,
        env=env,
    )
    duration_ms = int((time.time() - start) * 1000)

    return {
        "stdout": result.stdout,
        "stderr": result.stderr,
        "returncode": result.returncode,
        "duration_ms": duration_ms,
    }


def main() -> None:
    parser = argparse.ArgumentParser(description="Run a defensive adversarial input suite.")
    parser.add_argument("--inputs", required=True, help="Path to newline-delimited inputs file")
    parser.add_argument("--command", required=True, help="Command that reads RIRI_INPUT env var")
    parser.add_argument("--log", required=True, help="Path to JSONL log file")
    parser.add_argument("--meta", default="", help="Optional metadata string appended to each record")
    args = parser.parse_args()

    inputs_path = Path(args.inputs)
    log_path = Path(args.log)
    log_path.parent.mkdir(parents=True, exist_ok=True)

    inputs = load_inputs(inputs_path)
    if not inputs:
        raise ValueError("Inputs file is empty.")

    with log_path.open("w", encoding="utf-8") as handle:
        for index, input_text in enumerate(inputs):
            run_data = run_command(args.command, input_text)
            record = {
                "index": index,
                "input": input_text,
                "timestamp": datetime.utcnow().isoformat() + "Z",
                "meta": args.meta,
                **run_data,
            }
            handle.write(json.dumps(record, ensure_ascii=True) + "\n")

    print(f"Wrote {len(inputs)} records to {log_path}")


if __name__ == "__main__":
    main()
