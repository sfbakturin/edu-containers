$gtestVersion = 'v1.14.0'

$gtestUrl = 'https://github.com/google/googletest.git'
$gtestSrc = 'gtest-src'

# Download GoogleTest sources.
git clone "${gtestUrl}" -b "${gtestVersion}" "${gtestSrc}";

# Set working directory to GoogleTest sources.
Push-Location "${gtestSrc}";

# Build and install GoogleTest.
cmake . -D CMAKE_INSTALL_PREFIX="$env:EDUCONTAINER_GOOGLETEST";
cmake --build . --target install --config Release;

# Go back.
Pop-Location;

# Remove sources.
Remove-Item -Recurse -Force "${gtestSrc}";
