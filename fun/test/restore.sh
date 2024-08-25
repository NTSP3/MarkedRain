#!/bin/bash
find . -mindepth 1 -maxdepth 1 ! -name 'bak' ! -name 'restore.sh' -exec rm -rf {} +
rsync -a bak/ .
