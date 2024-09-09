@echo off

call !clear1.bat Debug
call !clear1.bat Release

if exist *.pdb del *.pdb
if exist *.user del *.user

if exist *.ncb del *.ncb
attrib -H GenerConst.suo > nul
if exist GenerConst.suo del GenerConst.suo
