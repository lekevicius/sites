#! /bin/bash

SITE=$1

if [ -z "$SITE" ]; then
  echo "Usage: $0 <site>"
  exit 1
fi

cd sites/$SITE
pnpm dev --host $SITE.localhost