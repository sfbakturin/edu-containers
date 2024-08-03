$fftwVersion = '3.3.10'

$fftwSrc = "fftw-${fftwVersion}"
$fftwArchive = "${fftwSrc}.tar.gz"
$fftwUrl = "https://www.fftw.org/${fftwArchive}"

$fftwBuildType = $args[0]

# Download and extract FFTW sources.
Invoke-WebRequest -Uri $fftwUrl -OutFile $fftwArchive;
tar xzvf $fftwArchive;
Remove-Item $fftwArchive;

# Set working directory to GoogleTest sources.
Push-Location "${fftwSrc}";

# Build and install FFTW.
cmake . -D CMAKE_INSTALL_PREFIX="$env:EDUCONTAINER_FFTW" -D ENABLE_FLOAT=ON -D ENABLE_LONG_DOUBLE=ON -D ENABLE_QUAD_PRECISION=ON;
cmake --build . --target install --config "$fftwBuildType";

# Go back.
Pop-Location;

# Remove sources.
Remove-Item -Recurse -Force "${fftwSrc}";
