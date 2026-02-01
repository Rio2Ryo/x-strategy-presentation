#!/bin/bash
# Create video v2 - with precise audio sync

SLIDES_DIR="screenshots"
AUDIO_DIR="audio-v2-combined"
OUTPUT_DIR="video-parts-v2"
FINAL_OUTPUT="final-video-v2.mp4"

mkdir -p "$OUTPUT_DIR"

echo "Creating video parts with precise timing..."

for i in $(seq 1 33); do
  slide_num=$(printf '%02d' $i)
  slide_file=$(ls $SLIDES_DIR/slide-${slide_num}-*.png 2>/dev/null | head -1)
  audio_file="$AUDIO_DIR/slide-${slide_num}.mp3"
  output_file="$OUTPUT_DIR/part-${slide_num}.mp4"
  
  if [ -f "$slide_file" ] && [ -f "$audio_file" ]; then
    # Get precise audio duration
    duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$audio_file")
    echo "Creating video for slide $slide_num (${duration}s)..."
    
    ffmpeg -y -loop 1 -i "$slide_file" -i "$audio_file" \
      -c:v libx264 -tune stillimage -c:a aac -b:a 192k \
      -pix_fmt yuv420p -t "$duration" -r 30 "$output_file" 2>/dev/null
  else
    echo "Skipping slide $slide_num (missing files)"
  fi
done

echo "Creating file list..."
> filelist-v2.txt
for f in $(ls -v $OUTPUT_DIR/part-*.mp4 2>/dev/null); do
  echo "file '$f'" >> filelist-v2.txt
done

echo "Merging all parts into final video..."
ffmpeg -y -f concat -safe 0 -i filelist-v2.txt -c copy "$FINAL_OUTPUT" 2>/dev/null

if [ -f "$FINAL_OUTPUT" ]; then
  echo "Success! Final video: $FINAL_OUTPUT"
  ls -lh "$FINAL_OUTPUT"
  # Show total duration
  total_dur=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$FINAL_OUTPUT")
  echo "Total duration: ${total_dur}s"
else
  echo "Error: Failed to create final video"
fi
