#!/bin/bash
set -e

for dir in astro/*/; do
  site_name=$(basename "$dir")
  if [ "$site_name" = "_base" ]; then
    continue
  fi
  if [ ! -d "$dir/src/pages" ]; then
    continue
  fi
  ./build.sh "$site_name"
done
