#!/usr/bin/env bash

for original in $(find $1 -type f -name "*.mp3")
do
  mv $original "$original.tmp.mp3"
  ffmpeg -i "$original.tmp.mp3" -ab 64k $original
  rm "$original.tmp.mp3"
done
