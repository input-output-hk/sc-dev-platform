#!/bin/bash

file="../infra/kube.config"
hash_file="$file.md5"

# Generate MD5 hash for the file
md5 "$file" > "$hash_file"

# Check if the file has changed
if md5 -c "$hash_file" --status; then
  echo "File has not changed."
else
  echo "File has changed."
fi