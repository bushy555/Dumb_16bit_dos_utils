@echo off
@cls
@call zbfc %1
@if errorlevel 1 echo Level 1
@if errorlevel 1 goto end
@if errorlevel 0 echo level 0
:end
