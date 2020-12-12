# Contributing to multiarch/qemu-user-static

Your contributions such as reporting a bug and sending pull-request are very wellcome! Thank you.

## Did you find a bug?

* Ensure the bug was not already reported by searching on GitHub under Issues.
* multiarch/qemu-user-static is a collection of containers to enable people to emulate multi-architecture containers by using qemu-user-static (= a collection of QEMU's user mode static binaries `qemu-$arch-static`) [1] and binfmt_misc [2]. This repository is not QEMU project's one. If you find a bug about them, you can visit the website [1][2] to report an issue on the projects.

## How to send pull-request

1. Fork the repository: https://github.com/multiarch/qemu-user-static . Ex. https://github.com/junaruga/qemu-user-static
2. This repository is using Github Actions. You can test your modified code on your forked repository before sending a pull-requeste.
3. If you want to test pushing created container images,
    * You need to have your own container repository such as DockerHub or Quay.io. Ex. https://quay.io/repository/junaruga/qemu-user-static
    * You need to set environment variables `DOCKER_USERNAME` and `DOCKER_PASSWORD` on your repository's Settings page. Please remember it is better to set `DOCKER_PASSWORD` without displaying the value for your security.
4. You also need to have your https://quay.io/repository/junaruga/qemu-user-static
5. You need to edit `.github/workflows/actions.yml` with your container repository. This step can be improved in the future.
6. Below is an example of how to test with your container repository.
7. Check Github Actions's log, and ensure the container images are created.
8. You are ready to send the pull-request!

## References

* [1] QEMU: https://www.qemu.org/
* [2] binfmt-misc: https://www.kernel.org/doc/html/latest/admin-guide/binfmt-misc.html

