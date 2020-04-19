import os


def framesToTres(frames, fps, output_file):
    f = open(output_file, 'a')

    f.write("[gd_resource type=\"AnimatedTexture\" load_steps={} format=2]\n\n".format(len(frames)+1))

    for (i, frame) in enumerate(frames):
        f.write("[ext_resource path=\"res://media/frames/{}\" type=\"Texture\" id={}]\n".format(frame, i+1))

    #flags ?
    f.write("\n[resource]\nframes = {}\nfps = {}\n".format(len(frames), fps))

    for (i, frame) in enumerate(frames):
        if i == 0:
            f.write("frame_{}/texture = ExtResource({})\n".format(i, i+1))
            continue

        f.write("frame_{}/texture = ExtResource( {} )\nframe_{}/delay_sec = 0.0\n".format(i, i+1, i))
        
    f.close()

def main():
    path = "C:\\Users\\Victor\\Documents\\dev\\godot_experiments\\3D\\tv\\media\\frames"
    output_name = "C:\\Users\\Victor\\Documents\\dev\\godot_experiments\\3D\\tv\\video.tres"
    fps = 24

    frames = os.listdir(path)
    frames = [f.lower() for f in frames if f.endswith('.jpeg')]
    sorted(frames)

    framesToTres(frames, fps, output_name)

if __name__ == "__main__":
    main()