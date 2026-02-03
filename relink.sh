#!/bin/bash

# Re-create symlinks for all sites after cloning
# Git tracks symlinks, but they may not work on Windows or some configurations

BASE_DIR="_base"
SITES_DIR="sites"

# Check if _base directory exists
if [ ! -d "$BASE_DIR" ]; then
    echo "Error: Base directory '$BASE_DIR' not found"
    exit 1
fi

# Check if sites directory exists
if [ ! -d "$SITES_DIR" ]; then
    echo "Error: Sites directory '$SITES_DIR' not found"
    exit 1
fi

# Files to symlink
SYMLINK_FILES=(
    "astro.config.mjs"
    "package.json"
    "pnpm-lock.yaml"
    "pnpm-workspace.yaml"
    "tsconfig.json"
    "node_modules"
)

# Process each site
for site in "$SITES_DIR"/*/; do
    if [ -d "$site" ]; then
        site_name=$(basename "$site")
        echo "Relinking: $site_name"
        
        cd "$site"
        
        for file in "${SYMLINK_FILES[@]}"; do
            # Remove existing file/symlink if it exists
            if [ -e "$file" ] || [ -L "$file" ]; then
                rm -rf "$file"
            fi
            
            # Create new symlink
            ln -s "../../$BASE_DIR/$file" "$file"
            echo "  ✓ $file"
        done
        
        cd - > /dev/null
    fi
done

echo ""
echo "Done! All sites relinked to _base."
echo "Run 'cd _base && pnpm install' if node_modules is missing."
