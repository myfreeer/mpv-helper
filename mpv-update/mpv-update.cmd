@echo off
REM Header
setlocal EnableExtensions EnableDelayedExpansion
CD /D "%~dp0"
pushd "%~dp0"
title mpv updater by myfreeer
REM main
set "bin=%~dp0"

if exist mpv.com if exist mpv.exe for /f "tokens=2 delims= " %%i in ('mpv -V ^| find /I "mpv"') do set currentVersion=%%i
if "%currentVersion%" neq "" (
    echo Current mpv version: %currentVersion%
) else (
    echo Caution: mpv does not exist.
)
call :DownloadStr "https://ci.appveyor.com/api/projects/myfreeer/mpv-build-lite/artifacts/VERSION?branch=master" newVersion
if "%newVersion%" == "" (
    echo Network error, check your network and try again later.
    goto :End
) else (
    echo Latest mpv version:  %newVersion%
)
if "%currentVersion%" == "%newVersion%" (
    echo Already Up-to-date.
    goto :End
)

echo Downloading mpv %newVersion%...
mkdir "mpv-%newVersion%" 2>&1 1>nul
cd "mpv-%newVersion%"
call :Download "https://ci.appveyor.com/api/projects/myfreeer/mpv-build-lite/artifacts/mpv.7z?branch=master" "mpv-%newVersion%.7z"
echo Extracting mpv %newVersion%...
mkdir "mpv-%newVersion%"
cd "mpv-%newVersion%"
..\..\7zDec x "..\mpv-%newVersion%.7z"
if %ERRORLEVEL% neq 0 goto :Error

:Update
mpv -V | find /I "%newVersion%" 2>&1 1>nul
if %ERRORLEVEL% neq 0 goto :Error
echo Updating mpv files to %newVersion%...
2>&1 1>nul xcopy /S /G /H /R /Y /D ".\*" ..\..\
cd ..\..
rd /s /q "mpv-%newVersion%" || rd /s /q "mpv-%newVersion%" 2>&1 1>nul 
echo Updated mpv to version %newVersion%
goto :End

:Error
echo Download or extract error, check your network and try again later.
goto :End

:End
if exist youtube-dl.exe (
    echo Found youtube-dl, checking for updates...
    youtube-dl.exe --update
)
pause
exit /B

:Download
REM call :Download URL FileName
"%bin%\curl" -L -k -f --progress-bar --retry 3 --retry-delay 5 -o "%~2" "%~1"
exit /b %ERRORLEVEL%

:DownloadStr
REM call :DownloadStr URL
REM call :DownloadStr URL output_var
if "%~2" == "" (
    curl -L -k -f -q -s --retry 3 --retry-delay 5 "%~1"
) else (
    for /f "usebackq tokens=* delims=" %%i in (`curl -L -k -f -q -s --retry 3 --retry-delay 5 "%~1"`) do set "%~2=%%i"
)
exit /b %ERRORLEVEL%