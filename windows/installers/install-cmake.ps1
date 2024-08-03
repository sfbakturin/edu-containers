$installer = 'cmake-installer.msi'

$channel = 'releases'
$version = '3.29.6'
$arch = 'x86_64'

$cmakeUrl = "https://github.com/Kitware/CMake/${channel}/download/v${version}/cmake-${version}-windows-${arch}.msi"

Write-Host 'Downloading CMake MSI...';
Invoke-WebRequest -Uri $cmakeUrl -OutFile $installer;

Write-Host 'Installing CMake...';
Start-Process -FilePath 'msiexec.exe' -Wait -ArgumentList @(
    '/i', $installer,
    'ALLUSERS=1', 'ADD_CMAKE_TO_PATH=System', '/qn'
);

Write-Host 'Removing temporary files...';
Remove-Item -Force $installer;
