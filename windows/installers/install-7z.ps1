$installer = '7z-installer.msi'

$version = '2407'
$arch = 'x64'

$7zUrl = "https://www.7-zip.org/a/7z${version}-${arch}.msi"

Write-Host 'Downloading 7z MSI...';
Invoke-WebRequest -Uri $7zUrl -OutFile $installer;

Write-Host 'Installing 7z...';
Start-Process -FilePath 'msiexec.exe' -Wait -ArgumentList @(
    '/i', $installer,
    '/qn', '/norestart'
);

Write-Host 'Removing temporary files...';
Remove-Item -Force $installer;
