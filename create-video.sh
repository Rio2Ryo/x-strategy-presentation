#!/bin/bash
# Create video from slides and audio

SLIDES_DIR="screenshots"
AUDIO_DIR="audio-combined"
OUTPUT_DIR="video-parts"
FINAL_OUTPUT="final-video.mp4"

mkdir -p "$OUTPUT_DIR"

echo "Creating video parts..."

for i in $(seq 1 33); do
  slide_num=$(printf '%02d' $i)
  slide_file=$(ls $SLIDES_DIR/slide-${slide_num}-*.png 2>/dev/null | head -1)
  audio_file="$AUDIO_DIR/slide-${slide_num}.mp3"
  output_file="$OUTPUT_DIR/part-${slide_num}.mp4"
  
  if [ -f "$slide_file" ] && [ -f "$audio_file" ]; then
    echo "Creating video for slide $i..."
    ffmpeg -y -loop 1 -i "$slide_file" -i "$audio_file" \
      -c:v libx264 -tune stillimage -c:a aac -b:a 192k \
      -pix_fmt yuv420p -shortest -r 30 "$output_file" 2>/dev/null
  else
    echo "Skipping slide $i (missing: slide=$slide_file audio=$audio_file)"
  fi
done

echo "Creating file list..."
> filelist.txt
for f in $(ls -v $OUTPUT_DIR/part-*.mp4 2>/dev/null); do
  echo "file '$f'" >> filelist.txt
done

echo "Merging all parts into final video..."
ffmpeg -y -f concat -safe 0 -i filelist.txt -c copy "$FINAL_OUTPUT" 2>/dev/null

if [ -f "$FINAL_OUTPUT" ]; then
  echo "Success! Final video: $FINAL_OUTPUT"
  ls -lh "$FINAL_OUTPUT"
else
  echo "Error: Failed to create final video"
fi
