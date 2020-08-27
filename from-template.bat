@echo off

set REPO=%1
set DEST=%2

echo %REPO%

echo %cd%

call git clone "git@github.com:racket-templates/%REPO%.git" %DEST%

if not exist %DEST% goto :clone_failed

cd %DEST%

rd /s /q .git

goto :exit

:clone_failed

echo "Cloning %REPO% failed."

exit /b 1

:exit
