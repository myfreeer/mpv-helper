@echo off
setlocal EnableExtensions EnableDelayedExpansion
CD /D "%~dp0"
pushd "%~dp0"
set "player=%~dp0mpv.exe"
REM main
if not exist "%~1" exit /B
for /f "tokens=1,2* delims=* usebackq" %%i in ("%~1") do call :parser "%%~i" "%%~j" "%%~k"
pause
exit /B

:parser
if "%~2" == "file" set "%~1_%~2=%~3"
if "%~2" == "title" (
    set "%~3=!%~1_file!"
    echo Creating shortcut for %~3 !%~3!
    if "!%~3!" neq "" call :CreateShort "%~dp0%~3_%~1.lnk" "%player%" "--title=""""%~3"""" """"!%~3!"""""
)
exit /b

:CreateShort
set "vbs=set a=CreateObject(""WScript.Shell"") :set b=a.CreateShortcut(""%~1"")"
set "vbs=%vbs%  :b.TargetPath=""%~2""  :b.Arguments=""%~3""  :b.Save:close"
echo %vbs%
start /wait /min mshta VBScript:Execute("%vbs%")
exit /b
