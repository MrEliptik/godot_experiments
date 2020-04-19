import os
import argparse
from PIL import Image
import cv2 as cv

from frames_to_animatedTexture import framesToTres

# Limit imposed by AnimatedTexture in godot
MAX_FRAMES = 256

video_extension = ['.mp4', '.mov', '.webm', '.mkv', '.ogv']

def extractFromGIF(gif):
    frames = []

    # Break GIF into PNG frames.
    with Image.open(args.gif) as im:
        fps = 1 / (im.info['duration'] / 1000.)
        n_frames = im.n_frames

        for i in range(n_frames):
            im.seek(i)
            frames.append(im)

    return frames

def extractFromVideo(video):
    frames = []

    # Break video into frames
    videocap = cv.VideoCapture(video)
    success, frame = videocap.read()
    count = 0
    while success:
        frames.append(frame)

        if count == MAX_FRAMES: break 
        success, frame = videocap.read()
        count += 1

    return frames

def saveFramesToDisk(frames, path, name, image_format):
    for (i, frame) in enumerate(frames):
        cv.imwrite(os.path.join(path, name, '_{}{}'.format(i, image_format)), frame)

def main(input, output_frames, output_texture, fps, image_format):
    name, ext = os.path.splitext(input)
    print(name, ext)

    if ext in video_extension:
        frames = extractFromVideo(input)
    else:
        frames = extractFromVideo(input)

    saveFramesToDisk(frames, output_frames, 'frame', image_format)

    frames_str = os.listdir(output_frames)
    frames_str = [f.lower() for f in frames_str if f.endswith('.jpeg')]
    sorted(frames_str)

    name, ext = os.path.splitext(input)
    if ext == "": output_texture = os.path.join(name, '.tres')
    framesToTres(frames_str, fps, output_texture)
    


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='Convert GIF or videos into frames and then create '
                    'AnimatedTexture .tres')
    parser.add_argument('--input', type=str, help='path to input (video/gif)')
    parser.add_argument('--output_frames_path', type=str, help='name and path of the AnimatedTexture file generated')
    parser.add_argument('--output_texture_path', type=str, help='name and path of the AnimatedTexture file generated')
    parser.add_argument('--fps', type=int, help='fps target of the AnimatedTexture')
    parser.add_argument('--image_format', choices=['.jpeg', '.jpg', '.png', '.bmp'], type=str, required=False, default='.jpeg', 
        help='frames image format [\'.jpeg\', \'.png\', \'.bmp\']')
    args = parser.parse_args()

    main(args.input, args.output_frames_path, agrs.output_texture_path, args.fps, args.image_format)