#!/usr/bin/env bash

# Cleaning up caches from APT.
apt-get autoremove -y --purge
apt-get autoclean

# Cleaning up caches and temporary folder.
rm -rf /var/lib/apt/lists/*
rm -rf /tmp/*
