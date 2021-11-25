Param($src, $dst)
# powershell "$s=(New-Object -COM WScript.Shell).CreateShortcut('%userprofile%\Start Menu\Programs\Startup\%~n0.lnk');$s.TargetPath='%~f0';$s.Save()"
# Write-Host $src
# Write-Host $dst
#
$srcd=Split-Path $src -Parent
# Write-Host $srcd
$s=(New-Object -COM WScript.Shell).CreateShortcut("$dst");
$s.TargetPath="$src";
$s.WorkingDirectory="$srcd"
$s.Save();
