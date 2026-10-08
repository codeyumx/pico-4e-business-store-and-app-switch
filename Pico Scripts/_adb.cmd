@echo off
rem Shared helper, not meant to be run directly.
rem   call "%~dp0_adb.cmd"        at the start of a script
rem   call "%~dp0_adb.cmd" stop   at the end of a script
rem Start: sets ADB_EXE to adb.exe (the one on PATH first, else a winget install of
rem Google.PlatformTools, which covers windows opened before winget updated PATH)
rem and remembers which adb server process, if any, is running.
rem Exits with errorlevel 1 if adb is not found.
rem Stop: stops the adb server if it is not the one that was running at the start,
rem i.e. the script started it. A server another tool was already using is left alone.
if /i "%~1"=="stop" goto stop

set "SERVER_PID_BEFORE="
set "ADB_EXE="
for /f "delims=" %%A in ('where adb 2^>nul') do if not defined ADB_EXE set "ADB_EXE=%%A"
if not defined ADB_EXE for /d %%D in ("%LOCALAPPDATA%\Microsoft\WinGet\Packages\Google.PlatformTools_*" "%ProgramFiles%\WinGet\Packages\Google.PlatformTools_*") do if exist "%%D\platform-tools\adb.exe" set "ADB_EXE=%%D\platform-tools\adb.exe"
if not defined ADB_EXE goto missing
call :server_pid SERVER_PID_BEFORE
exit /b 0

:missing
echo ERROR: adb not found. Install it once from a terminal:
echo   winget install Google.PlatformTools
echo then run this script again. Without winget, download platform-tools from
echo   https://developer.android.com/tools/releases/platform-tools
echo and add its folder to PATH.
exit /b 1

:stop
if not defined ADB_EXE exit /b 0
call :server_pid SERVER_PID_NOW
if not defined SERVER_PID_NOW exit /b 0
if "%SERVER_PID_NOW%"=="%SERVER_PID_BEFORE%" exit /b 0
"%ADB_EXE%" kill-server >nul 2>&1
echo adb server stopped.
exit /b 0

rem :server_pid <var> - sets <var> to the PID listening on adb's port 5037, or clears it.
:server_pid
set "%~1="
for /f "tokens=5" %%P in ('netstat -ano -p tcp ^| findstr /r /c:":5037 .*LISTENING"') do set "%~1=%%P"
exit /b 0
