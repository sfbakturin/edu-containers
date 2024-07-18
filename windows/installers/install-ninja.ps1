$name = 'ninja'
$executable = "${name}.exe"

$version = 'v1.12.1'
$src = 'ninja-win'
$zip = "${src}.zip"
$channel = 'releases'

$ninjaUrl = "https://github.com/ninja-build/ninja/${channel}/download/${version}/${zip}"

Write-Host 'Downloading Ninja executable...';
Invoke-WebRequest -Uri $ninjaUrl -OutFile $zip;

Write-Host 'Extracting Ninja zip...';
Expand-Archive $zip;

mkdir "${name}";
Copy-Item -Path "${src}/${executable}" -Destination "${name}";
setx /M path "$Env:PATH;C:\${name}";

Write-Host 'Removing temporary files...';
Remove-Item -Force $zip;
Remove-Item -Force -Recurse $src;
