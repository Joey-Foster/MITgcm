#!/bin/bash

cd ../run
ln -s ../input/* .
cp ../build/mitgcmuv .
./mitgcmuv > output.txt
