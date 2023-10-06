#!/bin/bash

# Check if the user provided a filename argument
if [ $# -eq 0 ]; then
  echo "Usage: $0 <filename.zig>"
  exit 1
fi

# Get the filename from the first command-line argument
filename="$1"

# Check if the file exists in the current directory
if [ -f "$filename" ]; then
  # Compile the Zig file
  zig build-exe "$filename"

  # Get the name of the Zig file without the file extension
  filename_without_extension="${filename%.zig}"

  # Run the compiled executable
  "./$filename_without_extension"
  
  # Remove the executable file

  rm -f "$filename_without_extension"
  rm -f "$filename_without_extension".o


else
  # Search for the file in directories listed in PATH
  found_file=""
  IFS=":" read -ra dirs_in_path <<< "$PATH"
  for dir in "${dirs_in_path[@]}"; do
    if [ -f "$dir/$filename" ]; then
      found_file="$dir/$filename"
      break
    fi
  done

  if [ -n "$found_file" ]; then
    # Compile the found Zig file
    zig build-exe "$found_file"

    # Get the name of the Zig file without the file extension
    filename_without_extension="$(basename "$found_file" .zig)"

    # Run the compiled executable
    "$filename_without_extension"

    # Remove the executable file
    rm -f "$filename_without_extension"
    rm -f "$filename_without_extension".o


  else
    echo "Error: File '$filename' not found in current directory or in PATH directories."
    exit 1
  fi
fi
