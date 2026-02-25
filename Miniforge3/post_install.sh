#!/bin/bash
# Post-installation script to add PEP 668 EXTERNALLY-MANAGED marker
# This prevents pip/uv/poetry from modifying the base environment

set -e

# Create the EXTERNALLY-MANAGED marker file to block pip installations
# The file needs to be in lib/pythonX.Y/ directory
# Constructor sets PREFIX to the installation directory

# Find Python version dynamically
PYTHON_VERSION=$("${PREFIX}/bin/python" -c "import sys; print(str(sys.version_info.major) + '.' + str(sys.version_info.minor))")

MARKER_FILE="${PREFIX}/lib/python${PYTHON_VERSION}/EXTERNALLY-MANAGED"

echo "Creating PEP 668 marker file at: ${MARKER_FILE}"

cat > "${MARKER_FILE}" << 'EOF'
[externally-managed]
Error=This DTU Python base environment is frozen and cannot be modified.

To install additional packages, create a new environment:
  conda create -n myproject python=3.12
  conda activate myproject
  conda install <packages>   # or: pip install <packages>

This protection applies to both conda/mamba AND pip/uv/poetry.

For more information about frozen environments:
  - conda/mamba: https://conda.org/learn/ceps/cep-0022
  - pip: https://peps.python.org/pep-0668/
EOF

chmod 644 "${MARKER_FILE}"

echo "PEP 668 protection installed successfully"
