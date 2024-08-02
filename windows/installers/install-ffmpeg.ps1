$ffmpegVersion = '6.1.1'

$ffmpegChannel = 'releases'
$ffmpegSrc = "ffmpeg-${ffmpegVersion}-full_build-shared"
$ffmpegZip = "${ffmpegSrc}.zip"

$ffmpegUrl = "https://github.com/GyanD/codexffmpeg/${ffmpegChannel}/download/${ffmpegVersion}/${ffmpegZip}"

# Download and extract FFmpeg builds.
Invoke-WebRequest -Uri $ffmpegUrl -OutFile $ffmpegZip;
Expand-Archive $ffmpegZip;

# Set working directory to FFmpeg builds.
Push-Location $ffmpegSrc;
Push-Location $ffmpegSrc;

# Copy files from include/ and lib/.
Copy-Item include -Destination "$env:EDUCONTAINER_FFMPEG_INCLUDE" -Recurse;
Copy-Item lib -Destination "$env:EDUCONTAINER_FFMPEG_LIBRARY" -Recurse;
Copy-Item bin -Destination "$env:EDUCONTAINER_FFMPEG_BINARY" -Recurse;

# Go back.
Pop-Location;
Pop-Location;

# Remove builds.
Remove-Item -Force $ffmpegZip;
Remove-Item -Recurse -Force $ffmpegSrc;
