# multimedia-enhance-scripts
Some of the scripts I want to share, which I use to enhance videos or other multimedia files with third party software (not included here).
## Features
The scripts use third party software to enhance multimedia files, the features vary on thirdparty but them can be:
1. Choose an approx. output's resolution for video.
2. Choose an approx. output's framerate for video.
3. Choose output's encoder for video (only h264(AV1) and h265(HEVC) codecs).
## Installation
The scripts require `ffmpeg`, `ffprobe`, `dos2unix`, `rife-ncnn-vulkan`, `realsr-ncnn-vulkan` and `srmd-ncnn-vulkan` added to the system's variable `PATH`.
1. Clone this repository and add it's directory to the system's varible `PATH`.
2. Install the required tools, you can place them all (and their stuff) inside the repository's directory.
```
/multimedia-enhance-scripts
  realsr-rife.cmd
  srmd-rife.cmd
  ffmpeg.exe
  ffprobe.exe
  dos2unix.exe
  rife-ncnn-vulkan
  realsr-ncnn-vulkan
  srmd-ncnn-vulkan
  etc...
```
## How to use
Call the scripts adding the video's path and follow the script's instructions.
Depending the AI to use, it could be:
```cmd
realsr-rife "D:\path\to\video.mkv"
```
or
```cmd
srmd-rife "D:\path\to\video.mkv"
```
It should interactively prompt some stuff, or error message asking for the file if the file's path is omited.
## Prompt examples:
Error for missing video's path:
```
Please bring the video's path after the command...

Example:

C:\Users\User>realsr-rife "D:\\path\to\video.mkv"
```
Approximate resolution size selection:
```
Select the maximum output size of the video by using the number of the list (the size is inclusive, based on the largest
side):

0 HD (1280x720)
1 FHD (1920x1080)
2 WQHD (2560x1440)
3 UHD1 (3840x2160)
4 5K (5120x2880)
5 UHD2 (7680x4320)

Number (default: 3):
```
Approximate frame rate selection:
```
Select the maximum output framerate of the video by using the number of the list (the framerate is inclusive):

0 60fps
1 120fps
2 240fps

Number (default: 0):
```
Encoder selection:
```
Select codec (encoder) for video (audio can not be changed):

0 h264 (CPU)
1 hevc (CPU)
2 h264 (GPU AMD)
3 hevc (GPU AMD)
4 h264 (GPU NVIDIA)
5 hevc (GPU NVIDIA)

Number (default: 1):
```
Summary prompt:
```
NOTE: This process will use realsr-ncnn-vulkan 1 times to increaze size and rife-ncnn-vulkan 1 times to increase frames.
Not always the maximun size/framerate selected will match the output size/framerate (software limitations).
The managed data an files will be store in the ".enhance" folder (which is the workspace) from the same folder as the video.

-----------------------------------------------------------------------
| Summary  | Size (on largest side) |  Framerate  |  Encoder (codec)  |
-----------------------------------------------------------------------
| Settings |                  3840p |   60.000fps |    libx265 (hevc) |
| Input    |                   854p |   25.000fps |            (h264) |
| Output   |                  3416p |   50.000fps |    libx265 (hevc) |
-----------------------------------------------------------------------

Workspace: D:\example\.enhance
or
Workspace: D:\example\.enhance\video

Do you want to continue?

0 Continue.
1 Cancel and exit.
2 Reset.

Number (default: 0):
```
## License
The script's code shared on this repository is shared under [The Unlicense](https://unlicense.org) license.
