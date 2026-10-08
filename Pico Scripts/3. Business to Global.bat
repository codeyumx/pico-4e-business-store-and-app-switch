@echo off
rem Switches one Pico headset from the business (ToB) apps to the global apps.
rem Run it, pick the headset, check the plan, confirm. Optional: pass a serial
rem to preselect a headset:  "3. Business to Global.bat" <serial>
rem Every adb command uses -s <serial>, so other connected devices are never touched.
rem Business apps are removed with "pm uninstall -k --user 0", which keeps the
rem system copy; the undo command is printed at the end.
setlocal EnableDelayedExpansion
title Pico - Business to Global
call "%~dp0_pico.cmd" %1 || goto end

for %%I in ("%~dp0..\Apks") do set "APKS=%%~fI"

rem Business apps to remove. Names that are not installed are skipped.
rem com.picoxr.tobstore is the business store's name on newer firmware (seen on 5.9.9).
rem Not removed on purpose: com.pvr.tobservice (Business Settings, which holds
rem Customize Library). Effect unknown, so also kept: com.picovrtob.vrlauncher,
rem com.picoxr.tobmdm, com.bytedance.pico.tob.userservice. Add them here if you need to.
set "BUSINESS=com.pvr.tobactivate com.picovr.tobvrusercenter com.pvr.tobhome com.pvr.tobstore com.picoxr.tobstore com.picovr.enterpriseassistant"

rem Global system apps to restore and enable.
set "GLOBAL=com.picovr.vrusercenter com.pvr.home com.picovr.store"

rem APKs from ..\Apks to install. nextapp.fx.apk is left out on purpose: it is a
rem cracked FX File Explorer re-signed by a third party.
set "APK_LIST=store.apk home.apk VRUserCenter2.apk LightningLauncher.apk quickshortcut.apk"

set "TO_REMOVE="
for %%P in (%BUSINESS%) do (
  call :installed %%P
  if not errorlevel 1 set "TO_REMOVE=!TO_REMOVE! %%P"
)

echo.
echo Plan for %PICO_NAME%, serial %PICO_SERIAL%:
if defined TO_REMOVE echo   1. Remove business apps:%TO_REMOVE%
if not defined TO_REMOVE echo   1. Remove business apps: none installed, nothing to remove
echo   2. Restore global apps: %GLOBAL%
echo   3. Install APKs from %APKS%: %APK_LIST%
echo   4. Enable global apps
echo   5. Copy store.apk to the headset's Download folder, if it is not there yet
echo.
echo   These scripts only change apps. They never flash firmware.
echo   WARNING: never flash a firmware file meant for another model or edition,
echo   such as a consumer PICO 4 or PICO 4 Pro update, onto a PICO 4 Enterprise.
echo   Only use firmware confirmed for your exact model. Wrong firmware can brick it.
echo.
choice /c YN /m "Apply these changes"
if errorlevel 2 goto end

echo.
echo [1/5] Removing business apps...
for %%P in (%TO_REMOVE%) do (
  echo   %%P
  %ADB% shell pm uninstall -k --user 0 %%P
)

echo.
echo [2/5] Restoring global apps...
for %%P in (%GLOBAL%) do (
  echo   %%P
  %ADB% shell pm install-existing %%P
)

echo.
echo [3/5] Installing APKs...
for %%A in (%APK_LIST%) do (
  if exist "%APKS%\%%A" (
    call :describe %%A
    %ADB% install -r "%APKS%\%%A"
  ) else (
    echo   %%A: file not found, skipped
  )
)

echo.
echo [4/5] Enabling global apps...
for %%P in (%GLOBAL%) do call "%~dp0_enable.cmd" %%P

echo.
echo [5/5] Copying store.apk to the headset...
if exist "%APKS%\store.apk" (call "%~dp0_copy_store.cmd" "%APKS%\store.apk") else (echo   store.apk: file not found, skipped)

echo.
echo Done. Reboot the headset, open the PICO Store app and sign in there with a regular PICO account.
echo The taskbar profile button does not work on a business-edition headset.
echo If PICO Home does not show the store, open it from Lightning Launcher.
if defined TO_REMOVE (
  echo To bring a removed business app back:
  echo   adb -s %PICO_SERIAL% shell pm install-existing ^<package^>
  echo Removed:%TO_REMOVE%
)
goto end

rem :describe <apk> - one-line explanation of what an APK is, shown while installing it.
:describe
if /i "%~1"=="store.apk"             echo   %~1 - PICO Store, consumer version: buy and download apps with a regular PICO account.
if /i "%~1"=="home.apk"              echo   %~1 - PICO Home, consumer version: the normal home screen and app library.
if /i "%~1"=="VRUserCenter2.apk"     echo   %~1 - PICO User Center, consumer version: shows your PICO account; open it from Lightning Launcher.
if /i "%~1"=="LightningLauncher.apk" echo   %~1 - Lightning Launcher: third-party app launcher that lists every installed app, a way into the store if PICO Home will not open it.
if /i "%~1"=="quickshortcut.apk"     echo   %~1 - QuickShortcutMaker: opens hidden screens inside installed apps, such as settings pages, and can pin shortcuts to them.
exit /b 0

rem :installed <package> - errorlevel 0 if the package is installed for user 0.
:installed
%ADB% shell pm list packages %1 <nul | findstr /r /c:"^package:%1$" >nul
exit /b

:end
call "%~dp0_adb.cmd" stop
echo.
pause
