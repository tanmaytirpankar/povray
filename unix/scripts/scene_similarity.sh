#!/bin/sh

PROJECT_ROOT="$1"

# Assuming the original Povray is already built and installed in build_original
# Building and installing the modified povray
cd "$(dirname "$0")/../build_modified"
if [[ -n "$1" && $1 = build_modified ]]; then
  make clean && make -j12 && make install
fi

# Move to the scripts parent directory
cd "$(dirname "$0")"

# Running the original povray to generate scenes in build_original/output_scene
PATH=/home/tanmay/Documents/Tools/povray/build_original/bin:$PATH
# Remove remnants of previous runs and render new output scene in build_original/output_scene
rm -rf ../build_original/output_scene
mkdir ../build_original/output_scene
./render_scene.sh ../build_original/output_scene ../build_original/share/povray-3.7/scenes/textures/finishes/arches.pov

# Running the modified povray to generate scenes in build_modified/output_scene
PATH=/home/tanmay/Documents/Tools/povray/build_modified/bin:$PATH
# Remove remnants of previous runs and render new output scene in build_modified/output_scene
rm -rf ../build_modified/output_scene
mkdir ../build_modified/output_scene
./render_scene.sh ../build_modified/output_scene ../build_modified/share/povray-3.7/scenes/textures/finishes/arches.pov

# Comparing the scenes using ImageMagick
# Remove remnants of previous runs and render new output scene in diff_scene
rm -rf ../diff_scene
mkdir ../diff_scene
magick compare -metric SSIM ../build_original/output_scene/arches.png ../build_modified/output_scene/arches.png ../diff_scene/arches.png