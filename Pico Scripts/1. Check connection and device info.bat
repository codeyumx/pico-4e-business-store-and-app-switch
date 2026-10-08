@echo off
rem Checks that Windows and adb see the Pico headset over USB, then shows model,
rem firmware, OEM state, region and business apps of the headset you pick.
rem Read-only: changes nothing on the PC or the headset. The adb server is stopped
rem again at the end if this script started it (see _adb.cmd).
rem If a "PICO Composite ADB Interface" shows up with status OK, the driver is fine.
rem Optional: pass a serial to preselect a headset.
setlocal
title Pico - Check connection and device info
call "%~dp0_adb.cmd" || goto end
rem _pico.cmd calls _adb.cmd again, after "adb devices" below may have started the
rem server; keep the first reading so the server is still stopped at the end.
set "FIRST_PID=%SERVER_PID_BEFORE%"

echo === Pico USB devices seen by Windows ===
powershell -NoProfile -Command "$d = Get-PnpDevice -PresentOnly | Where-Object InstanceId -Match 'VID_2D40'; if ($d) { $d | Format-Table -AutoSize Status,Class,FriendlyName } else { 'None. Check the cable (must carry data), use a port on the PC, and wake the headset.' }"
echo.
echo === Devices seen by adb (%ADB_EXE%) ===
"%ADB_EXE%" devices -l
echo   device       = ready
echo   unauthorized = accept "Allow USB debugging" inside the headset
echo   offline      = unplug and replug the cable

set "PICKED="
call "%~dp0_pico.cmd" %1 && set "PICKED=1"
set "SERVER_PID_BEFORE=%FIRST_PID%"
if not defined PICKED goto end

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
