#!/bin/bash

echo "Build and test with AddressSanitizer."
cc -Wall -Wextra -Wpedantic -O0 -ggdb -fno-sanitize-recover=all -fsanitize=address fail_asan.c -o fail_asan.exe &> build_asan.log
./fail_asan.exe || echo "Found issue with AddressSanitizer."

echo "Build and test with LeakSanitizer."
cc -Wall -Wextra -Wpedantic -O0 -ggdb -fno-sanitize-recover=all -fsanitize=leak fail_lsan.c -o fail_lsan.exe &> build_lsan.log
./fail_lsan.exe || echo "Found issue with LeakSanitizer."

echo "Build and test with ThreadSanitizer."
cc -Wall -Wextra -Wpedantic -O0 -ggdb -fno-sanitize-recover=all -fsanitize=thread fail_tsan.c -o fail_tsan.exe &> build_tsan.log
./fail_tsan.exe || echo "Found issue with ThreadSanitizer."

echo "Build and test with UndefinedBehaviorSanitizer."
cc -Wall -Wextra -Wpedantic -O0 -ggdb -fno-sanitize-recover=all -fsanitize=undefined fail_ubsan.c -o fail_ubsan.exe &> build_ubsan.log
./fail_ubsan.exe || echo "Found issue with UndefinedBehaviorSanitizer."

echo "Build and test Hello World."
cc -Wall -Wextra -Wpedantic -O0 -ggdb -fno-sanitize-recover=all -fsanitize=leak,address,undefined hello_world.c -o hello_world.exe &> build_helloworld.log
./hello_world.exe || echo "This report should not be created..."
