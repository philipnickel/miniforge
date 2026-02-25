#!/usr/bin/env bash

set -euo pipefail

# Load conda shell functions from the newly installed prefix and
# activate the base environment at that same prefix.
# shellcheck disable=SC1091
. "${PREFIX}/etc/profile.d/conda.sh" && conda activate "${PREFIX}"

# Initialize conda for all supported shells on this machine.
conda init --all
