$binRoot = $(Split-Path -parent $MyInvocation.MyCommand.Definition)
$name  = "guidgen-console"
$version = "2.0.0.3"

$md5_net2_0 = "2A20DC1D8CB5FBDFB47AB20E2BB85B3D"
$md5_net3_5 = "49BD98617456F28906445625261C1F01"
$md5_net4_0 = "B65305EF5AAFE012C37E303FC26B100E"
$md5_net4_5_2 = "5F63C484E41CFBA4C47440D81D1D8C67"
$md5_net4_6_1 = "731F952D1B56603EC234D5576D34E41E"
$md5_root = "731F952D1B56603EC234D5576D34E41E"

$local = $true

if($local) {
	$rooturl = "" #local
	$rooturl = [System.Uri]$rooturl
} else {
	$rooturl = "https://cdn.rawgit.com/michaelmcdaniel/GuidgenConsole/master/Binaries/versions/$version"
}
$url = "$rooturl/guidgen.exe" #default as latest
$checksum = $rootmd5

Write-Host "Determining version to install..."
$installVersion = ""
$ndpDirectory = 'hklm:\SOFTWARE\Microsoft\NET Framework Setup\NDP\'

if ($pathToLatest -eq $binRoot -and (Test-Path "$ndpDirectory\v2.0.50727")) { # .NET 2
	Write-Debug ".NET version 2.0 is available"
    $url = "$rooturl/NET2_0/guidgen.exe"
	$checksum = $md5_net2_0
	$installVersion = "guidgen.exe for .NET version 2.0"
} 
if (Test-Path "$ndpDirectory\v3.0") { # .NET 3
	Write-Debug ".NET version 3.0 is available"
}
if ($pathToLatest -eq $binRoot -and (Test-Path "$ndpDirectory\v3.5")) { # .NET 3.5
	Write-Debug ".NET version 3.5 is available"
    $url = "$rooturl/NET3_5/guidgen.exe"
	$checksum = $md5_net3_5
	$installVersion = "guidgen.exe for .NET version 3.5"
}
if ($pathToLatest -eq $binRoot -and (Test-Path "$ndpDirectory\v4")) { # .NET 4
	Write-Debug ".NET version 4.0 is available"
    $url = "$rooturl/NET4_0/guidgen.exe"
	$checksum = $md5_net4_0
	$installVersion = "guidgen.exe for .NET version 4.0"
}
if (Test-Path "$ndpDirectory\v4\Full") { # .NET 4.5+
    $rv = (Get-ItemProperty "$ndpDirectory\v4\Full" -name Release).Release
    switch([String]$rv) {
        '378389' { Write-Debug ".NET version 4.5 is available"; break; } #4.5
        '378758' { Write-Debug ".NET version 4.5.1 is available"; break; } #4.5.1 (win81/ws12r2)
        '378675' { Write-Debug ".NET version 4.5.1 is available"; break; } #4.5.1
        '379893' { Write-Debug ".NET version 4.5.2 is available";  $url = "$rooturl/NET4_5_2/guidgen.exe"; $checksum = $md5_net4_5_2; $installVersion = "guidgen.exe for .NET version 4.5.2"; break; } #4.5.2
        '393295' { Write-Debug ".NET version 4.6 is available"; break; } #4.6 (win10)
        '393297' { Write-Debug ".NET version 4.6 is available"; break; } #4.6
        '394254' { Write-Debug ".NET version 4.6.1 is available"; $url = "$rooturl/NET4_6_1/guidgen.exe"; $checksum = $md5_net4_6_1; $installVersion = "guidgen.exe for .NET version 4.6.1"; break; } #4.6.1 (win10)
        '394271' { Write-Debug ".NET version 4.6.1 is available"; $url = "$rooturl/NET4_6_1/guidgen.exe"; $checksum = $md5_net4_6_1; $installVersion = "guidgen.exe for .NET version 4.6.1"; break; } #4.6.1
    }
}

$filePath = ([System.IO.FileInfo](join-path $binRoot "..\guidgen.exe")).FullName
Write-Host "Downloading $installVersion"
Write-Host "  from`: $url"
write-host "  to`: $filePath"

Get-ChocolateyWebFile -packageName $name -fileFullPath $filePath -url $url -checksum $checksum -checksumType "md5"
