#!/bin/sh
ratpoison &
cd /usr/local/src/ && python -mSimpleHTTPServer &
chromium --incognito --no-default-browser-check http://localhost:8000
