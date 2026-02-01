#!/bin/bash
# Merge slides and audio into video

SLIDES_DIR="screenshots"
AUDIO_DIR="audio"
OUTPUT_DIR="video-parts"
FINAL_OUTPUT="final-video.mp4"

mkdir -p "$OUTPUT_DIR"

# Create video parts for each slide
for i in $(seq -w 1 33); do
  slide_num=$(echo $i | sed 's/^0*//')
  slide_file="$SLIDES_DIR/slide-$(printf '%02d' $slide_num)-*.png"
  audio_file="$AUDIO_DIR/slide-${slide_num}.mp3"
  output_file="$OUTPUT_DIR/part-$(printf '%02d' $slide_num).mp4"
  
  # Find the actual slide file
  actual_slide=$(ls $SLIDES_DIR/slide-$(printf '%02d' $slide_num)-*.png 2>/dev/null | head -1)
  
  if [ -f "$actual_slide" ] && [ -f "$audio_file" ]; then
    echo "Creating video for slide $slide_num..."
    ffmpeg -y -loop 1 -i "$actual_slide" -i "$audio_file" \
      -c:v libx264 -tune stillimage -c:a aac -b:a 192k \
      -pix_fmt yuv420p -shortest "$output_file" 2>/dev/null
  else
    echo "Skipping slide $slide_num (missing files)"
  fi
done

# Create file list for concatenation
echo "Creating file list..."
> filelist.txt
for f in $(ls -v $OUTPUT_DIR/*.mp4); do
  echo "file '$f'" >> filelist.txt
done

# Concatenate all parts
echo "Merging all parts..."
ffmpeg -y -f concat -safe 0 -i filelist.txt -c copy "$FINAL_OUTPUT" 2>/dev/null

echo "Done! Final video: $FINAL_OUTPUT"
