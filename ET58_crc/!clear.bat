@echo off

call !clear1.bat Debug
call !clear1.bat Release

if exist *.pdb del *.pdb
if exist *.user del *.user

if exist *.ncb del *.ncb
attrib -H ET58_crc.suo > nul
if exist ET58_crc.suo del ET58_crc.suo
