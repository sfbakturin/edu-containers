if ($args.Count -ne 2) {
    throw 'Illegal number of parameters'
}

$compilerName = $args[0]
$compilerVersion = $args[1]

$baseImageTag = "ltsc2019-${compilerName}${compilerVersion}"
$imageName = "$env:BASE_IMAGE_NAME:${baseImageTag}"

$containerName='buildtest'

# Build image.
docker build --tag "${imageName}" `
    --build-arg BUILD_TARGET_VERSION=${compilerVersion} `
    --build-arg BUILD_EXTRAS_RUN_TESTS=$env:RUN_TESTS `
    -f windows/Dockerfile .

# Test image.
# FIXME: Should run tests only if RUN_TESTS is true.
docker run -t -d --name "$containerName" "$imageName"
docker cp testing/. "$containerName":/student
docker exec "$containerName" powershell test.ps1
