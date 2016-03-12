@echo off
:: Batch file to compile arduino labs for CMPE 12L
title CMPE 12L

:: Check proper usage
if [%1]==[] (
   echo Usage: %~nx0 [file.s]
   pause
   title C:\Windows\system32\cmd.exe
   exit /B
)

:: Get file info
set FILE=%~nx1
set NAME=%~n1
set DIR=%~p1

:: Set the path so we can run MPIDE programs
set MPIDE_PATH=C:\Program Files (x86)\mpide
set PATH=%PATH%;%MPIDE_PATH%\hardware\pic32\compiler\pic32-tools\bin

pic32-g++ -c -mprocessor=32MX320F128H -I. "-I%MPIDE_PATH%/hardware/pic32/cores/pic32" "-I%MPIDE_PATH%/hardware/pic32/variants/Uno32" -O0 "%DIR%main.cpp" -o "%DIR%main.o"

pic32-as -march=pic32mx -I. "%FILE%" -o "%DIR%%NAME%.o"

pic32-g++ -Os -Wl,--gc-sections -mdebugger -mprocessor=32MX320F128H  -o "%DIR%%NAME%.elf"  "%DIR%main.o" "%DIR%%NAME%.o" "%DIR%core.a" -T  "%MPIDE_PATH%/hardware/pic32/cores/pic32/chipKIT-UNO32-application-32MX320F128L.ld"

pic32-bin2hex -a "%DIR%%NAME%.elf" 

pic32-objdump -h -S "%DIR%%NAME%.elf" > "%DIR%%NAME%.lss"

pic32-nm -n "%DIR%%NAME%.elf" > "%DIR%%NAME%.sym"

echo Done! (Were there any errors or warnings?)
pause