#!/bin/bash
# Combine audio files per slide

AUDIO_DIR="audio"
OUTPUT_DIR="audio-combined"

mkdir -p "$OUTPUT_DIR"

for i in $(seq 1 33); do
  slide_num=$(printf '%02d' $i)
  input_files=$(ls -v $AUDIO_DIR/slide-${slide_num}-*.mp3 2>/dev/null)
  
  if [ -n "$input_files" ]; then
    echo "Combining slide $i..."
    
    # Create file list for ffmpeg concat
    > /tmp/filelist_${slide_num}.txt
    for f in $input_files; do
      echo "file '$(pwd)/$f'" >> /tmp/filelist_${slide_num}.txt
    done
    
    # Concat with ffmpeg
    ffmpeg -y -f concat -safe 0 -i /tmp/filelist_${slide_num}.txt \
      -c:a libmp3lame -q:a 2 "$OUTPUT_DIR/slide-${slide_num}.mp3" 2>/dev/null
  else
    echo "No audio for slide $i"
  fi
done

echo "Done! Combined audio files in $OUTPUT_DIR/"
