#!/bin/bash

set -euo pipefail

# Install all basic utils.
apt-get install -y --no-install-recommends wget lsb-release software-properties-common gnupg make git pkg-config cmake tar
