#!/usr/bin/env bash

failed=0

check_html="${INPUT_CHECK_HTML:-true}"
if [[ "$check_html" =~ ^t.*|^T.*|^y.*|^Y.*|^1.* ]]; then
  if ! html5validator --also-check-css --log INFO --root "${INPUT_DIRECTORY}"; then
    failed=1
  fi
fi

tries="${INPUT_RETRIES:-3}"

while [ "$tries" -ge 1 ]; do
  tries=$((tries-1))
  if RUBYOPT="-W0" ruby /proof-html.rb; then
    break
  fi
  if [ "$tries" -ge 1 ]; then
    sleep 5
  fi
  if [ "$tries" -eq 0 ]; then
    failed=1
  fi
done

exit $failed
