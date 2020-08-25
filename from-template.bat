@echo off

set REPO=%1
set DEST=%2

echo %REPO%

echo %cd%

call git clone "git@github.com:racket-templates/%REPO%.git" %DEST%

cd "%DEST%"

rd /s /q .git
