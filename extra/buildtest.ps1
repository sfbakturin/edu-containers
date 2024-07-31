if ($args.Count -ne 2) {
    throw 'Illegal number of parameters'
}

$compilerName = $args[0]
$compilerVersion = $args[1]

$baseImageTag = "ltsc2019-${compilerName}${compilerVersion}"
$imageName = "$env:BASE_IMAGE_NAME:${baseImageTag}"

$containerName = 'buildtest'

# Build image.
docker build --tag "${imageName}" `
    --build-arg BUILD_TARGET_VERSION=${compilerVersion} `
    --build-arg BUILD_EXTRAS_RUN_TESTS=$env:RUN_TESTS `
    -f windows/Dockerfile .

# Test image.
docker run -t -d --name "$containerName" "$imageName"
docker container stop "$containerName"
docker cp .\testing\ "$containerName":/student
docker container restart "$containerName"
docker exec "$containerName" cmd.exe /K "powershell .\test.ps1"
