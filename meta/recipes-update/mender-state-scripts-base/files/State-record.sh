#!/bin/sh

STATE_FILE=/data/mender/upgrade/state

mkdir -p "$(dirname "$STATE_FILE")"
echo "$(basename "$0" | cut -d_ -f1-2)" > "$STATE_FILE"
