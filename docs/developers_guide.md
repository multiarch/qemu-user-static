# Developers guide

We provide information to understand this system in this document.

## Technology overview

### qemu-user-static

qemu-user-static is a collection of `qemu-$arch-static` "static" binary files that emulates application process (QEMU "user" mode) and binfmt_misc related files. [1]
In this system, Fedora project's qemu-user-static RPM is used as the input data. qemu-user-static RPM is sub package of qemu RPM. [2]

`qemu-$arch-static` file is just an interpreter to run the archtecture specfic binary. Below is an example to run aarch64 specifc binary `bin/hello-aarch64` on `qemu-aarch64-static`.

```
$ uname -m
x86_64

$ file bin/hello-aarch64
bin/hello-aarch64: ELF 64-bit LSB executable, ARM aarch64, version 1 (GNU/Linux), statically linked, BuildID[sha1]=fa19c63e3c60463e686564eeeb0937959bd6f559, for GNU/Linux 3.7.0, not stripped, too many notes (256)

$ bin/hello-aarch64
bash: bin/hello-aarch64: cannot execute binary file: Exec format error

$ qemu-aarch64-static bin/hello-aarch64
Hello World!
```

`qemu-$cpu-static` can run the architecture specific binary.


### qemu-user-static and binfmt_misc

qemu-user-static becomes powerful when it is used with binfmt_misc [3].
If you are interested in the C language level manual, see [4].

Here is an example of the most typical and recommended way to run different architecture's container.
In this example, aarch64 (ARM 64-bit) container are executed on host architecture x86_64.
The example shows what the container image is doing.

```
$ uname -m
x86_64

$ ls /proc/sys/fs/binfmt_misc/qemu-aarch64
ls: cannot access '/proc/sys/fs/binfmt_misc/qemu-aarch64': No such file or directory

$ docker run --rm -t arm64v8/ubuntu uname -m
standard_init_linux.go:211: exec user process caused "exec format error"

$ docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

$ ls /proc/sys/fs/binfmt_misc/qemu-aarch64
/proc/sys/fs/binfmt_misc/qemu-aarch64

$ cat /proc/sys/fs/binfmt_misc/qemu-aarch64
enabled
interpreter /usr/bin/qemu-aarch64-static
flags: F
offset 0
magic 7f454c460201010000000000000000000200b700
mask ffffffffffffff00fffffffffffffffffeffffff

$ docker run --rm -t arm64v8/ubuntu uname -m
aarch64
```

In this system, understanding the difference of the behavior of 2 patterns of flags: `flags: ` (empty flag) and `flags: F` is important.
According to [3], the actual operation and behavior are as follows.

* `# echo ":$name:$type:$offset:$magic:$mask:$interpreter:$flags" > /proc/sys/fs/binfmt_misc/register` to add a binary format entry.
* `# echo -1 > /proc/sys/fs/binfmt_misc/qemu-$arch` to remove a qemu binary format entry.
* If the entry file's `flags` is empty, the exsistance of the interpreter is checked at run time.
* If the entry file's `flags` is `flags: F`, the existance of the interpreter is checked when registering the entry.

### qemu-user-static, binfmt_misc and container

A point to keep in mind when using qemu-user-static and binfmt_misc in container, is binfmt_misc `/proc/sys/fs/binfmt_misc` files `register`, `status` and `qemu-$arch` are shared and commonly used between host and inside of container. As a result, a script executed in container can modify `/proc/sys/fs/binfmt_misc` files on host OS.
binfmt_misc is a feature of kernel. A container uses the host OS's kernel.

## Programs input & output

In this section, we describe a program's input and output.
This repository is a pipeline system by using Github Actions.

First, we describe the entire pipelne system's input and output. `.github/workflows/actions.yml` is the top level file.

* Input of the pipeline: `qemu-user-static-X.Y.Z-R.fcNN.$arch.rpm` RPM file under [Fedora Project URL](https://kojipkgs.fedoraproject.org/packages/qemu). Right now `$arch` is only x86_64.
* Output of the pipeline:
  * [GitHub Releases page](https://github.com/multiarch/qemu-user-static/releases): `qemu-$arch-static` binary files, `qemu-$arch-static.tar.gz` and `x86_64_qemu-$arch-static.tar.gz` (`$from_arch_qemu-$arch-statc.tar.gz`). `qemu-$arch-static.tar.gz` files are same content with `x86_64_qemu-$arch-static.tar.gz`. It is an implementation to add supported host architectures `$from_arch` in the future.
  * Images on [Docker Hub](https://hub.docker.com/r/multiarch/qemu-user-static/). For actual images, see `README.md` Usage - multiarch/qemu-user-static images section.

Second, we describe each program's input and output by sequence.

| Step | Name | Description | Input | Output |
| ---- | ---- | ----------- | ----- | ------ |
| 1 | `generate_tarballs.sh` | Create tar.gz files to upload GitHub Releases page. | `qemu-$arch-static` files in qemu-user-static RPM  | `qemu-$arch-static.tar.gz` and `x86_64_qemu-$arch-static.tar.gz` files |
| 2 | `publish.sh` | Upload the tar.gz files by [GitHub API](https://developer.github.com/) | `qemu-$arch-static.tar.gz` and `x86_64_qemu-$arch-static.tar.gz` files | `qemu-$arch-static.tar.gz` and `x86_64_qemu-$arch-static.tar.gz` files on GitHub Releases page. |
| 3 | `update.sh` | Create container images on local | `x86_64_qemu-$arch-static.tar.gz` files on GitHub Releases page. | Container images on local |
| 4 | `test.sh` | Test created container images on local | Container images on local | `test/*` container images created as a result of tests  |
| 5 | `docker push $DOCKER_REPO` | Push the container images to DockerHub | `multiarch/qemu-user-static:*` container images on local | `multiarch/qemu-user-static:*` container images on Docker Hub |

## References

* [1] QEMU: https://www.qemu.org/
* [2] Fedora qemu RPM: https://src.fedoraproject.org/rpms/qemu
* [3] binfmt_misc: https://www.kernel.org/doc/html/latest/admin-guide/binfmt-misc.html
* [4] binfmt_misc C language level manual: https://lwn.net/Articles/630727/
