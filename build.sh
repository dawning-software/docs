#!/bin/sh
git clone https://github.com/dawnlarsson/dawning-kit 2>/dev/null || true

. dawning-kit/doc.sh

folders="docs/dawning;docs/kit;docs/c standard;docs/eos"
side=""

# Function to sanitize names for URLs (replace spaces with dashes)
sanitize_for_url() {
    printf '%s' "$1" | sed 's/ /-/g'
}

doc_folder() {
    folder="$1"
    output_folder="${2:-dist}"
    mkdir -p "$output_folder"
    for file in "$folder"/*.md; do
        
        if [ -f "$file" ]; then
            filename=$(basename "$file" .md)
            sanitized_filename=$(sanitize_for_url "$filename")
            cp template.html "$output_folder/$sanitized_filename.html"
            
            template_replace "<meta template_side>" "$output_folder/$sanitized_filename.html" "$side"
            
            content=$(doc "$file")
            template_replace "<meta template_body>" "$output_folder/$sanitized_filename.html" "$content"
        fi
    done
}

build() {
    rm -rf dist
    mkdir -p dist
    cp -r assets/* dist/
    
    less_css "style/*.css" dist/style.css
    
    : > side.md
    
    # Process each folder (split on semicolon)
    remaining_folders="$folders"
    while [ -n "$remaining_folders" ]; do
        case "$remaining_folders" in
            *\;*)
                folder="${remaining_folders%%;*}"
                remaining_folders="${remaining_folders#*;}"
            ;;
            *)
                folder="$remaining_folders"
                remaining_folders=""
            ;;
        esac
        
        if [ -n "$folder" ]; then
            folder_title=$(basename "$folder")
            sanitized_folder=$(sanitize_for_url "$folder_title")
            output_folder="dist/$sanitized_folder"
            
            printf '%s\n' "$folder_title" >> side.md
            
            for file in "$folder"/*.md; do
                if [ -f "$file" ]; then
                    filename=$(basename "$file" .md)
                    sanitized_filename=$(sanitize_for_url "$filename")
                    printf '<a qx href="/%s/%s.html">%s</a>\n' "$sanitized_folder" "$sanitized_filename" "$filename" >> side.md
                fi
            done
        fi
    done
    
    side=$(doc side.md)
    
    # Process folders again for doc_folder calls
    remaining_folders="$folders"
    while [ -n "$remaining_folders" ]; do
        case "$remaining_folders" in
            *\;*)
                folder="${remaining_folders%%;*}"
                remaining_folders="${remaining_folders#*;}"
            ;;
            *)
                folder="$remaining_folders"
                remaining_folders=""
            ;;
        esac
        
        if [ -n "$folder" ]; then
            folder_title=$(basename "$folder")
            sanitized_folder=$(sanitize_for_url "$folder_title")
            doc_folder "$folder" "dist/$sanitized_folder"
        fi
    done
    
    sanitized_dawning=$(sanitize_for_url "dawning")
    if [ -f "dist/$sanitized_dawning/about.html" ]; then
        cp "dist/$sanitized_dawning/about.html" dist/index.html
        elif [ -f "dist/dawning/about.html" ]; then
        cp "dist/dawning/about.html" dist/index.html
    fi
}

build

# check if "watch" argument is passed
if [ "$1" = "watch" ]; then
    while inotifywait -e modify -r .; do
        build
        echo "Rebuilt documentation."
    done
fi