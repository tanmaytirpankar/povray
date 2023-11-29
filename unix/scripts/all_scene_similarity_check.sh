#!/bin/sh

# Assuming the original Povray is already built and installed in build_original
# Building and installing the modified povray
if [[ -n "$1" && $1 = build_modified ]]; then
  cd "$(dirname "$0")/../build_modified"
  make clean && make -j12 && make install

  # Move to the scripts parent directory
  cd "$(dirname "$0")"

  # Running the modified povray to generate all scenes in build_modified/output_scene
  PATH=/home/tanmay/Documents/Tools/povray/build_modified/bin:$PATH
  rm -rf ../build_modified/output_scene
  mkdir ../build_modified/output_scene
  ./allscene.sh -o ../build_modified/output_scene
fi

# Move to the scripts parent directory
cd "$(dirname "$0")"

# Running the original povray to generate all scenes in build_original/output_scene
#PATH=/home/tanmay/Documents/Tools/povray/build_original/bin:$PATH
#rm -rf ../build_original/output_scene
#mkdir ../build_original/output_scene
#./allscene.sh -o ../build_original/output_scene

# Comparing the scenes using ImageMagick
# Remove remnants of previous runs and render new output scene in diff_scene
rm -rf ../diff_scene
mkdir ../diff_scene

# Run ImageMagick on corresponding scence files in ../build_original/output_scene and ../build_modified/output_scene
# and store the difference in ../diff_scene
for file in ../build_original/output_scene/*.png; do
  # Takes the basename: ../build_original/output_scene/file.png -> file.png
  filename=$(basename -- "$file")
  # Takes the filename without extension: file.png -> file
  filename="${filename%.*}"

  # Compare the two images and store the difference in ../diff_scene
  similarity=$(magick compare -metric SSIM ../build_original/output_scene/$filename.png ../build_modified/output_scene/$filename.png ../diff_scene/$filename.png 2>&1)
  if [[ $similarity < 0.95 ]]; then
    echo $filename": "$similarity
  fi
done