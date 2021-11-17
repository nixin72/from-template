@echo off

set PROTOCOL=%1
set REPO=%2
set DEST=%3

call git clone "%PROTOCOL%%REPO%.git" %DEST%

if not exist %DEST% goto :clone_failed

cd %DEST%

rd /s /q .git

goto :exit

:clone_failed

echo "Cloning %REPO% failed."

exit /b 1

:exit
