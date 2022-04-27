@echo off
cls
setlocal enabledelayedexpansion
if "%~1"=="" (
  echo Please bring the video's path after the command...
  echo;
  echo Example:
  echo;
  echo %cd%^>realsr-rife "D:\\path\to\video.mkv"
  goto :eof
)
:agre
cls
echo This script requires some software that might be downloaded separately from their own sources.
echo This script doesn't include and doesn't instent to claim or garantee the work of any of the other tools nor they output and errors.
echo By continuing you declare your positive agreement to the messages described before.
echo;
set /p "pagree=Continue? (y/n): "
cls
if "%pagree%"=="n" (
  color
  goto :eof
)
if "%pagree%"=="y" (
  color
  goto :maxs
) else (
  color 4
  goto :agre
)

:maxs
cls
echo Select the maximum output size of the video by using the number of the list ^(the size is inclusive, based on the largest side^):
echo;
echo 0 HD ^(1280x720^)
echo 1 FHD ^(1920x1080^)
echo 2 WQHD ^(2560x1440^)
echo 3 UHD1 ^(3840x2160^)
echo 4 5K ^(5120x2880^)
echo 5 UHD2 ^(7680x4320^)
echo;
set /p "psize=Number (default: 3): "
if "%psize%"=="5" (
  set /a "ssize=7680*10000"
) else (
  set /a "ssize=3840*10000"
)
if "%psize%"=="4" (
  set /a "ssize=5120*10000"
)
if "%psize%"=="3" (
  set /a "ssize=3840*10000"
)
if "%psize%"=="2" (
  set /a "ssize=2560*10000"
)
if "%psize%"=="1" (
  set /a "ssize=1920*10000"
)
if "%psize%"=="0" (
  set /a "ssize=1280*10000"
)

:maxf
cls
echo Select the maximum output framerate of the video by using the number of the list ^(the framerate is inclusive^):
echo;
echo 0 60fps
echo 1 120fps
echo 2 240fps
echo;
set /p "pframerate=Number (default: 0): "
if "%pframerate%"=="2" (
  set /a "sframerate=240*10000"
) else (
  set /a "sframerate=60*10000"
)
if "%pframerate%"=="1" (
  set /a "sframerate=120*10000"
)
if "%pframerate%"=="0" (
  set /a "sframerate=60*10000"
)

:sete
cls
echo Select codec ^(encoder^) for video ^(audio can not be changed^):
echo;
echo 0 h264 ^(CPU^)
echo 1 hevc ^(CPU^)
echo 2 h264 ^(GPU AMD^)
echo 3 hevc ^(GPU AMD^)
echo 4 h264 ^(GPU NVIDIA^)
echo 5 hevc ^(GPU NVIDIA^)
echo;
set /p "pencoder=Number (default: 1): "
if "%pencoder%"=="5" (
  set "sencoder=hevc_nvenc"
  set "scodec=hevc"
) else (
  set "sencoder=libx265"
  set "scodec=hevc"
)
if "%pencoder%"=="4" (
  set "sencoder=h264_nvenc"
  set "scodec=h264"
)
if "%pencoder%"=="3" (
  set "sencoder=hevc_amf"
  set "scodec=hevc"
)
if "%pencoder%"=="2" (
  set "sencoder=h264_amf"
  set "scodec=h264"
)
if "%pencoder%"=="1" (
  set "sencoder=libx265"
  set "scodec=hevc"
)
if "%pencoder%"=="0" (
  set "sencoder=libx264"
  set "scodec=h264"
)

:prep
cls
set "input=%~1"
set "idisk=%~d1"
set "ipath=%~p1"
set "iname=%~n1"
set "iextension=%~x1"
set "sworkspace=%idisk%%ipath%.enhance\%iname%"
mkdir "%sworkspace%" 2>nil
ffprobe.exe -v error -select_streams v:0 -show_entries stream=width,height,r_frame_rate,codec_name -of csv=p=0 "%input%" > "%sworkspace%\attributes.txt"
set /p iattributes=<"%sworkspace%\attributes.txt"
for /f "tokens=1,2,3,4 delims=," %%a in ("%iattributes%") do (
  set "icodec=%%a"
  set "iwidth=%%b"
  set "iheight=%%c"
  set "iframeratefraction=%%d"
)
if %iwidth% gtr %iheight% (
  set /a "isize=!iwidth!*10000"
) else (
  set /a "isize=!iheight!*10000"
)
for /f "tokens=1,2 delims=/" %%a in ("%iframeratefraction%") do (
  set "inumerator=%%a"
  set "idenominator=%%b"
)
set /a "iframerate=(%inumerator%*10000)/%idenominator%"
set /a "osize=%isize%"
set /a "owidth=%iwidth%"
set /a "oheight=%iheight%"
set "scount="
set /a "oframerate=%iframerate%"
set /a "fcount=0"
set /a "scale=4"

:cals
set /a "osize=%osize%*%scale%"
set /a "owidth=%owidth%*%scale%"
set /a "oheight=%oheight%*%scale%"
set "scount=%scount%%scale% "
echo;
if %osize% gtr %ssize% (
  set "scount=!scount:~0,-2!"
  set /a "osize=!osize!/!scale!"
  set /a "owidth=!owidth!/!scale!"
  set /a "oheight=!oheight!/!scale!"
  if !scale! gtr 2 (
    set /a "scale=!scale!-1"
    goto :cals
  )
) else (
  goto :cals
)
if not "%scount%"=="" (
  set "scount=%scount:~0,-1%"
)

:calf
set /a "oframerate=%oframerate%*2"
set /a "fcount=%fcount%+1"
if %oframerate% gtr %sframerate% (
  set /a "oframerate=%oframerate%/2"
  set /a "fcount=%fcount%-1"
) else (
  goto :calf
)

:tras
set "ssizewindowstrashy=              %ssize%"
set "isizewindowstrashy=              %isize%"
set "osizewindowstrashy=              %osize%"
set "sframeratewindowstrashy=         %sframerate%"
set "iframeratewindowstrashy=         %iframerate%"
set "oframeratewindowstrashy=         %oframerate%"
set "sencoderwindowstrashy=           %sencoder% (%scodec%)"
set "iencoderwindowstrashy=           (%icodec%)"
set "oencoderwindowstrashy=           %sencoder% (%scodec%)"

:suma
cls
echo NOTE: This process will use srmd-ncnn-vulkan one or more times usign scale sequenze of %scount% to increaze size and rife-ncnn-vulkan %fcount% times to increase frames.
echo Not always the maximun size/framerate selected will match the output size/framerate (software limitations).
echo The managed data an files will be store in the ".enhance" folder (which is the workspace) from the same folder as the video.
echo;
echo -----------------------------------------------------------------------
echo ^| Summary  ^| Size ^(on largest side^) ^|  Framerate  ^|  Encoder ^(codec^)  ^|
echo -----------------------------------------------------------------------
echo ^| Settings ^|                  %ssizewindowstrashy:~-8,4%p ^|  %sframeratewindowstrashy:~-7,-4%.%sframeratewindowstrashy:~-4,3%fps ^| %sencoderwindowstrashy:~-17,17% ^|
echo ^| Input    ^|                  %isizewindowstrashy:~-8,4%p ^|  %iframeratewindowstrashy:~-7,-4%.%iframeratewindowstrashy:~-4,3%fps ^| %iencoderwindowstrashy:~-17,17% ^|
echo ^| Output   ^|                  %osizewindowstrashy:~-8,4%p ^|  %oframeratewindowstrashy:~-7,-4%.%oframeratewindowstrashy:~-4,3%fps ^| %oencoderwindowstrashy:~-17,17% ^|
echo -----------------------------------------------------------------------
echo;
echo Workspace: %idisk%%ipath%.enhance
echo or
echo Workspace: %idisk%%ipath%.enhance\%iname%
echo;
echo Do you want to continue?
echo;
echo 0 Continue.
echo 1 Cancel and exit.
echo 2 Reset.
echo;
set /p "psummary=Number (default: 0): "
if "%psummary%"=="2" (
  set "psummary=0"
  goto :maxs
)
if "%psummary%"=="1" (
  color
  rmdir /s /q "%sworkspace%"
  goto :eof
) else (
  color
)

:init
cls
set "scalator=%scount: =_%srmd_models_srmd"
set "interpolator=%fcount%rife_rife_v3_1"
set "osufix=%scalator% %interpolator%"

:extr
mkdir "%sworkspace%\input" 2>> "%sworkspace%\log.txt"
ffmpeg -v error -y -i "%input%" -start_number 0 "%sworkspace%\input\%%6d.png"
ffmpeg -v error -y -i "%input%" -start_number 0 -f matroska -vn -acodec copy "%sworkspace%\a.mkv"
ffprobe.exe -v error -show_entries format_tags=title -of csv=p=0:e=none "%input%" > "%sworkspace%\title.txt"
ffprobe.exe -v error -show_entries format_tags=artist -of csv=p=0:e=none "%input%" > "%sworkspace%\artist.txt"
ffprobe.exe -v error -show_entries format_tags=date -of csv=p=0:e=none "%input%" > "%sworkspace%\date.txt"
ffprobe.exe -v error -show_entries format_tags=description -of csv=p=0:e=none "%input%" > "%sworkspace%\description.txt"
ffprobe.exe -v error -show_entries format_tags=comment -of csv=p=0:e=none "%input%" > "%sworkspace%\comment.txt"
ffprobe.exe -v error -show_entries format_tags=purl -of csv=p=0:e=none "%input%" > "%sworkspace%\purl.txt"
echo ;FFMETADATA1> "%sworkspace%\metadata.txt"
set "first=true"
set /a "lines=0"
for /f "delims=" %%s in ('findstr /n /r "^.*$" "%sworkspace%\title.txt"') do (
  set /a "lines=!lines!+1"
)
for /f "delims=" %%s in ('findstr /n /r "^.*$" "%sworkspace%\title.txt"') do (
  set /a "lines=!lines!-1"
  set "t=%%~s"
  set "t=!t:#=\#!"
  set "t=!t:*:=!"
  if !lines! gtr 0 (
    set "t=!t!\"
  )
  if "!first!"=="true" (
    echo TITLE=!t!>> "%sworkspace%\metadata.txt"
    set "first=false"
  ) else (
    echo !t!>> "%sworkspace%\metadata.txt"
  )
)
set "first=true"
set /a "lines=0"
for /f "delims=" %%s in ('findstr /n /r "^.*$" "%sworkspace%\artist.txt"') do (
  set /a "lines=!lines!+1"
)
for /f "delims=" %%s in ('findstr /n /r "^.*$" "%sworkspace%\artist.txt"') do (
  set /a "lines=!lines!-1"
  set "t=%%~s"
  set "t=!t:#=\#!"
  set "t=!t:*:=!"
  if !lines! gtr 0 (
    set "t=!t!\"
  )
  if "!first!"=="true" (
    echo ARTIST=!t!>> "%sworkspace%\metadata.txt"
    set "first=false"
  ) else (
    echo !t!>> "%sworkspace%\metadata.txt"
  )
)
set "first=true"
set /a "lines=0"
for /f "delims=" %%s in ('findstr /n /r "^.*$" "%sworkspace%\date.txt"') do (
  set /a "lines=!lines!+1"
)
for /f "delims=" %%s in ('findstr /n /r "^.*$" "%sworkspace%\date.txt"') do (
  set /a "lines=!lines!-1"
  set "t=%%~s"
  set "t=!t:#=\#!"
  set "t=!t:*:=!"
  if !lines! gtr 0 (
    set "t=!t!\"
  )
  if "!first!"=="true" (
    echo DATE=!t!>> "%sworkspace%\metadata.txt"
    set "first=false"
  ) else (
    echo !t!>> "%sworkspace%\metadata.txt"
  )
)
set "first=true"
set /a "lines=0"
for /f "delims=" %%s in ('findstr /n /r "^.*$" "%sworkspace%\description.txt"') do (
  set /a "lines=!lines!+1"
)
for /f "delims=" %%s in ('findstr /n /r "^.*$" "%sworkspace%\description.txt"') do (
  set /a "lines=!lines!-1"
  set "t=%%~s"
  set "t=!t:#=\#!"
  set "t=!t:*:=!"
  if !lines! gtr 0 (
    set "t=!t!\"
  )
  if "!first!"=="true" (
    echo DESCRIPTION=!t!>> "%sworkspace%\metadata.txt"
    set "first=false"
  ) else (
    echo !t!>> "%sworkspace%\metadata.txt"
  )
)
set "first=true"
set /a "lines=0"
for /f "delims=" %%s in ('findstr /n /r "^.*$" "%sworkspace%\comment.txt"') do (
  set /a "lines=!lines!+1"
)
for /f "delims=" %%s in ('findstr /n /r "^.*$" "%sworkspace%\comment.txt"') do (
  set /a "lines=!lines!-1"
  set "t=%%~s"
  set "t=!t:#=\#!"
  set "t=!t:*:=!"
  if !lines! gtr 0 (
    set "t=!t!\"
  )
  if "!first!"=="true" (
    echo COMMENT=!t!>> "%sworkspace%\metadata.txt"
    set "first=false"
  ) else (
    echo !t!>> "%sworkspace%\metadata.txt"
  )
)
set "first=true"
set /a "lines=0"
for /f "delims=" %%s in ('findstr /n /r "^.*$" "%sworkspace%\purl.txt"') do (
  set /a "lines=!lines!+1"
)
for /f "delims=" %%s in ('findstr /n /r "^.*$" "%sworkspace%\purl.txt"') do (
  set /a "lines=!lines!-1"
  set "t=%%~s"
  set "t=!t:#=\#!"
  set "t=!t:*:=!"
  if !lines! gtr 0 (
    set "t=!t!\"
  )
  if "!first!"=="true" (
    echo PURL=!t!>> "%sworkspace%\metadata.txt"
    set "first=false"
  ) else (
    echo !t!>> "%sworkspace%\metadata.txt"
  )
)
dos2unix "%sworkspace%\metadata.txt"
for %%a in (%scount%) do (
  call :besc "%%~a"
)
goto :bint

:besc
set "scale=%~1"
set /a "greaterscale=%scale%+1"
if exist "%sworkspace%\scaled%greaterscale%0\000000.png" (
  mkdir "%sworkspace%\scaled%scale%0"
  srmd-ncnn-vulkan.exe -v -s "%scale%" -n 0 -m "models-srmd" -i "%sworkspace%\scaled%greaterscale%0" -o "%sworkspace%\scaled%scale%0"
) else (
  set /a "greaterscale=%greaterscale%+1"
  if exist "%sworkspace%\scaled!greaterscale!0\000000.png" (
    mkdir "%sworkspace%\scaled%scale%0"
    srmd-ncnn-vulkan.exe -v -s "%scale%" -n 0 -m "models-srmd" -i "%sworkspace%\scaled!greaterscale!0" -o "%sworkspace%\scaled%scale%0"
  ) else (
    if exist "%sworkspace%\scaled%scale%0\000000.png" (
      move /y "%sworkspace%\scaled%scale%0" "%sworkspace%\scaled%scale%1"
      mkdir "%sworkspace%\scaled%scale%0"
      srmd-ncnn-vulkan.exe -v -s "%scale%" -n 0 -m "models-srmd" -i "%sworkspace%\scaled%scale%1" -o "%sworkspace%\scaled%scale%0"
    ) else (
      mkdir "%sworkspace%\scaled%scale%0"
      srmd-ncnn-vulkan.exe -v -s "%scale%" -n 0 -m "models-srmd" -i "%sworkspace%\input" -o "%sworkspace%\scaled%scale%0"
    )
  )
)
goto :eof

:bint
set /a "fcountaux=%fcount%+1"
if %fcount% gtr 0 (
  if exist "%sworkspace%\interpolated%fcountaux%\000001.png" (
    mkdir "%sworkspace%\interpolated%fcount%" 2>> "%sworkspace%\log.txt"
    rife-ncnn-vulkan.exe -v -u -j "1:1:1" -m "rife-v3.1" -f "%%06d.png" -i "%sworkspace%\interpolated%fcountaux%" -o "%sworkspace%\interpolated%fcount%"
  ) else (
    mkdir "%sworkspace%\interpolated%fcount%" 2>> "%sworkspace%\log.txt"
    rife-ncnn-vulkan.exe -v -u -j "1:1:1" -m "rife-v3.1" -f "%%06d.png" -i "%sworkspace%\scaled%scount:~-1,1%0" -o "%sworkspace%\interpolated%fcount%"
  )
  set /a "fcount=%fcount%-1"
  goto :bint
) else (
  if not exist "%sworkspace%\interpolated%fcountaux%\000001.png" (
    mkdir "%sworkspace%\interpolated%fcount%" 2>> "%sworkspace%\log.txt"
    pause
    copy /y "%sworkspace%\scaled%scount:~-1,1%0\*" "%sworkspace%\interpolated%fcount%"
  ) else (
    mkdir "%sworkspace%\interpolated%fcount%" 2>> "%sworkspace%\log.txt"
    copy /y "%sworkspace%\interpolated%fcountaux%\*" "%sworkspace%\interpolated%fcount%"
  )
)

:merg
if exist "%sworkspace%\a.mkv" (
  ffmpeg -y -f ffmetadata -r "%oframerate:~0,-4%.%oframerate:~-4,3%" -i "%sworkspace%\metadata.txt" -f matroska -r "%oframerate:~0,-4%.%oframerate:~-4,3%" -i "%sworkspace%\a.mkv" -f image2 -start_number 0 -r "%oframerate:~0,-4%.%oframerate:~-4,3%" -i "%sworkspace%\interpolated0\%%6d.png" -start_number 0 -c:v %sencoder% -gops_per_idr 1 -g 1 -crf 32 -qp_i 21 -qp_p 21 -c:a copy -map_metadata:s -1 -map_metadata 0 -r "%oframerate:~0,-4%.%oframerate:~-4,3%" -f matroska "%idisk%%ipath%%iname% %sencoder% %osufix%.mkv"
) else (
  ffmpeg -y -f ffmetadata -r "%oframerate:~0,-4%.%oframerate:~-4,3%" -i "%sworkspace%\metadata.txt" -f image2 -start_number 0 -r "%oframerate:~0,-4%.%oframerate:~-4,3%" -i "%sworkspace%\interpolated0\%%6d.png" -start_number 0 -c:v %sencoder% -gops_per_idr 1 -g 1 -crf 21 -qp_i 21 -qp_p 21 -map_metadata:s -1 -map_metadata 0 -r "%oframerate:~0,-4%.%oframerate:~-4,3%" -f matroska "%idisk%%ipath%%iname% %sencoder% %osufix%.mkv"
)

:fini
set /p "pdelete=Delete frame files? y/n (default: n): "
cls
if "%pdelete%"=="y" (
  rmdir /s /q "%sworkspace%"
)
endlocal