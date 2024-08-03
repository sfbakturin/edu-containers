$zlibVersion = 'v1.3.1'

$zlibUrl = 'https://github.com/madler/zlib.git'
$zlibSrc = 'zlib-src'

$zlibBuildType = $args[0]

# Download ZLIB sources.
git clone "${zlibUrl}" -b "${zlibVersion}" "${zlibSrc}";

# Set working directory to ZLIB sources.
Push-Location "${zlibSrc}";

# Build and install ZLIB.
cmake . -D CMAKE_INSTALL_PREFIX="$env:EDUCONTAINER_ZLIB";
cmake --build . --target install --config "$zlibBuildType";

# Go back.
Pop-Location;

# Remove sources.
Remove-Item -Recurse -Force "${zlibSrc}";
