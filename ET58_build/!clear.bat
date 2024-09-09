@echo off

call !clear1.bat Debug
call !clear1.bat Release

if exist *.pdb del *.pdb
if exist *.user del *.user

if exist *.ncb del *.ncb
attrib -H ET58_build.suo > nul
if exist ET58_build.suo del ET58_build.suo
