$installer = 'msvc-installer.exe'

$version = $env:BUILD_TARGET_VERSION
$channel = 'release'
$edition = 'buildtools'

$bootstrapperUrl = "https://aka.ms/vs/${version}/${channel}/vs_${edition}.exe"

Write-Host 'Downloading BuildTools bootstrapper...';
Invoke-WebRequest -Uri $bootstrapperUrl -OutFile $installer;

Write-Host 'Installing BuildTools...';
Start-Process -FilePath $installer -Wait -ArgumentList @(
    '--includeRecommended',
    '--add Microsoft.VisualStudio.Workload.VCTools',
    '--add Microsoft.VisualStudio.Component.VC.Llvm.ClangToolset',
    '--quiet', '--wait', '--norestart', '--nocache'
);

Write-Host 'Removing temporary files...';
Remove-Item -Force $installer;
Remove-Item -Force -Recurse 'C:\Program Files (x86)\Microsoft Visual Studio\Installer';
