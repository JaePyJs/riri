---
name: scaffold-riri-screen
description: "Generate a standard Riri Compose screen + ViewModel scaffold with StateFlow and a dark theme Preview. Use for new UI screens."
argument-hint: "Provide screen name, package, and output directory"
---

# Scaffold Riri Screen

## When to Use

- Creating a new Compose screen with a matching ViewModel
- Ensuring UDF with StateFlow and a dark preview background

## Procedure

1. Choose a `ScreenName` (PascalCase), Kotlin `package`, and output directory.
2. Run the scaffold script to generate `Screen` + `ViewModel` files.
3. Open the generated files and wire navigation/events as needed.

## Run

- Script: [scaffold_riri_screen.py](./scripts/scaffold_riri_screen.py)

Example:

```bash
python .github/skills/scaffold-riri-screen/scripts/scaffold_riri_screen.py \
  --screen ChaosReport \
  --package com.riri.ui.chaos \
  --output-dir app/src/main/java/com/riri/ui/chaos
```
