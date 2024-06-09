#!/bin/bash
# This script packages modules into artifacts

[ -n "$1" ] || {
  echo "No base directory specified. Usage: $(basename "${0}") <base_directory>"
  exit 1
}

echo "WARNING: This script will clean all gitignored files in the modules directory, including plans and states"
echo "Abort if necessary, you have 5s !"
sleep 5

SUBDIRECTORY="$1"
CURRENT_PATH="$PWD"

rm -Rf /tmp/"$SUBDIRECTORY"
rm -Rf "$CURRENT_PATH"/artifacts
mkdir -p "$CURRENT_PATH"/artifacts
cd "$CURRENT_PATH"/"$SUBDIRECTORY"
git clean -Xdf

cp -R "$CURRENT_PATH"/"$SUBDIRECTORY" /tmp/"$SUBDIRECTORY"
cd /tmp/"$SUBDIRECTORY"

for dir in *; do
  echo "DIR: $dir"
  cd "$dir"
  tar -cvzf /tmp/"${dir}".tgz --exclude=./.git .
  cp /tmp/"${dir}".tgz "$CURRENT_PATH"/artifacts/"${dir}".tgz
  cd ../
done
