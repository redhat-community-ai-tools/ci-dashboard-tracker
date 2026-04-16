#!/bin/bash
# Render all Mermaid diagrams to PNG and SVG
#
# Prerequisites:
#   npm install -g @mermaid-js/mermaid-cli
#
# Usage:
#   ./render-all.sh

set -e

echo "Rendering Mermaid diagrams..."

# Create output directories
mkdir -p png svg

# Resolution for presentations (1920x1080)
WIDTH=1920
HEIGHT=1080

# Render each diagram
for mmd_file in *.mmd; do
    if [ -f "$mmd_file" ]; then
        filename=$(basename "$mmd_file" .mmd)
        echo "Rendering $filename..."

        # PNG for presentations
        mmdc -i "$mmd_file" -o "png/${filename}.png" -w $WIDTH -H $HEIGHT -b white

        # SVG for print/web (scalable)
        mmdc -i "$mmd_file" -o "svg/${filename}.svg" -b white

        echo "  -> png/${filename}.png"
        echo "  -> svg/${filename}.svg"
    fi
done

echo ""
echo "Done! Diagrams rendered to:"
echo "  - png/ (for PowerPoint/Keynote)"
echo "  - svg/ (for print/web, scalable)"
