# qemu-user-static

[![License](https://img.shields.io/github/license/multiarch/qemu-user-static.svg?style=flat-square)](./LICENSE) ![actions](https://github.com/multiarch/qemu-user-static/workflows/actions/badge.svg) [![Releases](https://img.shields.io/github/commits-since/multiarch/qemu-user-static/latest.svg?style=flat-square)](https://github.com/multiarch/qemu-user-static/releases) [![Docker Hub](https://img.shields.io/docker/pulls/multiarch/qemu-user-static.svg?style=flat-square)](https://hub.docker.com/r/multiarch/qemu-user-static/)

![](https://raw.githubusercontent.com/multiarch/dockerfile/master/logo.jpg)

**multiarch/qemu-user-static** is to enable an execution of different multi-architecture containers by QEMU [<sup>1</sup>](#ref-1) and binfmt_misc [<sup>2</sup>](#ref-2).
Here are examples with Docker [<sup>3</sup>](#ref-3).

## Getting started

```
$ uname -m
x86_64

$ docker run --rm -t arm64v8/ubuntu uname -m
standard_init_linux.go:211: exec user process caused "exec format error"

$ docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

$ docker run --rm -t arm64v8/ubuntu uname -m
aarch64
```

It works on many architectures and OS container images.

```
$ docker run --rm -t arm32v6/alpine uname -m
armv7l

$ docker run --rm -t ppc64le/debian uname -m
ppc64le

$ docker run --rm -t s390x/ubuntu uname -m
s390x

$ docker run --rm -t arm64v8/fedora uname -m
aarch64

$ docker run --rm -t arm32v7/centos uname -m
armv7l

$ docker run --rm -t ppc64le/busybox uname -m
ppc64le

$ docker run --rm -t i386/ubuntu uname -m
x86_64
```

Podman [<sup>4</sup>](#ref-4) also works.

```
$ sudo podman run --rm --privileged multiarch/qemu-user-static --reset -p yes

$ podman run --rm -t arm64v8/fedora uname -m
aarch64
```

Singularity [<sup>5</sup>](#ref-5) also works.

```
$ sudo singularity run docker://multiarch/qemu-user-static --reset -p yes

$ singularity run --cleanenv docker://arm64v8/fedora uname -m
aarch64
```

## Usage

### multiarch/qemu-user-static images

multiarch/qemu-user-static images are managed on the [Docker Hub](https://hub.docker.com/r/multiarch/qemu-user-static/) container repository.
The images have below tags.

**Images**

1. `multiarch/qemu-user-static` image
2. `multiarch/qemu-user-static:$version` images
3. `multiarch/qemu-user-static:$from_arch-$to_arch` images
4. `multiarch/qemu-user-static:$from_arch-$to_arch-$version` images
5. `multiarch/qemu-user-static:$to_arch` images
6. `multiarch/qemu-user-static:$to_arch-$version` images
7. `multiarch/qemu-user-static:register` image

**Variables**

* `$version`: Based QEMU's version.
* `$from_arch`: Host architecture
* `$to_arch`: Guest architecture

**Description**

* `multiarch/qemu-user-static` image container includes both a register script to register binfmt_misc entries and all the `/usr/bin/qemu-$arch-static` binary files in the container in it. `multiarch/qemu-user-static` image is an alias of the latest version of `multiarch/qemu-user-static:$version` images.
* `multiarch/qemu-user-static:$to_arch` images are aliases of `multiarch/qemu-user-static:x86_64-$to_arch`. `multiarch/qemu-user-static:$to_arch` images only include the `$to_arch`'s `/usr/bin/qemu-$to_arch-static` binary file in it. `multiarch/qemu-user-static:$to_arch` image is an alias of the latest version of `multiarch/qemu-user-static:$to_arch-$version` images.
* `multiarch/qemu-user-static:register` image has only the register script binfmt_misc entries.

`multiarch/qemu-user-static` and `multiarch/qemu-user-static:register` images execute the register script that registers below kind of `/proc/sys/fs/binfmt_misc/qemu-$arch` files for all supported processors except the current one in it when running the container. See binfmt_misc manual [2] for detail of the files.
As the `/proc/sys/fs/binfmt_misc` are common between host and inside of container, the register script modifies the file on host.

```
$ cat /proc/sys/fs/binfmt_misc/qemu-$arch
enabled
interpreter /usr/bin/qemu-$arch-static
flags: F
offset 0
magic 7f454c460201010000000000000000000200b700
mask ffffffffffffff00fffffffffffffffffeffffff
```

The `--reset` option is implemented at the register script that executes `find /proc/sys/fs/binfmt_misc -type f -name 'qemu-*' -exec sh -c 'echo -1 > {}' \;` to remove binfmt_misc entry files before register the entry.
When same name's file `/proc/sys/fs/binfmt_misc/qemu-$arch` exists, the register command is failed with an error message "sh: write error: File exists".

```
$ docker run --rm --privileged multiarch/qemu-user-static [--reset][--help][-p yes][options]
```

On below image, we can not specify `-p yes` (`--persistent yes`) option. Because an interpreter's existance is checked when registering a binfmt_misc entry. As the interpreter does not exist in the container, the register script finishes with an error.

```
$ docker run --rm --privileged multiarch/qemu-user-static:register [--reset][--help][options]
```

Then the register script executes QEMU's [scripts/qemu-binfmt-conf.sh](https://github.com/qemu/qemu/blob/master/scripts/qemu-binfmt-conf.sh) script with options.
You can check `usage()` in the file about the options.

```
Usage: qemu-binfmt-conf.sh [--qemu-path PATH][--debian][--systemd CPU]
                           [--help][--credential yes|no][--exportdir PATH]
                           [--persistent yes|no][--qemu-suffix SUFFIX]
       Configure binfmt_misc to use qemu interpreter
       --help:        display this usage
       --qemu-path:   set path to qemu interpreter ($QEMU_PATH)
       --qemu-suffix: add a suffix to the default interpreter name
       --debian:      don't write into /proc,
                      instead generate update-binfmts templates
       --systemd:     don't write into /proc,
                      instead generate file for systemd-binfmt.service
                      for the given CPU. If CPU is "ALL", generate a
                      file for all known cpus
       --exportdir:   define where to write configuration files
                      (default: $SYSTEMDDIR or $DEBIANDIR)
       --credential:  if yes, credential and security tokens are
                      calculated according to the binary to interpret
       --persistent:  if yes, the interpreter is loaded when binfmt is
                      configured and remains in memory. All future uses
                      are cloned from the open file.
```

You can run `/usr/bin/qemu-$arch-static` binary file in the container.

```
$ docker run --rm -t multiarch/qemu-user-static:x86_64-aarch64 /usr/bin/qemu-aarch64-static -help
usage: qemu-aarch64 [options] program [arguments...]
Linux CPU emulator (compiled for aarch64 emulation)
...

$ docker run --rm -t multiarch/qemu-user-static:x86_64-aarch64 /usr/bin/qemu-aarch64-static -version
qemu-aarch64 version 4.0.0 (qemu-4.0.0-5.fc31)
Copyright (c) 2003-2019 Fabrice Bellard and the QEMU Project developers


$ docker run --rm -t multiarch/qemu-user-static:aarch64 /usr/bin/qemu-aarch64-static -help
usage: qemu-aarch64 [options] program [arguments...]
Linux CPU emulator (compiled for aarch64 emulation)
...

$ docker run --rm -t multiarch/qemu-user-static:aarch64 /usr/bin/qemu-aarch64-static -version
qemu-aarch64 version 4.0.0 (qemu-4.0.0-5.fc31)
Copyright (c) 2003-2019 Fabrice Bellard and the QEMU Project developers
```

`multiarch/qemu-user-static:$from_arch-$to_arch` images are used with `multiarch/qemu-user-static:register` image.
Because when the binfmt_misc entry is registered without `-p` option, the interpreter needs to be put in the container.

```
$ docker run --rm --privileged multiarch/qemu-user-static:register --reset

$ docker build --rm -t "test/integration/ubuntu" -<<EOF
FROM multiarch/qemu-user-static:x86_64-aarch64 as qemu
FROM arm64v8/ubuntu
COPY --from=qemu /usr/bin/qemu-aarch64-static /usr/bin
EOF

$ docker run --rm -t "test/integration/ubuntu" uname -m
aarch64
```

If you have `qemu-$arch-static` binary files on your local environment, you can set it to the container by `docker -v` volume mounted file.

```
$ docker run --rm --privileged multiarch/qemu-user-static:register --reset

$ docker run --rm -t arm64v8/ubuntu uname -m
standard_init_linux.go:211: exec user process caused "no such file or directory"

$ docker run --rm -t -v /usr/bin/qemu-aarch64-static:/usr/bin/qemu-aarch64-static arm64v8/ubuntu uname -m
aarch64
```

### multiarch compatible images [DEPRECATED]

The concept of "compatible images" are deprecated because **multiarch/qemu-user-static** can build and run standard multi-architecture container images without the multiarch compatible images now. But you can refer the document [Compatible images](docs/compatible_images.md).

The compatible image is the one to add `/usr/bin/qemu-$arch-static` binary inside of the container based on the standard arch specific container.
Last time, we could not register binfmt_misc entry with `flags: F` (persistent option).
When `flags: F` was not set, the interpreter always needed to be existed inside of the container to run the arch container.

## Contributing

We encourage you to contribute to **multiarch/qemu-user-static**! Please check out the [Contributing to multiarch/qemu-user-static guide](CONTRIBUTING.md) for guidelines about how to proceed.

See [Developers guide](docs/developers_guide.md) for detail.

## Supported host architectures

* x86_64

Currently qemu-user-static is not available on other host architectures such as aarch64.
Run `uname -m` to check it on your environment.

## Examples & articles

Please note that some examples using compatible images are deprecated.

See [Examples & articles](docs/examples.md).

## References

* <a id="ref-1" href="#ref-1">[1]</a> QEMU: https://www.qemu.org/
* <a id="ref-2" href="#ref-2">[2]</a> binfmt_misc: https://www.kernel.org/doc/html/latest/admin-guide/binfmt-misc.html
* <a id="ref-3" href="#ref-3">[3]</a> Docker: https://www.docker.com/
* <a id="ref-4" href="#ref-4">[4]</a> Podman: https://podman.io/
* <a id="ref-5" href="#ref-5">[5]</a> Singularity: https://sylabs.io/singularity/
