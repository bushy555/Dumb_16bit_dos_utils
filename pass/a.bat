echo off
cls
call pass2.com
if errorlevel 1 echo "dont continue"
if errorlevel 1 goto :a
if errorlevel 0 echo "continue" 
:a


