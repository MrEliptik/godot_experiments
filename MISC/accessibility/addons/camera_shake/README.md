# Godot Camera Shake
A simple camera shake system based on the [GDC talk by SMU Guildhall's Squirrel Eiserloh](https://www.youtube.com/watch?v=tu-Qe66AvtY&list=WL&index=18&t=968s&ab_channel=GDC).

## How it works.

The camera script has a stress value that determines the level of camera shake (shake = stress ^ 2). The stress value is clamped between 0 and 1. The shake is based on a max value, the shake variable and a simplex noise sample.

