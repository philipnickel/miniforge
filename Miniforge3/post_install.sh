#!/usr/bin/env bash

set -euo pipefail

# Load conda shell functions from the newly installed prefix and
# activate the base environment at that same prefix.
# shellcheck disable=SC1091
. "${PREFIX}/etc/profile.d/conda.sh" && conda activate "${PREFIX}"

# Initialize conda for all supported shells on this machine.
conda init --all

# Create PEP 668 EXTERNALLY-MANAGED marker to block pip/uv/poetry in base
PYTHON_VERSION=$("${PREFIX}/bin/python" -c "import sys; print(str(sys.version_info.major) + '.' + str(sys.version_info.minor))")
MARKER_FILE="${PREFIX}/lib/python${PYTHON_VERSION}/EXTERNALLY-MANAGED"

cat > "${MARKER_FILE}" << 'EOF'
[externally-managed]
Error=This base environment is frozen and should not be modified.
  Bypassing this protection can break your installation. Do so at your own risk.

  Instead, create a new environment:
    conda create -n myproject python=3.12
    conda activate myproject
    conda install <packages>

  Only use pip if the package is not available on conda-forge:
    pip install <packages>
EOF

chmod 644 "${MARKER_FILE}"
