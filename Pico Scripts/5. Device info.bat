@echo off
rem Shows model, firmware, OEM state, region and business apps of one Pico headset.
rem Read-only. Optional: pass a serial to preselect a headset.
setlocal
title Pico - Device info
call "%~dp0_pico.cmd" %1 || goto end

set "FIRMWARE="
set "OEM="
set "REGION="
set "HOME_APP="
for /f "delims=" %%V in ('call %ADB% shell getprop ro.build.display.id ^<nul') do set "FIRMWARE=%%V"
for /f "delims=" %%V in ('call %ADB% shell getprop ro.oem.state ^<nul') do set "OEM=%%V"
for /f "delims=" %%V in ('call %ADB% shell settings get global user_settings_initialized ^<nul') do set "REGION=%%V"
for /f "delims=" %%V in ('call %ADB% shell getprop persist.pvr.default.home ^<nul') do set "HOME_APP=%%V"
if not defined OEM set "OEM=not set, so non-OEM"

echo.
echo Headset:      %PICO_NAME%
echo Serial:       %PICO_SERIAL%
echo Firmware:     %FIRMWARE%
echo OEM state:    %OEM%
echo Region:       %REGION%
echo Default home: %HOME_APP%
echo Business apps installed:
%ADB% shell pm list packages <nul | findstr /i /r "\.tob vrtob\. enterpriseassistant" || echo   none

:end
call "%~dp0_adb.cmd" stop
echo.
pause
