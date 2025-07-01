#!/bin/sh

PREFIX=INHIBIT-REBOOT-SCRIPT-STANDALONE

INHIBIT_FILE_PATH="/data/mender/upgrade/inhibit-reboot-script-standalone"

echo "Inhibiting reboot script for standalone mode"
touch $INHIBIT_FILE_PATH
