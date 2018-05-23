# qemu-user-static [![Build Status](https://travis-ci.org/multiarch/qemu-user-static.svg?branch=master)](https://travis-ci.org/multiarch/qemu-user-static)

![](https://raw.githubusercontent.com/multiarch/dockerfile/master/logo.jpg)

## Binaries

* Releases: https://github.com/multiarch/qemu-user-static/releases/
* Docker hub: https://hub.docker.com/r/multiarch/qemu-user-static/

## `binfmt_misc` register

Register `qemu-*-static` for all supported processors except the current one

* `docker run --rm --privileged multiarch/qemu-user-static:register`

Same as above, but remove all registered `binfmt_misc` before

* `docker run --rm --privileged multiarch/qemu-user-static:register --reset`

## Examples & articles

* Scaleway's build system:
  * https://github.com/scaleway/image-tools
  * https://github.com/scaleway/image-builder
* Release blog post: http://blog.m.42.am/post/138181251836/docker-multiarch-3-recently-i-started-the
* Introduction article: https://eyskens.me/multiarch-docker-images/
* Dockerized C benchmarks for both ARM and amd64 hardware: https://github.com/luxas/benchmark
* Standalone image example: https://github.com/meyskens/multiarch-nodejs
* RaspberryPI + haskell hacks:
  * https://github.com/TGOlson/rpi-haskell
  * https://github.com/TGOlson/rpi-haskell-classy
* Music notation software: https://github.com/musescore/MuseScore

## Compatible images

* https://hub.docker.com/r/multiarch/ubuntu-core/
* https://hub.docker.com/r/multiarch/debian-debootstrap/
* https://hub.docker.com/r/multiarch/ubuntu-debootstrap/
* https://hub.docker.com/r/multiarch/busybox/

---

Organizations with some (if not all) multiarch images:

* https://hub.docker.com/u/multiarch/
* https://hub.docker.com/u/scaleway/
* https://hub.docker.com/u/meyskens/

## License

MIT
