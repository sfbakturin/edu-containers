#!/usr/bin/env bash

set -euo pipefail

# Python PIP.
apt-get install --no-install-recommends -y python3-pip

# PyYAML library.
pip3 install pyyaml
