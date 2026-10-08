@echo off
rem Shared helper, not meant to be run directly.
rem   call "%~dp0_enable.cmd" <package>
rem Switches an app on, using ADB from _pico.cmd, and reports whether it is on afterwards.
rem adb may not use "pm enable" on an app the system switched off (enabled=2):
rem "Shell cannot change component state". For a system app in that state, the app is
rem removed for user 0 and restored, which resets it to its default (on) state; -k keeps
rem its data and the installed update stays. Other apps just get "pm enable".
%ADB% shell "s=$(dumpsys package %~1 2>/dev/null | grep -m1 -oE 'enabled=[0-9]'); if [ x$s = xenabled=2 ] && pm list packages -s | grep -qx package:%~1; then pm uninstall -k --user 0 %~1 >/dev/null && pm install-existing %~1 >/dev/null; else pm enable %~1 >/dev/null 2>&1; fi; if pm list packages -e | grep -qx package:%~1; then echo '  %~1: on'; else echo '  %~1: STILL OFF'; fi" <nul
