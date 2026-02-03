#!/bin/bash
for dir in sites/*/; do
  site_name=$(basename "$dir")
  ./build.sh "$site_name"
done