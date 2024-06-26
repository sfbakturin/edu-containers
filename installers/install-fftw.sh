#!/bin/bash

wget https://www.fftw.org/fftw-3.3.10.tar.gz && tar -xf fftw-3.3.10.tar.gz && rm fftw-3.3.10.tar.gz
cd fftw-3.3.10/ && ./configure --prefix=/thirdparty/fftw/
make && make install
cd .. && rm -rf fftw-3.3.10/
