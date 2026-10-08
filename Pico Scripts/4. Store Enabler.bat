@echo off
rem Reinstalls the global store (..\Apks\store.apk) on one Pico headset and enables it.
rem Optional: pass a serial to preselect a headset.
setlocal
title Pico - Store Enabler
call "%~dp0_pico.cmd" %1 || goto end

for %%I in ("%~dp0..\Apks\store.apk") do set "APK=%%~fI"
if not exist "%APK%" echo ERROR: %APK% not found.& goto end

echo.
echo Plan for %PICO_NAME%, serial %PICO_SERIAL%:
echo   Install %APK%
echo   Enable com.picovr.store
echo.
choice /c YN /m "Apply these changes"
if errorlevel 2 goto end

%ADB% install -r "%APK%"
call "%~dp0_enable.cmd" com.picovr.store

:end
call "%~dp0_adb.cmd" stop
echo.
pause
