#!/usr/bin/env bash

for original in $(find $1 -type f -name "*.mp3")
do
  mv $original "$original.tmp.mp3"
  ffmpeg -i "$original.tmp.mp3" -ab 48k $original
  rm "$original.tmp.mp3"
  if [[ $(find $original -type f -size +20000000c 2>/dev/null) ]]
  then
      echo "WARN: $original > 20MB"
  fi
done
