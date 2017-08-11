#!/bin/sh
ratpoison &
chromium --incognito --kiosk --no-default-browser-check file:///usr/local/src/airgap-signer-v1.0.2/index.html
