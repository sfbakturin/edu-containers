# edu-containers

This repository stores configurations of Linux containers developed for future educational purposes using C/C++. The images provide pre-installed applications and pre-built libraries to use.

> [!WARNING]
> The commands and scripts below are described *exclusively* for these images and are not guaranteed to work for other images.

## Quick Start

Build the container image with the following required arguments:

* **COMPILER_NAME** - C compiler, suppored: `gcc`, `clang`;
* **COMPILER_NAMEXX** - C++ compiler, supported: `g++`, `clang++` (don't mess `gcc` with `clang++` and `g++` with `clang`, it will break everything);
* **COMPILER_VERSION** - compiler version, depends on selected compiler.

Example:

```bash
docker build --tag "educontainer" --build-arg COMPILER_NAME=clang --build-arg COMPILER_NAMEXX=clang++ --build-arg COMPILER_VERSION=18 .
```

Copy the student files to the `/student` working directory and run the build script:

```bash
python3 compile.py --name=student.exe --build-type=release
```

Check the student's solution.

## `compile.py`

[`compile.py`](compile-app/compile.py) is a script designed to automate the generation of a build command and linking a program with supported libraries. After generating the command, the script immediately starts the build.

Build configuration is done through flags in the following format: **--\<name\>=\<value\>** or **--\<name\>=\<value\>,\<value\>,...,\<value\>**.

Required flags:

* **name** (1) - name of the executable output file;
* **build-type** (1) - build optimizations, suppored: *release*, *debug*;

Optional flags:

* **include-libraries** (many) - adds the library to the library search path and include search path (with the `isystem` flag);
* **link-libraries** (many) - adds libraries for subsequent linking (accepts the full name of the library);
* **use-sanitizer** (1) - sets sanitizer flags;
* **std** (1) - sets the flag of the standard used;
* **add-compile-flags** (many) - adds a compilation flag "*as is*", does not require "-";
* **add-linkage-flags** (many) - adds a linking flag "*as is*".

Example:

```bash
python3 compile.py --name=dummy.out --std=c++20 --build-type=release --include-libraries=GoogleTest --link-libraries=gtest
```

At the beginning of the launch, the script is initialized with configuration parameters in YAML format, located in the [`.compileconfig`](compile-app/.compileconfig) directory (in the current or home). The directory values (such as `includedir`) ​​can be either a path (it must exist) or an environment variable in which the path values ​​are written (must also exist).

## Supported libraries

Below is a list of supported libraries that are built into the system during image configuration. The names of environment variables are provided as file paths.

| **Name**   | **Version** | **Basedir**      | **Includedir**           | **Librarydir**           |
|:-----------|:------------|:-----------------|:-------------------------|:-------------------------|
| zlib       | 1.3.1       | `EDU_ZLIB`       | `EDU_ZLIB_INCLUDE`       | `EDU_ZLIB_LIBRARY`       |
| GoogleTest | 1.14.0      | `EDU_GOOGLETEST` | `EDU_GOOGLETEST_INCLUDE` | `EDU_GOOGLETEST_LIBRARY` |
| FFmpeg     | 6.1         | `EDU_FFMPEG`     | `EDU_FFMPEG_INCLUDE`     | `EDU_FFMPEG_LIBRARY`     |
| FFTW       | 3.3.10      | `EDU_FFTW`       | `EDU_FFTW_INCLUDE`       | `EDU_FFTW_LIBRARY`       |
| libdeflate | 1.20        | `EDU_LIBDEFLATE` | `EDU_LIBDEFLATE_INCLUDE` | `EDU_LIBDEFLATE_LIBRARY` |
