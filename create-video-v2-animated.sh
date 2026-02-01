#!/bin/bash
# Create video v2 with Ken Burns effect (zoompan)

SLIDES_DIR="screenshots"
AUDIO_DIR="audio-v2-combined"
OUTPUT_DIR="video-parts-v2-animated"
FINAL_OUTPUT="final-video-v2-animated.mp4"

mkdir -p "$OUTPUT_DIR"

echo "Creating animated video parts with Ken Burns effect..."

for i in $(seq 1 33); do
  slide_num=$(printf '%02d' $i)
  slide_file=$(ls $SLIDES_DIR/slide-${slide_num}-*.png 2>/dev/null | head -1)
  audio_file="$AUDIO_DIR/slide-${slide_num}.mp3"
  output_file="$OUTPUT_DIR/part-${slide_num}.mp4"
  
  if [ -f "$slide_file" ] && [ -f "$audio_file" ]; then
    # Get precise audio duration
    duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$audio_file")
    # Calculate frames (30fps)
    frames=$(echo "$duration * 30" | bc | cut -d'.' -f1)
    
    echo "Creating animated video for slide $slide_num (${duration}s, ${frames} frames)..."
    
    # Ken Burns effect: slow zoom in from 1.0x to 1.1x
    # zoompan filter: z=zoom factor, d=duration in frames
    # pzs=pan x start, pys=pan y start (center)
    ffmpeg -y -i "$slide_file" -i "$audio_file" \
      -filter_complex "[0:v]scale=8000:-1,zoompan=z='min(zoom+0.0003,1.1)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=${frames}:s=1920x1080:fps=30[v]" \
      -map "[v]" -map 1:a \
      -c:v libx264 -preset fast -crf 23 -c:a aac -b:a 192k \
      -t "$duration" "$output_file" 2>/dev/null
  else
    echo "Skipping slide $slide_num (missing files)"
  fi
done

echo "Creating file list..."
> filelist-v2-animated.txt
for f in $(ls -v $OUTPUT_DIR/part-*.mp4 2>/dev/null); do
  echo "file '$f'" >> filelist-v2-animated.txt
done

echo "Merging all parts into final video..."
ffmpeg -y -f concat -safe 0 -i filelist-v2-animated.txt -c copy "$FINAL_OUTPUT" 2>/dev/null

if [ -f "$FINAL_OUTPUT" ]; then
  echo "Success! Final video: $FINAL_OUTPUT"
  ls -lh "$FINAL_OUTPUT"
  total_dur=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$FINAL_OUTPUT")
  echo "Total duration: ${total_dur}s"
else
  echo "Error: Failed to create final video"
fi
