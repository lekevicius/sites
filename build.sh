#!/bin/bash
set -e

SITE=$1

if [ -z "$SITE" ]; then
  echo "Usage: ./build.sh <astro-site>"
  echo "Example: ./build.sh alive_app"
  exit 1
fi

SITE_DIR="astro/$SITE"

if [ ! -d "$SITE_DIR" ]; then
  echo "Error: Astro site '$SITE' not found at $SITE_DIR"
  exit 1
fi

if [ ! -d "$SITE_DIR/src/pages" ]; then
  echo "Error: '$SITE' does not look like an Astro site"
  exit 1
fi

cd "$SITE_DIR"
pnpm pages:build
