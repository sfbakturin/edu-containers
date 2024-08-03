$fftwVersion = '3.3.10'

$fftwSrc = "fftw-${fftwVersion}"
$fftwArchive = "${fftwSrc}.tar.gz"
$fftwUrl = "https://www.fftw.org/${fftwArchive}"

# Download and extract FFTW sources.
Invoke-WebRequest -Uri $fftwUrl -OutFile $fftwArchive;
tar xzvf $fftwArchive;
Remove-Item $fftwArchive;

# Set working directory to GoogleTest sources.
Push-Location "${fftwSrc}";

# Build and install FFTW.
cmake . -D CMAKE_INSTALL_PREFIX="$env:EDUCONTAINER_FFTW";
cmake --build . --target install --config "$env:EDUCONATINER_BUILDTYPE";

# Go back.
Pop-Location;

# Remove sources.
Remove-Item -Recurse -Force "${fftwSrc}";
