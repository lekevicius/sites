#!/bin/bash

# Check if site name is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <site-name>"
    echo "Example: $0 my-new-site.com"
    exit 1
fi

SITE_NAME="$1"
SITE_DIR="sites/$SITE_NAME"
BASE_DIR="_base"

# Check if site directory already exists
if [ -d "$SITE_DIR" ]; then
    echo "Error: Site directory '$SITE_DIR' already exists"
    exit 1
fi

# Check if _base directory exists
if [ ! -d "$BASE_DIR" ]; then
    echo "Error: Base directory '$BASE_DIR' not found"
    exit 1
fi

echo "Creating new site: $SITE_NAME"

# Create site directory
mkdir -p "$SITE_DIR"

# Navigate to site directory
cd "$SITE_DIR"

echo "Creating symlinks to base configuration files..."
# Create symlinks to base configuration files
ln -s "../../$BASE_DIR/astro.config.mjs" astro.config.mjs
ln -s "../../$BASE_DIR/package.json" package.json
ln -s "../../$BASE_DIR/pnpm-lock.yaml" pnpm-lock.yaml
ln -s "../../$BASE_DIR/pnpm-workspace.yaml" pnpm-workspace.yaml
ln -s "../../$BASE_DIR/node_modules" node_modules
ln -s "../../$BASE_DIR/tsconfig.json" tsconfig.json

echo "Copying public and src folders..."
# Copy public and src folders from base
cp -r "../../$BASE_DIR/.gitignore" .gitignore
cp -r "../../$BASE_DIR/public" .
mkdir -p ./src
cp -r "../../$BASE_DIR/src/pages" ./src
cp -r "../../$BASE_DIR/src/assets" ./src

echo "Initializing git repository..."
# Initialize git repo
git init

echo "Building the site..."
# Run pnpm build
pnpm build

echo "✅ Site '$SITE_NAME' created successfully!"
echo "📁 Location: $SITE_DIR"
echo "🚀 To start development: cd $SITE_DIR && pnpm dev"
