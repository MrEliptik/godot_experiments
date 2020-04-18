import os
import argparse
from PIL import Image

from frames_to_animatedTexture import frames_to_tres

parser = argparse.ArgumentParser(
        description='Convert GIF into frames and then create '
                    'AnimatedTexture .tres')
parser.add_argument('gif', help='GIF to process')
args = parser.parse_args()

name = os.path.splitext(args.gif)[0]

frames = []

# Break GIF into PNG frames.
with Image.open(args.gif) as im:
    fps = 1 / (im.info['duration'] / 1000.)
    n_frames = im.n_frames

    for i in range(n_frames):
        im.seek(i)
        fn = '{}-{}.png'.format(name, i)
        im.save(fn)
        frames.append(fn)