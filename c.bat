@echo off
rem Compilation...
call d.bat
if exist %APPNAME%.hex del %APPNAME%.hex

cd ET58_module
if exist ML.S del ML.S
ET58_module ML
cd ..
if not exist ET58_module\ML.S goto err

copy crc_0.S crc.S > nul

ET58_build\ET58_build.exe ET-58 > build.S

echo Compile %APPNAME%...
make all -s PROJECT=%APPNAME% MCU=atmega328p F_CPU=4000000
rem 2> a
if errorlevel 1 goto err

ET58_crc\ET58_crc.exe ET58.bin crc.S
if errorlevel 1 goto err

call d.bat
if exist %APPNAME%.hex del %APPNAME%.hex

make all -s PROJECT=%APPNAME% MCU=atmega328p F_CPU=4000000
if errorlevel 1 goto err

avr-nm -n %APPNAME%.elf > %APPNAME%.sym
avr-size -C --mcu=atmega328p %APPNAME%.elf
avr-objdump -d -S -m avr %APPNAME%.elf > %APPNAME%.lst
goto ok

:err
if exist %APPNAME%.elf avr-size -C --mcu=atmega328p %APPNAME%.elf
echo.
pause

:ok
if exist *.o del *.o
