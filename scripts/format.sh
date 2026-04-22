#!/bin/bash
set -e
echo "=== Formatting Python files with black ==="
uv run black .
echo "Done."
