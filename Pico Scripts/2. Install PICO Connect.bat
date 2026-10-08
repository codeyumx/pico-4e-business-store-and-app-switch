@echo off
rem Installs the global PICO Connect APK (..\Apks\PICOConnect*.apk) on one Pico headset
rem and switches it on. PICO Connect is the consumer build of Streaming Assistant:
rem both use the package com.picovr.picostreamassistant, so this updates the
rem preinstalled business copy. If several PICOConnect*.apk files exist, the last
rem one by file name is used.
rem Optional: pass a serial to preselect a headset.
setlocal
title Pico - Install PICO Connect
call "%~dp0_pico.cmd" %1 || goto end

for %%I in ("%~dp0..\Apks") do set "APKS=%%~fI"
set "APK="
for /f "delims=" %%F in ('dir /b /o:n "%APKS%\PICOConnect*.apk" 2^>nul') do set "APK=%APKS%\%%F"
if not defined APK echo ERROR: no PICOConnect*.apk found in %APKS%.& goto end

echo.
echo Plan for %PICO_NAME%, serial %PICO_SERIAL%:
echo   Install %APK%
echo   Enable com.picovr.picostreamassistant
echo.
choice /c YN /m "Apply these changes"
if errorlevel 2 goto end

%ADB% install -r "%APK%"
call "%~dp0_enable.cmd" com.picovr.picostreamassistant

:end
call "%~dp0_adb.cmd" stop
echo.
pause
