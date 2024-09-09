@echo off
GenerConst const.S
fc const.S const_ref.S
if not errorlevel 1 goto ok
pause
:ok
