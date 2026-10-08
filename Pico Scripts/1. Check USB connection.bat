@echo off
rem Shows whether Windows and adb can see Pico headsets over USB. Changes nothing
rem on the PC or the headset; the adb server is stopped again at the end if this
rem script started it (see _adb.cmd).
rem Replaces the original driver script, whose usb_driver folder was never shipped.
rem If a "PICO Composite ADB Interface" shows up below with status OK, the driver is fine.
setlocal
title Pico - Check USB connection
call "%~dp0_adb.cmd" || goto end

echo === Pico USB devices seen by Windows ===
powershell -NoProfile -Command "$d = Get-PnpDevice -PresentOnly | Where-Object InstanceId -Match 'VID_2D40'; if ($d) { $d | Format-Table -AutoSize Status,Class,FriendlyName } else { 'None. Check the cable (must carry data), use a port on the PC, and wake the headset.' }"
echo.
echo === Devices seen by adb (%ADB_EXE%) ===
"%ADB_EXE%" devices -l
echo   device       = ready
echo   unauthorized = accept "Allow USB debugging" inside the headset
echo   offline      = unplug and replug the cable

:end
call "%~dp0_adb.cmd" stop
echo.
pause
