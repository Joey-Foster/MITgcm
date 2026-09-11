#!/bin/bash

rm -r run/*
cd build
make clean && \
make -j 3 
