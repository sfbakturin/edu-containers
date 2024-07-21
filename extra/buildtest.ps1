if ($args.Count -ne 2) {
    throw 'Illegal number of parameters'
}

$compilerName = $args[0]
$systemVersion = $args[1]

$baseImageTag = "ltsc${systemVersion}-${compilerName}"
$imageName = "$env:BASE_IMAGE_NAME:${baseImageTag}"

# Build image.
docker build --tag "${imageName}" `
    --build-arg RUN_TESTS=$env:BUILD_EXTRAS_RUN_TESTS `
    -f windows/Dockerfile .

# Test image.
# TODO: Implement testing images for Windows.
