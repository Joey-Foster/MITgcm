#!/bin/bash

rm -r run/*
cd build
make Clean && \
make depend && \
make -j 3 
