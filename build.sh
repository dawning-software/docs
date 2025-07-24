#!/bin/sh
git clone https://github.com/dawnlarsson/dawning-kit 2>/dev/null || true

. dawning-kit/doc.sh

doc_folder() {
        local input_folder="$1"
        local output_folder="${2:-dist}"

        mkdir -p "$output_folder"

        for file in "$input_folder"/*.md; do
                if [ -f "$file" ]; then
                        local filename=$(basename "$file" .md)
                        cp template.html "$output_folder/$filename.html"

                        local side=$(doc side.md)
                        template_replace "<meta template_side>" "$output_folder/$filename.html" "$side"

                        local content=$(doc "$file")
                        template_replace "<meta template_body>" "$output_folder/$filename.html" "$content"
                fi
        done
}

build() {
        rm -rf dist
        mkdir -p dist
        cp -r assets/* dist/

        less_css "style/*.css" dist/style.css

        doc_folder "dawning" "dist/dawning"

        cp dist/dawning/index.html dist/index.html
}

build

# check if "watch" argument is passed
if [ "$1" = "watch" ]; then
        while inotifywait -e modify -r .; do
                build
                echo "Rebuilt documentation."
        done
fi
