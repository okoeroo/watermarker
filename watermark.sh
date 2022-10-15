#!/bin/bash

export LC_CTYPE="en_US.UTF-8"

TEXT_CENTER="© Sandra van de Luitgaarden"
TEXT_LOW_LEFT="Celebrities Spotted"


#######################################
usage() {
    echo "Usage: $0 [-v] -d <directory> -i <file path> [-o <output filename>]" 1>&2;
    exit 1;
}

while getopts "vd:i:o:" o; do
    case "${o}" in
        v)  # Verbose
            vflag=1
            VERBOSE=1
            ;;
        d)  # Output directory
            dflag=1
            OUTPUT_DIRECTORY=${OPTARG}
            ;;
        i)  # Input file
            iflag=1
            INPUTFILE=${OPTARG}
            ;;
        o)  # Output file
            oflag=1
            OUTPUTFILE=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "$iflag" ]; then
    echo "Error: no input file path selected"
    usage
    exit 1
fi

if [ -z "$dflag" ]; then
    echo "Error: no output directory selected"
    usage
    exit 1
fi

if [ ! -d "${OUTPUT_DIRECTORY}" ]; then
    echo "Directory \"${OUTPUT_DIRECTORY}\" does not exist."
    exit 1
fi


# Input
original_image="${INPUTFILE}"
original_image_dirname="$(dirname "${INPUTFILE}")"
original_image_basename="$(basename "${INPUTFILE}")"
original_image_basename_name="${original_image_basename%.*}"
original_image_basename_ext="${INPUTFILE##*.}"


# Output
if [ ! -z "$oflag" ]; then
    watermarked_image_dirname="${OUTPUT_DIRECTORY}"
    watermarked_image_basename_name="${watermarked_image_basename%.*}"
    watermarked_image_basename_ext="${watermarked_image_basename##*.}"
    watermarked_image_basename="${OUTPUTFILE}"
    watermarked_image_final="${OUTPUTFILE}"
else
    watermarked_image="${INPUTFILE}"
    watermarked_image_dirname="${OUTPUT_DIRECTORY}"
    watermarked_image_basename_name="${original_image_basename_name}"
    watermarked_image_basename_ext=${original_image_basename_ext}
    watermarked_image_basename="${watermarked_image_basename_name}_watermarked.${watermarked_image_basename_ext}"
    watermarked_image_final="${watermarked_image_dirname}/${watermarked_image_basename}"
fi


echo $watermarked_image_dirname
echo $watermarked_image_basename_name
echo $watermarked_image_basename_ext
echo $watermarked_image_basename

echo $watermarked_image_final


echo "Input: ${original_image} - processing"


watermark() {
    INPUT="$1"
    OUTPUT="$2"
    GRAVITY="$3"
    WATERMARK_TEXT="$4"
    FONT_SIZE="$5"

    convert "${INPUT}" \
       -fill 'rgba(100%,100%,100%,0.4)' -pointsize ${FONT_SIZE} \
       -gravity ${GRAVITY} -draw "text 0,50 '${WATERMARK_TEXT}'" "${OUTPUT}"
}

step1() {
    input="$1"
    output="$2"

    convert "${input}" \
       -fill 'rgba(100%,100%,100%,0.2)' -pointsize 400 \
       -gravity Center -draw "text 0,50 '${TEXT_CENTER}'" "${output}"
}

step2() {
    input="$1"
    output="$2"

    convert "${input}" \
       -fill 'rgba(100%,100%,100%,0.4)' -pointsize 200 \
       -gravity SouthWest -draw "text 0,50 '${TEXT_LOW_LEFT}'" "${output}"
}


# Step 1
#step1 "${original_image}"                       "${watermarked_image_final}.step_1.TMP"
#step2 "${watermarked_image_final}.step_1.TMP"   "${watermarked_image_final}.step_2.TMP"


watermark \
    "${original_image}" \
    "${watermarked_image_final}.step_1.TMP" \
    "SouthWest" \
    "${TEXT_LOW_LEFT}" \
    200

watermark \
    "${watermarked_image_final}.step_1.TMP" \
    "${watermarked_image_final}.step_2.TMP" \
    "Center" \
    "${TEXT_CENTER}" \
    400

# Final step
cp "${watermarked_image_final}.step_2.TMP" "${watermarked_image_final}"


# Clean up
rm "${watermarked_image_final}.step_1.TMP"
rm "${watermarked_image_final}.step_2.TMP"


echo "Output: $watermarked_image_final - Done"

open "${watermarked_image_final}"
