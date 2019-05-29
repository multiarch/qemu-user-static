# **qemu-user-static**

[![License](https://img.shields.io/github/license/multiarch/qemu-user-static.svg?style=flat-square)](./LICENSE) [![Build Status](https://img.shields.io/travis/multiarch/qemu-user-static/master.svg?style=flat-square&logo=travis)](https://travis-ci.org/multiarch/qemu-user-static/builds) [![Releases](https://img.shields.io/github/commits-since/multiarch/qemu-user-static/latest.svg?style=flat-square)](https://github.com/multiarch/qemu-user-static/releases) [![Docker Hub](https://img.shields.io/docker/pulls/multiarch/qemu-user-static.svg?style=flat-square)](https://hub.docker.com/r/multiarch/qemu-user-static/)

<p align="center">
  <img src="https://raw.githubusercontent.com/multiarch/dockerfile/master/logo.jpg" width="550"/>
</p>


## `binfmt_misc` register

Register `qemu-*-static` for all supported processors except the current one

* `docker run --rm --privileged multiarch/qemu-user-static:register`

Same as above, but remove all registered `binfmt_misc` before

* `docker run --rm --privileged multiarch/qemu-user-static:register --reset`

---

## Supported host architectures

* x86_64

Currently qemu-user-static is not available on other host architectures such as aarch64.
Run `uname -m` to check it on your environment.

## Examples & articles

* Scaleway's build system:
  * [scaleway/image-tools](https://github.com/scaleway/image-tools)
  * [scaleway/image-builder](https://github.com/scaleway/image-builder)
* [Docker + multiarch = <3](https://manfredtouron.com/2016/01/28/docker-multiarch/) (Release blog post)
* Introduction article: [eyskens.me/multiarch-docker-images](https://eyskens.me/multiarch-docker-images/)
* Dockerized C benchmarks for both ARM and amd64 hardware: [luxas/benchmark](https://github.com/luxas/benchmark)
* Standalone image example: [meyskens/multiarch-nodejs](https://github.com/meyskens/multiarch-nodejs)
* RaspberryPI + haskell hacks:
  * [TGOlson/rpi-haskell](https://github.com/TGOlson/rpi-haskell)
  * [TGOlson/rpi-haskell-classy](https://github.com/TGOlson/rpi-haskell-classy)
* Music notation software: [musescore/MuseScore](https://github.com/musescore/MuseScore)

## Compatible images

* [hub.docker.com/r/multiarch/](https://hub.docker.com/r/multiarch/)
  * alpine: [Docker Hub](https://hub.docker.com/r/multiarch/alpine/), [GitHub](https://github.com/multiarch/alpine)
  * debian-debootstrap: [Docker Hub](https://hub.docker.com/r/multiarch/debian-debootstrap/), [GitHub](https://github.com/multiarch/debian-debootstrap)
  * ubuntu-core: [Docker Hub](https://hub.docker.com/r/multiarch/ubuntu-core/), [GitHub](https://github.com/multiarch/ubuntu-core)
  * ubuntu-debootstrap: [Docker Hub](https://hub.docker.com/r/multiarch/ubuntu-debootstrap/), [GitHub](https://github.com/multiarch/ubuntu-debootstrap)
  * fedora: [Docker Hub](https://hub.docker.com/r/multiarch/fedora/), [GitHub](https://github.com/multiarch/fedora)
  * centos: [Docker Hub](https://hub.docker.com/r/multiarch/centos/), [GitHub](https://github.com/multiarch/centos)
  * busybox: [Docker Hub](https://hub.docker.com/r/multiarch/busybox/), [GitHub](https://github.com/multiarch/busybox)

Organizations with some (if not all) multiarch images:

* [hub.docker.com/u/multiarch](https://hub.docker.com/u/multiarch/)
* [hub.docker.com/u/scaleway](https://hub.docker.com/u/scaleway/)
* [hub.docker.com/u/meyskens](https://hub.docker.com/u/meyskens/)

