# TV

## Video scene

Display a video in a Viewport. The Viewport is then used as a texture for the mesh.

## Animated texture scene

Careful, there's a 256 frames limit! This is roughly 10 seconds at 24 fps.

## CRT TV shader

Same as video scene. *TODO: CRT shader*

## FFMPEG conversion

Trim original video to 30sec video

    ffmpeg -ss 00:00:00 -i big_buck_bunny_720p_stereo.ogv -to 00:00:10 -c copy big_buck_bunny_short.ogv

Convert shot video to frames

    ffmpeg -r 1 -i big_buck_bunny_short.ogv -r 1 "frames/$filename%03d.jpeg"

Extract audio from video

    ffmpeg -i big_buck_bunny_short.ogv -vn -acodec copy big_buck_bunny_audio.ogg


## Download Big Buck Bunny

[https://peach.blender.org/download/](https://peach.blender.org/download/)