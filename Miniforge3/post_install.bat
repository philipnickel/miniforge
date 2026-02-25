@echo off

REM Initialize conda for all supported shells on this machine.
call "%PREFIX%\Scripts\activate.bat"
conda init --all
