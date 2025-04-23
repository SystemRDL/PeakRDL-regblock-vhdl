#!/bin/bash

set -e

cd "$(dirname "$0")"

# Initialize venv
rm -rf .venv
uv venv --no-project
source .venv/bin/activate

# Install test dependencies
uv pip install -r requirements.txt

# Install dut
uv pip install -e "../[cli]"

# Run lint
pylint --rcfile pylint.rc ../src/peakrdl_regblock_vhdl

# Run static type checking
mypy ../src/peakrdl_regblock_vhdl

# Run unit tests
pytest --workers auto --cov=peakrdl_regblock_vhdl --synth-tool skip

# Generate coverage report
coverage html -i -d htmlcov
