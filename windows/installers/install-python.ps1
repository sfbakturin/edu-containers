$installer = 'python-installer.exe'

$version = '3.12.4'
$arch = 'amd64'

$pythonUrl = "https://www.python.org/ftp/python/${version}/python-${version}-${arch}.exe"

Write-Host 'Downloading Python installer...';
Invoke-WebRequest -Uri $pythonUrl -OutFile $installer;

Write-Host 'Installing Python...';
Start-Process -FilePath $installer -Wait -ArgumentList @(
    '/quiet', 'InstallAllUsers=0', 'PrependPath=1', 'Include_test=0'
);

Write-Host 'Removing temporary files...';
Remove-Item -Force $installer;
