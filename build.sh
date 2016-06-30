#!/bin/sh

set -xe

wget -N http://ftp.fr.debian.org/debian/pool/main/q/qemu/qemu-user-static_2.6+dfsg-3_amd64.deb
dpkg -i qemu-user-static_2.6+dfsg-3_amd64.deb

