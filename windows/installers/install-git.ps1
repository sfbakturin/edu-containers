$installer = 'git-installer.exe'

$channel = 'releases'
$version = '2.45.2'
$versionFull = "v${version}.windows.1"
$arch = '64-bit'

$gitUrl = "https://github.com/git-for-windows/git/${channel}/download/${versionFull}/Git-${version}-${arch}.exe"

Write-Host 'Downloading Git installer...';
Invoke-WebRequest -Uri $gitUrl -OutFile $installer;

Write-Host 'Installing Git...';
Start-Process -FilePath $installer -Wait -ArgumentList @(
    '/VERYSILENT', '/SUPPRESSMSGBOXES'
);

Write-Host 'Removing temporary files...';
Remove-Item -Force $installer;
