# qemu-user-static

## Binaries

* Releases: https://github.com/multiarch/qemu-user-static/releases/
* Docker hub: https://hub.docker.com/r/multiarch/qemu-user-static/

## `binfmt_misc` register

Register `qemu-*-static` for all supported processors except the current one

* `docker run --rm --privileged multiarch/qemu-user-static:register`

Same as above, but remove all registered `binfmt_misc` before

* `docker run --rm --privileged multiarch/qemu-user-static:register --reset`

## Compatible images

* https://hub.docker.com/r/multiarch/ubuntu-core/
* https://hub.docker.com/r/multiarch/debian-debootstrap/
* https://hub.docker.com/r/multiarch/ubuntu-debootstrap/
* https://hub.docker.com/r/multiarch/busybox/

---

Organizations with some (if not all) multiarch images:

* https://hub.docker.com/u/multiarch/
* https://hub.docker.com/u/scaleway/

## License

MIT
