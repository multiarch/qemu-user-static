#!/bin/sh

set -xe

wget -N http://ftp.fr.debian.org/debian/pool/main/q/qemu/qemu-user-static_2.7+dfsg-3+b1_amd64.deb
dpkg -i qemu-user-static_2.7+dfsg-3+b1_amd64.deb

