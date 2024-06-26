#!/bin/bash

echo "Build and test with AddressSanitizer."
cc -Wall -Wextra -Wpedantic -O0 -ggdb -fno-sanitize-recover=all -fsanitize=address fail_asan.c -o fail_asan.exe &> build_asan.log
ASAN_OPTIONS=log_path=asan ./fail_asan.exe || echo "Created report in asan.pid."

echo "Build and test with LeakSanitizer."
cc -Wall -Wextra -Wpedantic -O0 -ggdb -fno-sanitize-recover=all -fsanitize=leak fail_lsan.c -o fail_lsan.exe &> build_lsan.log
LSAN_OPTIONS=log_path=lsan ./fail_lsan.exe || echo "Created report in lsan.pid."

echo "Build and test with ThreadSanitizer."
cc -Wall -Wextra -Wpedantic -O0 -ggdb -fno-sanitize-recover=all -fsanitize=thread fail_tsan.c -o fail_tsan.exe &> build_tsan.log
TSAN_OPTIONS=log_path=tsan ./fail_tsan.exe || echo "Created report in tsan.pid."

echo "Build and test with UndefinedBehaviorSanitizer."
cc -Wall -Wextra -Wpedantic -O0 -ggdb -fno-sanitize-recover=all -fsanitize=undefined fail_ubsan.c -o fail_ubsan.exe &> build_ubsan.log
UBSAN_OPTIONS=log_path=ubsan ./fail_ubsan.exe || echo "Created report in ubsan.pid."

echo "Build and test Hello World."
cc -Wall -Wextra -Wpedantic -O0 -ggdb -fno-sanitize-recover=all -fsanitize=leak,address,undefined hello_world.c -o hello_world.exe &> build_helloworld.log
./hello_world.exe || echo "This report should not be created..."
