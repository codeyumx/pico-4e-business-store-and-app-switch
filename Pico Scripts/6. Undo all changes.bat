@echo off
rem Undoes what scripts 2-5 changed on one Pico headset, as far as adb allows:
rem - brings back the business apps script 3 removed (pm install-existing) and switches them on;
rem - removes the installed updates of PICO Store, User Center, PICO Home (scripts 3, 4) and
rem   PICO Connect (script 2), which brings back the preinstalled versions. Their data,
rem   including the store sign-in, is lost. PICO Connect goes back to Streaming Assistant;
rem - switches the consumer store, user center and PICO Home off;
rem - uninstalls Lightning Launcher and QuickShortcutMaker (script 3);
rem - switches Explore and the User Guide back on (script 5);
rem - deletes store.apk from the headset's Download folder (scripts 3, 4).
rem Only what is found on the headset is listed in the plan. Settings changed by hand,
rem such as Customize Library or the developer menu, are not touched.
rem A factory reset undoes everything instead.
rem Optional: pass a serial to preselect a headset.
setlocal EnableDelayedExpansion
title Pico - Undo all changes
call "%~dp0_pico.cmd" %1 || goto end

rem com.pvr.tobservice is listed because older versions of script 3 removed it.
set "BUSINESS=com.pvr.tobactivate com.picovr.tobvrusercenter com.pvr.tobhome com.pvr.tobstore com.picoxr.tobstore com.pvr.tobservice com.picovr.enterpriseassistant"
set "UPDATED=com.picovr.store com.picovr.vrusercenter com.pvr.home com.picovr.picostreamassistant"
set "CONSUMER=com.picovr.store com.picovr.vrusercenter com.pvr.home"
rem Lightning Launcher and QuickShortcutMaker.
set "HELPERS=com.threethan.launcher com.sika524.android.quickshortcut"
rem Explore and User Guide.
set "SCRIPT5=com.picovr.activitycenter com.picovr.guide"

echo.
echo Checking what the scripts changed...
set "TO_RESTORE="
for %%P in (%BUSINESS%) do (
  call :state %%P
  if "!STATE!"=="removed" set "TO_RESTORE=!TO_RESTORE! %%P"
)
set "TO_DOWNGRADE="
for %%P in (%UPDATED%) do (
  call :state %%P
  if "!UPD!"=="upd" set "TO_DOWNGRADE=!TO_DOWNGRADE! %%P"
)
set "TO_OFF="
for %%P in (%CONSUMER%) do (
  call :state %%P
  if "!STATE!"=="on" set "TO_OFF=!TO_OFF! %%P"
)
set "TO_UNINSTALL="
for %%P in (%HELPERS%) do (
  call :state %%P
  if "!UPD!"=="upd" set "TO_UNINSTALL=!TO_UNINSTALL! %%P"
)
set "TO_ENABLE="
for %%P in (%SCRIPT5%) do (
  call :state %%P
  if "!STATE!"=="off" set "TO_ENABLE=!TO_ENABLE! %%P"
)
set "STORE_FILE="
for /f %%F in ('call %ADB% shell "[ -f /sdcard/Download/store.apk ] && echo yes" ^<nul') do set "STORE_FILE=%%F"

set "ANY=%TO_RESTORE%%TO_DOWNGRADE%%TO_OFF%%TO_UNINSTALL%%TO_ENABLE%%STORE_FILE%"
if not defined ANY echo Nothing to undo on %PICO_NAME%, serial %PICO_SERIAL%.& goto end

echo.
echo Plan for %PICO_NAME%, serial %PICO_SERIAL%:
if defined TO_RESTORE   echo   1. Bring back and switch on business apps:%TO_RESTORE%
if defined TO_DOWNGRADE echo   2. Remove installed updates, back to the preinstalled versions:%TO_DOWNGRADE%
if defined TO_DOWNGRADE echo      Their data, including the store sign-in, is lost.
if defined TO_OFF       echo   3. Switch off consumer apps:%TO_OFF%
if defined TO_UNINSTALL echo   4. Uninstall Lightning Launcher / QuickShortcutMaker:%TO_UNINSTALL%
if defined TO_ENABLE    echo   5. Switch back on:%TO_ENABLE%
if defined STORE_FILE   echo   6. Delete store.apk from the headset's Download folder
echo.
echo   Not touched: apps you installed yourself, Customize Library and the developer menu.
echo.
choice /c YN /m "Apply these changes"
if errorlevel 2 goto end

if defined TO_RESTORE (
  echo.
  echo [1/6] Bringing back business apps...
  for %%P in (%TO_RESTORE%) do (
    %ADB% shell pm install-existing %%P >nul
    call "%~dp0_enable.cmd" %%P
  )
)
if defined TO_DOWNGRADE (
  echo.
  echo [2/6] Removing installed updates...
  for %%P in (%TO_DOWNGRADE%) do (
    echo   %%P
    %ADB% shell pm uninstall %%P
  )
)
rem Checked again: removing an update can change whether an app is on.
set "TO_OFF="
for %%P in (%CONSUMER%) do (
  call :state %%P
  if "!STATE!"=="on" set "TO_OFF=!TO_OFF! %%P"
)
if defined TO_OFF (
  echo.
  echo [3/6] Switching off consumer apps...
  for %%P in (%TO_OFF%) do %ADB% shell pm disable-user --user 0 %%P
)
if defined TO_UNINSTALL (
  echo.
  echo [4/6] Uninstalling helper apps...
  for %%P in (%TO_UNINSTALL%) do (
    echo   %%P
    %ADB% shell pm uninstall %%P
  )
)
if defined TO_ENABLE (
  echo.
  echo [5/6] Switching apps back on...
  for %%P in (%TO_ENABLE%) do call "%~dp0_enable.cmd" %%P
)
if defined STORE_FILE (
  echo.
  echo [6/6] Deleting store.apk from the Download folder...
  %ADB% shell rm /sdcard/Download/store.apk
)

echo.
echo Done. Reboot the headset. The business apps are back; Customize Library settings
echo you changed by hand stay as they are, change them in Business Settings if needed.
goto end

rem :state <package> - sets STATE to on, off (switched off), removed (removed for
rem user 0, still in the system image) or missing, and UPD to upd if an installed
rem APK (an update or a non-system app) is present, else sys.
:state
set "STATE=missing"
set "UPD=sys"
for /f "tokens=1,2" %%A in ('call %ADB% shell "if pm list packages -e | grep -qx package:%1; then s=on; elif pm list packages -d | grep -qx package:%1; then s=off; elif pm list packages -u | grep -qx package:%1; then s=removed; else s=missing; fi; u=sys; pm path %1 2>/dev/null | grep -q /data/app/ && u=upd; echo $s $u" ^<nul') do (
  set "STATE=%%A"
  set "UPD=%%B"
)
exit /b 0

:end
call "%~dp0_adb.cmd" stop
echo.
pause
