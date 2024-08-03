$libdeflateVersion = 'v1.20'

$libdeflateUrl = 'https://github.com/ebiggers/libdeflate'
$libdeflateSrc = 'libdeflate-src'

$libdeflateBuildType = $args[0]

# Download libdeflate sources.
git clone "${libdeflateUrl}" -b "${libdeflateVersion}" "${libdeflateSrc}";

# Set working directory to libdeflate sources.
Push-Location "${libdeflateSrc}";

# Build and install libdeflate.
cmake . -D CMAKE_INSTALL_PREFIX="$env:EDUCONTAINER_LIBDEFLATE" -D ZLIB_ROOT="$env:EDUCONTAINER_ZLIB";
cmake --build . --target install --config "$libdeflateBuildType";

# Go back.
Pop-Location;

# Remove sources.
Remove-Item -Recurse -Force "${libdeflateSrc}";
