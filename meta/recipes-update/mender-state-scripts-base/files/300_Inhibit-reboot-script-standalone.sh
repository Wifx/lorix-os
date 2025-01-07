#!/bin/sh

PREFIX=INHIBIT-REBOOT-SCRIPT-STANDALONE

echo "Inhibiting reboot script for standalone mode"
touch /data/mender/upgrade/inhibit-reboot-script-standalone
