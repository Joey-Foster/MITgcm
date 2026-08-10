#!/bin/bash

cd run
ln -s ../input/* .
cp ../build/mitgcmuv .
time ./mitgcmuv > output.txt
