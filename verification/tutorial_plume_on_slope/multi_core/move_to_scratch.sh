#!/bin/bash

directory=""

while getopts "d:" opt; do
  case "$opt" in
    d)
      directory="$OPTARG"
      ;;
    *)
      echo "Usage: $0 -d <directory>"
      exit 1
      ;;
  esac
done

if [[ -z "$directory" ]]; then
  echo "Error: -d is required."
  echo "Usage: $0 -d <directory>"
  exit 1
fi

pwd
echo "Creating directory: scratch/jlf1g19/$directory"
mkdir ~/../../scratch/jlf1g19/"$directory"
mv run/* $_
echo "Moved contents of run/"