#! /bin/bash

SITE=$1

if [ -z "$SITE" ]; then
  echo "Usage: $0 <astro-site>"
  echo "Example: $0 alive_app"
  exit 1
fi

cd "astro/$SITE"
pnpm dev --host "$SITE.localhost"
