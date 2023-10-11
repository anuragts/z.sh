#!/bin/bash

# Detect the operating system
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Linux
  BUILD_COMMAND="zig build-exe"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
  # Windows (MSYS2 or Cygwin)
  BUILD_COMMAND="zig build"
else
  echo "Error: Unsupported operating system."
  exit 1
fi

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
  $BUILD_COMMAND "$filename"

  # Get the name of the Zig file without the file extension
  filename_without_extension="${filename%.zig}"

  # Run the compiled executable
  "./$filename_without_extension"

  # Check the exit status of the program
  if [ $? -eq 0 ]; then
    # Remove the executable and object file
    rm -f "$filename_without_extension"
    rm -f "$filename_without_extension.o"
  else
    echo "Program execution failed."
    exit 1
  fi

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
    $BUILD_COMMAND "$found_file"

    # Get the name of the Zig file without the file extension
    filename_without_extension="$(basename "$found_file" .zig)"

    # Run the compiled executable
    "$filename_without_extension"

    # Check the exit status of the program
    if [ $? -eq 0 ]; then
      # Remove the executable and object file
      rm -f "$filename_without_extension"
      rm -f "$filename_without_extension.o"
    else
      echo "Program execution failed."
      exit 1
    fi

  else
    echo "Error: File '$filename' not found in the current directory or in PATH directories."
    exit 1
  fi
fi
