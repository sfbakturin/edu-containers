$fftwVersion = '3.3.10'

$fftwSrc = "fftw-${fftwVersion}"
$fftwArchive = "${fftwSrc}.tar.gz"
$fftwUrl = "https://www.fftw.org/${fftwArchive}"

$fftwBuildType = $args[0]

$builddir = 'BUILD'

# Download and extract FFTW sources.
Invoke-WebRequest -Uri $fftwUrl -OutFile $fftwArchive;
tar xzvf $fftwArchive;
Remove-Item $fftwArchive;

# Set working directory to GoogleTest sources.
Push-Location "${fftwSrc}";

# Set working directory to built sources.
mkdir "${builddir}";
Push-Location "${builddir}";

# Build and install FFTW (Single precision).
cmake .. -D CMAKE_INSTALL_PREFIX="$env:EDUCONTAINER_FFTW" -D ENABLE_FLOAT=ON;
cmake --build . --target install --config "$fftwBuildType";

# Clean built.
Remove-Item -Recurse -Force *;

# Build and install FFTW (Single precision).
cmake .. -D CMAKE_INSTALL_PREFIX="$env:EDUCONTAINER_FFTW" -D ENABLE_DOUBLE=ON;
cmake --build . --target install --config "$fftwBuildType";

# Go back.
Pop-Location;
Pop-Location;

# Remove sources.
Remove-Item -Recurse -Force "${fftwSrc}";
