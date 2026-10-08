@echo off
rem Disables Explore (activity center), Pico Home and the User Guide on one Pico headset.
rem Same packages as the original script. Undo with:
rem   adb -s <serial> shell pm enable <package>
rem Optional: pass a serial to preselect a headset.
setlocal EnableDelayedExpansion
title Pico - Disable Explore and User Guide
call "%~dp0_pico.cmd" %1 || goto end

set "DISABLE=com.picovr.activitycenter com.pvr.home com.picovr.guide"

set "TO_DISABLE="
for %%P in (%DISABLE%) do (
  call :installed %%P
  if not errorlevel 1 set "TO_DISABLE=!TO_DISABLE! %%P"
)
if not defined TO_DISABLE echo None of %DISABLE% are installed.& goto end

echo.
echo Plan for %PICO_NAME%, serial %PICO_SERIAL%:
echo   Disable:%TO_DISABLE%
echo.
choice /c YN /m "Apply these changes"
if errorlevel 2 goto end

for %%P in (%TO_DISABLE%) do %ADB% shell pm disable-user --user 0 %%P
echo.
echo To undo:  adb -s %PICO_SERIAL% shell pm enable ^<package^>
goto end

rem :installed <package> - errorlevel 0 if the package is installed for user 0.
:installed
%ADB% shell pm list packages %1 <nul | findstr /r /c:"^package:%1$" >nul
exit /b

:end
call "%~dp0_adb.cmd" stop
echo.
pause
