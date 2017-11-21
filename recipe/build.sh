#!/bin/bash

chmod +x configure

if [ "$(uname)" == "Darwin" ];
then
    ./configure --prefix=$PREFIX --enable-cxx --build=x86_64-apple-darwin
else
    ./configure --prefix=$PREFIX --enable-cxx
fi

make
make check
make install
