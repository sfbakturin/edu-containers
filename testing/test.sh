#!/bin/bash

set -euo pipefail

echo "Hello World on C"
cp tests/test_helloworld.c .
python3 compile.py --name=hello_world.exe --build-type=Release
rm test_helloworld.c
./hello_world.exe

echo "=============================="

echo "Hello World on C++"
cp tests/test_helloworld.cpp .
python3 compile.py --name=hello_world2.exe --build-type=Release
rm test_helloworld.cpp
./hello_world2.exe

echo "=============================="

echo "Basic GoogleTest"
cp tests/test_googletest.cpp .
python3 compile.py --name=google.exe --build-type=Release --include-libraries=GoogleTest --link-libraries=gtest
rm test_googletest.cpp
./google.exe
