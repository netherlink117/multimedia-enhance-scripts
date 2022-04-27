@echo off
cls
setlocal enabledelayedexpansion
if "%~1"=="" (
  echo Please bring the image's path after the command...
  echo;
  echo Example:
  echo;
  echo %cd%^>realsr-rife "D:\\path\to\image.jpg"
  goto :eof
)

:prep
cls
set "input=%~1"
set "idisk=%~d1"
set "ipath=%~p1"
set "iname=%~n1"
set "iextension=%~x1"
realsr-ncnn-vulkan.exe -v -x -s 4 -m "models-DF2K_JPEG" -i "%idisk%%ipath%%iname%%iextension%" -o "%idisk%%ipath%%iname%-realsrx%iextension%"
endlocal