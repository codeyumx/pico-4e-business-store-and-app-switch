@echo off
rem Shared helper, not meant to be run directly.
rem   call "%~dp0_copy_store.cmd" <path to store.apk>
rem Copies store.apk to the headset's Download folder unless a copy of the same size
rem is already there, so the store can be reinstalled from the Files app after a
rem reboot without a PC. Uses ADB from _pico.cmd.
setlocal
set "REMOTE_SIZE="
for /f %%S in ('call %ADB% shell "stat -c %%s /sdcard/Download/store.apk 2>/dev/null" ^<nul') do set "REMOTE_SIZE=%%S"
if "%REMOTE_SIZE%"=="%~z1" (
  echo   store.apk is already in the headset's Download folder.
) else (
  %ADB% push "%~1" /sdcard/Download/store.apk >nul || (echo   ERROR: could not copy store.apk to the headset.& exit /b 1)
  echo   Copied store.apk to the headset's Download folder.
)
echo   If the store is switched off after a reboot, reinstall it in the headset:
echo   open Files, go to Download, tap store.apk and install it.
exit /b 0
