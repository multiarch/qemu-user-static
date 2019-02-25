#!/bin/bash -e

rm -rf releases
mkdir -p releases
# find . -regex './qemu-.*' -not -regex './qemu-system-.*' -exec cp {} releases \;
cp ./usr/bin/qemu-*-static releases/
cd releases/
for file in *; do
    tar -czf $file.tar.gz $file;
    cp $file.tar.gz x86_64_$file.tar.gz
done
