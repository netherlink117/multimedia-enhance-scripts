@echo off
cls
setlocal enabledelayedexpansion
echo Process started at %TIME%...
echo;
@REM Where .enhance files will be created, by default same path of origin video + video name as subfolder
set "workspace=null"
@REM Where Video will be created, by default same path of origin video
set "outputpath=null"
cd /d "%workspace%"
set "fint=0"
set "fesc=0"
set "nint=0"
set "nesc=0"
set "origin=null"
set "aux=0"
set "colorbalance=0"
set "na=0"
set "mer=0"
set "cons=55"
:loopagrs
set "aux=0"
if "%~1"=="" (
  goto :endloopargs
)
if "%~1"=="-i" (
  set "fint=1"
  set "aux=1"
)
if "%~1"=="-s" (
  set "fesc=1"
  set "aux=1"
)
if "%~1"=="-ni" (
  set "nint=1"
  set "aux=1"
)
if "%~1"=="-ns" (
  set "nesc=1"
  set "aux=1"
)
if "%~1"=="-cbs" (
  set "colorbalance=1"
  set "aux=1"
)
if "%~1"=="-cbm" (
  set "colorbalance=2"
  set "aux=1"
)
if "%~1"=="-cbh" (
  set "colorbalance=3"
  set "aux=1"
)
if "%~1"=="-cbsm" (
  set "colorbalance=12"
  set "aux=1"
)
if "%~1"=="-cbms" (
  set "colorbalance=12"
  set "aux=1"
)
if "%~1"=="-cbsh" (
  set "colorbalance=13"
  set "aux=1"
)
if "%~1"=="-cbhs" (
  set "colorbalance=13"
  set "aux=1"
)
if "%~1"=="-cbmh" (
  set "colorbalance=23"
  set "aux=1"
)
if "%~1"=="-cbhm" (
  set "colorbalance=23"
  set "aux=1"
)
if "%~1"=="-cb" (
  set "colorbalance=123"
  set "aux=1"
)
if "%~1"=="-na" (
  set "na=1"
  set "aux=1"
)
if "%~1"=="-merge" (
  set "mer=1"
  set "aux=1"
)
if "%~1"=="-ulc" (
  set "cons=7"
  set "aux=1"
)
if "%~1"=="-lc" (
  set "cons=13"
  set "aux=1"
)
if "%~1"=="-mc" (
  set "cons=55"
  set "aux=1"
)
if "%~1"=="-hc" (
  set "cons=77"
  set "aux=1"
)
if "%~1"=="-uhc" (
  set "cons=88"
  set "aux=1"
)
if "%aux%"=="0" (
  set "origin=%~1"
)
shift
goto :loopagrs
:endloopargs
for %%o in ("%origin%") do (
  set "fd=%%~do"
  set "fp=%%~po"
  set "fn=%%~no"
  set "fx=%%~xo"
)
if "%workspace%"=="null" (
  set "workspace=%fd%%fp%.enhance"
) else (
  set "workspace=%workspace%\.enhance"
)
if "%outputpath%"=="null" (
  set "outputpath=%fd%%fp%"
) else (
  set "outputpath=%outputpath%"
)
set "workspace=%workspace%\%fn%"
echo Creating workspace...
mkdir "%workspace%"
echo;
echo Getting resolution and framerate (if posible) from origin media...
ffprobe.exe -v error -select_streams v:0 -show_entries stream=width,height,r_frame_rate -of csv=p=0 "%origin%" > "%workspace%\origin.txt"
set /p originsizes=<"%workspace%\origin.txt"
for /f "tokens=1,2,3 delims=," %%a in ("%originsizes%") do (
  set "originwidth=%%a"
  set "originheight=%%b"
  set "originfps=%%c"
)
echo Original resolution: %originwidth%x%originheight%
for /f "tokens=1,2 delims=/" %%a in ("%originfps%") do (
  set "numerator=%%a"
  set "denominator=%%b"
)
set /a "originfps=%numerator%000/%denominator%"
echo Original frame rate: %originfps:~0,-3%.%originfps:~-3%
echo;
echo Calculating resolution and frame rate for enhanced media...
set /a "uhdp=2160*3840"
if %originwidth% gtr %originheight% (
  set /a "mscale=384000000/%originwidth%"
  set "maxsize=%originwidth%"
) else (
  set /a "mscale=384000000/%originheight%"
  set "maxsize=%originheight%"
)
set /a "scale=%mscale%/1000"
:res
set /a "outputwidth=(%originwidth%*%scale%)/100"
set /a "outputheight=(%originheight%*%scale%)/100"
set /a "outputp=%outputwidth%*%outputheight%"
if %outputp% gtr %uhdp% (
  set /a "scale=%scale%-1"
  goto :res
)
set "scalator=noscaled"
if %scale% gtr 100 (
  echo Scaled resolution: %outputwidth%x%outputheight% ^(%scale%%%^) %scale:~0,-2%.%scale:~-2%
  if "%nesc%"=="1" ( 
    set "scalator=noscaled"
    echo Scalation aborted by argument -ns
  ) else (
    set "scalator=prob1"
  )
) else (
  if "%fesc%"=="1" (
    echo Scaled resolution: %outputwidth%x%outputheight% ^(%scale%%%^) %scale:~0,-2%.%scale:~-2%
    set "scalator=prob1"
  ) else (
    echo Video is on max resolution, no scalation needed.
  )
)
set "interpolator=nointerpolated"
set /a "interpolatedfps=%originfps%*2"
if %originfps% gtr 30000 (
  if "%fint%"=="1" (
    echo Interpolated frame rate: %interpolatedfps:~0,-3%.%interpolatedfps:~-3%
    set "interpolator=rife"
  ) else (
    set /a "interpolatedfps=%originfps%"
    echo Frame rate should not be greater than 60, no interpolation needed.
  )
) else (
  echo Interpolated frame rate: %interpolatedfps:~0,-3%.%interpolatedfps:~-3%
  if "%nint%"=="1" (
    set "interpolator=nointerpolated"
    echo Interpolation aborted by argument -ni
  ) else (
    set "interpolator=rife"
  )
)
if "%mer%"=="1" (
  set "merge=true"
  goto :merge
)
echo Extracting video frames...
mkdir "%workspace%\frames"
if "%colorbalance%"=="0" (
  start /wait ffmpeg -y -i "%origin%" -start_number 0 "%workspace%\frames\%%6d.png"
)
if "%colorbalance%"=="1" (
  start /wait ffmpeg -y -i "%origin%" -start_number 0 -vf colorbalance=rs=0.1:gs=0.1:bs=0.1 "%workspace%\frames\%%6d.png"
)
if "%colorbalance%"=="2" (
  start /wait ffmpeg -y -i "%origin%" -start_number 0 -vf colorbalance=rm=0.1:gm=0.1:bm=0.1 "%workspace%\frames\%%6d.png"
)
if "%colorbalance%"=="3" (
  start /wait ffmpeg -y -i "%origin%" -start_number 0 -vf colorbalance=rh=0.1:gh=0.1:bh=0.1 "%workspace%\frames\%%6d.png"
)
if "%colorbalance%"=="12" (
  start /wait ffmpeg -y -i "%origin%" -start_number 0 -vf colorbalance=rs=0.1:gs=0.1:bs=0.1:rm=0.1:gm=0.1:bm=0.1 "%workspace%\frames\%%6d.png"
)
if "%colorbalance%"=="13" (
  start /wait ffmpeg -y -i "%origin%" -start_number 0 -vf colorbalance=rs=0.1:gs=0.1:bs=0.1:rh=0.1:gh=0.1:bh=0.1 "%workspace%\frames\%%6d.png"
)
if "%colorbalance%"=="23" (
  start /wait ffmpeg -y -i "%origin%" -start_number 0 -vf colorbalance=rm=0.1:gm=0.1:bm=0.1:rh=0.1:gh=0.1:bh=0.1 "%workspace%\frames\%%6d.png"
)
if "%colorbalance%"=="123" (
  start /wait ffmpeg -y -i "%origin%" -start_number 0 -vf colorbalance=rs=0.1:gs=0.1:bs=0.1:rm=0.1:gm=0.1:bm=0.1:rh=0.1:gh=0.1:bh=0.1 "%workspace%\frames\%%6d.png"
)
echo;
:besc
if "%scalator%"=="noscaled" (
  if "%interpolator%"=="nointerpolated" (
    set "merge=false"
  ) else (
    echo Moving video frames to scaled folder in a pop-out window, since no scalation is needed...
    mkdir "%workspace%\scaled"
    move /y "%workspace%\frames\*" "%workspace%\scaled" >> "%workspace%\log"
    set "merge=true"
  )
) else (
  echo Scaling video frames in a pop-out window...
  mkdir "%workspace%\scaled"
  start /wait veai.exe -m "prob-1" --compression %cons% --details 27 --blur 13 --noise 1 --halo 13 --preBlur -13 -s %scale:~0,-2%.%scale:~-2% -f "png" -o "%workspace%\scaled" -i "%workspace%\frames\000000.png"
  set "merge=true"
)
echo;
rmdir /s /q "%workspace%\frames"
:bint
if "%interpolator%"=="nointerpolated" (
  if "%scalator%"=="noscaled" (
    set "merge=false"
  ) else (
    echo Moving scaled folder to interpolated, since no interpolation is needed...
    mkdir "%workspace%\interpolated"
    move /y "%workspace%\scaled\*" "%workspace%\interpolated" >> "%workspace%\log"
    set "merge=true"
  )
) else (
  mkdir "%workspace%\interpolated"
  start /wait rife-ncnn-vulkan.exe -v -u -m "rife-v4" -j 1:1:1 -f "%%06d.png" -o "%workspace%\interpolated" -i "%workspace%\scaled"
  set "merge=true"
)
echo;
@REM echo Now is time to check if interpolation has made correctly, you can open the IA and do it manually if it didn't...
@REM pause
@REM echo Press again to confirm...
@REM pause
:merge
if "%merge%"=="true" (
  echo Extracting metadata in multiple files due system limitations...
  echo ;FFMETADATA1> "%workspace%\metadata.txt"
  ffprobe.exe -v error -show_entries format_tags=title -of csv=p=0:e=none "%origin%" > "%workspace%\title.txt"
  ffprobe.exe -v error -show_entries format_tags=artist -of csv=p=0:e=none "%origin%" > "%workspace%\artist.txt"
  ffprobe.exe -v error -show_entries format_tags=date -of csv=p=0:e=none "%origin%" > "%workspace%\date.txt"
  ffprobe.exe -v error -show_entries format_tags=description -of csv=p=0:e=none "%origin%" > "%workspace%\description.txt"
  ffprobe.exe -v error -show_entries format_tags=comment -of csv=p=0:e=none "%origin%" > "%workspace%\comment.txt"
  ffprobe.exe -v error -show_entries format_tags=purl -of csv=p=0:e=none "%origin%" > "%workspace%\purl.txt"
  set "first=true"
  set /a "lines=0"
  for /f "delims=" %%s in ('findstr /n /r "^.*$" "%workspace%\title.txt"') do (
    set /a "lines=!lines!+1"
  )
  for /f "delims=" %%s in ('findstr /n /r "^.*$" "%workspace%\title.txt"') do (
    set /a "lines=!lines!-1"
    set "t=%%~s"
    set "t=!t:#=\#!"
    set "t=!t:*:=!"
    if !lines! gtr 0 (
      set "t=!t!\"
    )
    if "!first!"=="true" (
      echo TITLE=!t!>> "%workspace%\metadata.txt"
      set "first=false"
    ) else (
      echo !t!>> "%workspace%\metadata.txt"
    )
  )
  set "first=true"
  set /a "lines=0"
  for /f "delims=" %%s in ('findstr /n /r "^.*$" "%workspace%\artist.txt"') do (
    set /a "lines=!lines!+1"
  )
  for /f "delims=" %%s in ('findstr /n /r "^.*$" "%workspace%\artist.txt"') do (
    set /a "lines=!lines!-1"
    set "t=%%~s"
    set "t=!t:#=\#!"
    set "t=!t:*:=!"
    if !lines! gtr 0 (
      set "t=!t!\"
    )
    if "!first!"=="true" (
      echo ARTIST=!t!>> "%workspace%\metadata.txt"
      set "first=false"
    ) else (
      echo !t!>> "%workspace%\metadata.txt"
    )
  )
  set "first=true"
  set /a "lines=0"
  for /f "delims=" %%s in ('findstr /n /r "^.*$" "%workspace%\date.txt"') do (
    set /a "lines=!lines!+1"
  )
  for /f "delims=" %%s in ('findstr /n /r "^.*$" "%workspace%\date.txt"') do (
    set /a "lines=!lines!-1"
    set "t=%%~s"
    set "t=!t:#=\#!"
    set "t=!t:*:=!"
    if !lines! gtr 0 (
      set "t=!t!\"
    )
    if "!first!"=="true" (
      echo DATE=!t!>> "%workspace%\metadata.txt"
      set "first=false"
    ) else (
      echo !t!>> "%workspace%\metadata.txt"
    )
  )
  set "first=true"
  set /a "lines=0"
  for /f "delims=" %%s in ('findstr /n /r "^.*$" "%workspace%\description.txt"') do (
    set /a "lines=!lines!+1"
  )
  for /f "delims=" %%s in ('findstr /n /r "^.*$" "%workspace%\description.txt"') do (
    set /a "lines=!lines!-1"
    set "t=%%~s"
    set "t=!t:#=\#!"
    set "t=!t:*:=!"
    if !lines! gtr 0 (
      set "t=!t!\"
    )
    if "!first!"=="true" (
      echo DESCRIPTION=!t!>> "%workspace%\metadata.txt"
      set "first=false"
    ) else (
      echo !t!>> "%workspace%\metadata.txt"
    )
  )
  set "first=true"
  set /a "lines=0"
  for /f "delims=" %%s in ('findstr /n /r "^.*$" "%workspace%\comment.txt"') do (
    set /a "lines=!lines!+1"
  )
  for /f "delims=" %%s in ('findstr /n /r "^.*$" "%workspace%\comment.txt"') do (
    set /a "lines=!lines!-1"
    set "t=%%~s"
    set "t=!t:#=\#!"
    set "t=!t:*:=!"
    if !lines! gtr 0 (
      set "t=!t!\"
    )
    if "!first!"=="true" (
      echo COMMENT=!t!>> "%workspace%\metadata.txt"
      set "first=false"
    ) else (
      echo !t!>> "%workspace%\metadata.txt"
    )
  )
  set "first=true"
  set /a "lines=0"
  for /f "delims=" %%s in ('findstr /n /r "^.*$" "%workspace%\purl.txt"') do (
    set /a "lines=!lines!+1"
  )
  for /f "delims=" %%s in ('findstr /n /r "^.*$" "%workspace%\purl.txt"') do (
    set /a "lines=!lines!-1"
    set "t=%%~s"
    set "t=!t:#=\#!"
    set "t=!t:*:=!"
    if !lines! gtr 0 (
      set "t=!t!\"
    )
    if "!first!"=="true" (
      echo PURL=!t!>> "%workspace%\metadata.txt"
      set "first=false"
    ) else (
      echo !t!>> "%workspace%\metadata.txt"
    )
  )
  set "videodata=Side data: Content Light Level Metadata, MaxCLL=1000, MaxFALL=300 Mastering Display Metadata, has_primaries:1 has_luminance:1 r(0.6800,0.3200) g(0.2650,0.6900) b(0.1500 0.0600) wp(0.3127, 0.3290) min_luminance=0.010000, max_luminance=1000.000000"
  dos2unix "%workspace%\metadata.txt"
  if "%na%"=="0" (
    echo Extracting audio...
    start /wait ffmpeg -y -i "%origin%" -f matroska -vn -acodec copy "%workspace%\a.mkv"
  ) else (
    echo Audio muted...
  )
  echo Mergin video data...
  if exist "%workspace%\a.mkv" (
    start /wait ffmpeg -y ^
    -f ffmetadata -r "%interpolatedfps:~0,-3%.%interpolatedfps:~-3%" -i "%workspace%\metadata.txt" ^
    -f matroska -r "%interpolatedfps:~0,-3%.%interpolatedfps:~-3%" -i "%workspace%\a.mkv" ^
    -f image2 -r "%interpolatedfps:~0,-3%.%interpolatedfps:~-3%" -start_number 0 -i "%workspace%\interpolated\%%6d.png" ^
    -start_number 0 -map_metadata:s -1 -map_metadata 0 -r "%interpolatedfps:~0,-3%.%interpolatedfps:~-3%" ^
    -c:v h264_amf -usage:v 0 -profile:v 100 -level:v 62 -quality:v 2 -rc:v 0 -enforce_hrd:v true -filler_data:v true -vbaq:v true -frame_skipping:v false -qp_i:v 17 -qp_p:v 17 -qp_b:v 17 -preanalysis:v true -max_au_size:v 0 -header_spacing:v -1 -bf_delta_qp:v 4 -bf_ref:v false -bf_ref_delta_qp:v 4 -intra_refresh_mb:v 0 -coder:v 1 -me_half_pel:v true -me_quarter_pel:v true -aud:v false -log_to_dbg:v false ^
    -c:a copy ^
    "%outputpath%%fn% %scalator%_%cons%_%interpolator%_%colorbalance%_%na%.mp4"
  ) else (
    start /wait ffmpeg -y ^
    -f ffmetadata -r "%interpolatedfps:~0,-3%.%interpolatedfps:~-3%" -i "%workspace%\metadata.txt" ^
    -f image2 -r "%interpolatedfps:~0,-3%.%interpolatedfps:~-3%" -start_number 0 -i "%workspace%\interpolated\%%6d.png" ^
    -start_number 0 -map_metadata:s -1 -map_metadata 0 -r "%interpolatedfps:~0,-3%.%interpolatedfps:~-3%" ^
    -c:v h264_amf -usage:v 0 -profile:v 100 -level:v 62 -quality:v 2 -rc:v 0 -enforce_hrd:v true -filler_data:v true -vbaq:v true -frame_skipping:v false -qp_i:v 17 -qp_p:v 17 -qp_b:v 17 -preanalysis:v true -max_au_size:v 0 -header_spacing:v -1 -bf_delta_qp:v 4 -bf_ref:v false -bf_ref_delta_qp:v 4 -intra_refresh_mb:v 0 -coder:v 1 -me_half_pel:v true -me_quarter_pel:v true -aud:v false -log_to_dbg:v false ^
    -an ^
    "%outputpath%%fn% %scalator%_%cons%_%interpolator%_%colorbalance%_%na%.mp4"
  )
)
echo;
@REM rmdir /s /q "%workspace%"
echo Process ended at %TIME%...
endlocal