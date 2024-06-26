#!/bin/bash

wget https://www.fftw.org/fftw-3.3.10.tar.gz && tar -xf fftw-3.3.10.tar.gz && rm fftw-3.3.10.tar.gz
cd fftw-3.3.10/ && ./configure --prefix="${EDU_FFTW}"
make -j"$(nproc --all)" && make install
cd .. && rm -rf fftw-3.3.10/
