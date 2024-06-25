#!/bin/bash

wget https://apt.llvm.org/llvm.sh
bash llvm.sh ${COMPILER_VERSION}
rm llvm.sh
