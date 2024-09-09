@echo off

call !clear1.bat Debug
call !clear1.bat Release

if exist *.pdb del *.pdb
if exist *.user del *.user

if exist *.ncb del *.ncb
attrib -H ET58_module.suo > nul
if exist ET58_module.suo del ET58_module.suo
