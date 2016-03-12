@echo off
:: Batch file to compile lab6 project for CMPE 12L
title CMPE 12L

:: Make sure to install drivers for Mac: http://www.ftdichip.com/Drivers/VCP.htm

:: Check proper usage
if [%1]==[] (
   echo Usage: %~nx0 [file.hex]
   pause
   title C:\Windows\system32\cmd.exe
   exit /B
)

:: Set the path so we can run MPIDE programs
set MPIDE_PATH=C:\Program Files (x86)\mpide
set PATH=%PATH%;%MPIDE_PATH%\hardware\tools\avr\bin

avrdude "-C%MPIDE_PATH%/hardware/tools/avr/etc/avrdude.conf" -p32MX320F128H -P\\.\COM4 -cstk500v2 -b115200 -Uflash:w:%1:i

echo Done! (Were there any errors or warnings?)
pause