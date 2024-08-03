if ($args.Count -ne 3) {
    throw 'Illegal number of parameters'
}

$compilerName = $args[0]
$compilerVersion = $args[1]
$baseImageName = $args[2]

$baseImageTag = "ltsc2019-${compilerName}${compilerVersion}"

$imageName = "${baseImageName}:${baseImageTag}"

# Build image.
docker build --tag "${imageName}" `
    --build-arg BUILD_TARGET_VERSION=${compilerVersion} `
    --build-arg BUILD_EXTRAS_RUN_TESTS=$env:RUN_TESTS `
    -f windows/Dockerfile .

# Test image.
docker run -t -d --name buildtest "$imageName"
docker container stop buildtest
docker cp .\testing\. buildtest:/student
docker container restart buildtest
docker exec buildtest cmd.exe /K "powershell .\test.ps1"
