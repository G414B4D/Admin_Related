REM This should be run on all builds Win 7 or newer. Will not work on XP

@echo off 
bcdedit /set nx optout
if %errorlevel% equ 0 (
  echo NX setting changed successfully to OptOut
) else (
    echo Failed. Be sure to run as an Administrator.
)
pause
