#!/bin/sh

tries="${INPUT_RETRIES:-3}"

code=1
while [ "$tries" -ge 1 ]; do
  tries=$((tries-1))
  ruby /proof-html.rb
  code="$?"
  if [ "$code" -eq 0 ]; then
    break
  fi
  if [ "$tries" -ge 1 ]; then
    sleep 5
  fi
done

exit "$code"
