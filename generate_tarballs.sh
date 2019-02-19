#!/bin/bash -e

rm -rf releases
mkdir -p releases

cd releases

curl -fsSL "$PACKAGE_URI" | rpm2cpio - | cpio -dimv "*usr/bin*qemu-*-static"
mv ./usr/bin/* ./
rm -rf ./usr/bin

for file in *; do
    tar -czf $file.tar.gz $file;
    cp $file.tar.gz x86_64_$file.tar.gz
done
