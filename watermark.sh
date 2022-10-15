#!/bin/bash

export LC_CTYPE="en_US.UTF-8"

TEXT_CENTER="© Sandra van de Luitgaarden"
TEXT_LOW_LEFT="Celebrities Spotted"



if [ -z "$1" ]; then
    echo "Error: no filename provided"
    exit 1
fi

# Input
original_image="$1"

# Dissect
extension="${original_image##*.}"
original_image_base="${original_image%.*}"

# Output
new_image="${original_image_base}_watermarked.${extension}"


echo "Input: ${original_image} - processing"


convert "${original_image}" \
   -fill 'rgba(100%,100%,100%,0.2)' -pointsize 400 \
   -gravity Center -draw "text 0,50 '${TEXT_CENTER}'" "${new_image}.step_1.TMP"

convert "${new_image}.step_1.TMP" \
   -fill 'rgba(100%,100%,100%,0.4)' -pointsize 200 \
   -gravity SouthWest -draw "text 0,50 '${TEXT_LOW_LEFT}'" "${new_image}.step_2.TMP"


# Final file
cp "${new_image}.step_2.TMP" "${new_image}"

# Clean up
rm "${new_image}.step_1.TMP"
rm "${new_image}.step_2.TMP"


echo "Output: $new_image - Done"

open "${new_image}"
