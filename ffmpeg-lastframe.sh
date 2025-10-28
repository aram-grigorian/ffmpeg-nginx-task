#!/bin/bash

set -e

INPUT_VIDEO="https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
OUTPUT_IMAGE="/output/last_frame.jpg"

DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$INPUT_VIDEO")

SEEK_TIME=$(echo "$DURATION - 0.1" | bc -l)


ffmpeg -ss "$SEEK_TIME" -i "$INPUT_VIDEO" -vframes 1 -q:v 1 -y "$OUTPUT_IMAGE"

echo "Last frame extracted to $OUTPUT_IMAGE"
