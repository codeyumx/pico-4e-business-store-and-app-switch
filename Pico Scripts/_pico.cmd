@echo off
rem Shared helper, not meant to be run directly.
rem   call "%~dp0_pico.cmd" [serial]
rem Lists connected Pico headsets, lets you pick one and confirm it.
rem Pass a serial to only consider that headset; otherwise you get a menu.
rem On success sets PICO_SERIAL, PICO_NAME, ADB_EXE and ADB, where ADB is
rem "adb.exe" -s <serial>, so every command goes to the chosen headset only.
rem Exits with errorlevel 1 if no headset was chosen.
set "PICO_SERIAL="
set "PICO_NAME="
set "ADB="
call "%~dp0_adb.cmd" || exit /b 1

setlocal EnableDelayedExpansion
set "WANT=%~1"
"%ADB_EXE%" start-server >nul 2>&1

:scan
for /f "delims==" %%V in ('set C_ 2^>nul') do set "%%V="
set /a COUNT=0
echo.
echo Looking for Pico headsets...
for /f "usebackq skip=1 tokens=1,2" %%S in (`call "%ADB_EXE%" devices`) do call :consider %%S %%T
if %COUNT% gtr 0 goto pick
echo.
if defined WANT echo No ready Pico headset with serial %WANT% found.
if not defined WANT echo No ready Pico headset found.
echo Plug the headset into a USB port on the PC with a data cable, wake it up,
echo and accept "Allow USB debugging" inside the headset.
choice /c RQ /m "R = scan again, Q = quit"
if errorlevel 2 exit /b 1
goto scan

:pick
echo.
echo Pico headsets found:
for /l %%I in (1,1,%COUNT%) do echo   %%I. !N_%%I!   serial: !C_%%I!
set "SEL=1"
if %COUNT% gtr 1 set "SEL=" & set /p "SEL=Type the number of the headset to use: "
if not defined SEL goto pick
for /f "delims=0123456789" %%X in ("!SEL!") do goto pick
if not defined C_!SEL! goto pick
set "SERIAL=!C_%SEL%!"
set "NAME=!N_%SEL%!"
echo.
echo Selected: !NAME!   serial: !SERIAL!
choice /c YN /m "Use this headset"
if errorlevel 2 exit /b 1
endlocal & set "PICO_SERIAL=%SERIAL%" & set "PICO_NAME=%NAME%"
set ADB="%ADB_EXE%" -s %PICO_SERIAL%
exit /b 0

rem :consider <serial> <state> - adds the device to the menu if it is a ready Pico.
:consider
if defined WANT if /i not "%~1"=="%WANT%" exit /b 0
if /i "%~2"=="unauthorized" echo   %~1: accept "Allow USB debugging" inside the headset, then scan again.& exit /b 0
if /i not "%~2"=="device" echo   %~1: state "%~2", not usable.& exit /b 0
set "BRAND="
for /f "delims=" %%B in ('call "%ADB_EXE%" -s %~1 shell getprop ro.product.brand ^<nul') do set "BRAND=%%B"
if /i not "!BRAND!"=="Pico" echo   %~1: not a Pico ^(brand "!BRAND!"^), ignored.& exit /b 0
set "NAME="
for /f "delims=" %%N in ('call "%ADB_EXE%" -s %~1 shell getprop sys.pxr.product.name ^<nul') do set "NAME=%%N"
if not defined NAME for /f "delims=" %%N in ('call "%ADB_EXE%" -s %~1 shell getprop ro.product.model ^<nul') do set "NAME=%%N"
set /a COUNT+=1
set "C_!COUNT!=%~1"
set "N_!COUNT!=!NAME!"
exit /b 0
