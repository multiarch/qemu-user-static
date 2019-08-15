#!/usr/bin/env bash
set -xe

#
## This script builds 3 types of Docker images (assuming version `VERSION`):
#
#   1. Image containing all qemu binaries. Built in `./containers/latest/`. Tagged with `:latest`, and `:VERSION`.
#   2. Register image.  Built in `./containers/register/`. Tagged with `:register`, and `:register-VERSION`.
#   3. A series of images, each bundled with a single guest-architecture qemu binary. Built in `./containers/qemu-ARCH`.
#      Tagged with `:ARCH`, and `:ARCH-VERSION`.


# Convert Travis-provided repo SLUG to lowercase - Docker's requirement for tags
SLUG="$(echo "${TRAVIS_REPO_SLUG}" | tr '[:upper:]' '[:lower:]')"

#
BUILD_DIR="containers"

# list of all supported architectures for guest machines
guest_architectures="aarch64 aarch64_be alpha armeb arm cris hppa i386 m68k microblazeel microblaze mips64el mips64 mipsel mipsn32el mipsn32 mips nios2 or1k ppc64abi32 ppc64le ppc64 ppc riscv32 riscv64 s390x sh4eb sh4 sparc32plus sparc64 sparc tilegx trace-stap xtensaeb xtensa"

# NOTE: All qemu binaries have been downloaded, and unpacked to `./usr/bin/` in `before_script` already.

##
# Prepare & build image containing all qemu binaries (`:latest`)
##
cp -p ./usr/bin/qemu-*-static "${BUILD_DIR}/latest/"
docker build  -t "${SLUG}:latest"  "${BUILD_DIR}/latest"


##
# Prepare & build register image (`:register`)
##
cp -p ${BUILD_DIR}/latest/{Dockerfile,register.sh} "${BUILD_DIR}/register/"

# Register image does not need `qemu-*-static` binaries copied into it.  This line removes the COPY directive from Dockerfile.
sed -i '/^COPY qemu/ s/^/#/' "${BUILD_DIR}/register/Dockerfile"
docker build  -t "${SLUG}:register"  "${BUILD_DIR}/register"


##
# Build images for individual target architectures (`:ARCH`)
##
for guest_arch in ${guest_architectures}; do
  work_dir="${BUILD_DIR}/qemu-${guest_arch}"

  mkdir -p "${work_dir}"

  # copy a single binary to the image
  cp -p "./usr/bin/qemu-${guest_arch}-static" "${work_dir}"

  # create a minimal `Dockerfile` that only copies that specific binary into the image
  cat > "${work_dir}/Dockerfile" -<<EOF
FROM scratch
COPY qemu-${guest_arch}-static /usr/bin/
EOF

  docker build  -t "${SLUG}:${guest_arch}"  "${work_dir}"

  # cleanup
  rm -rf "${work_dir}"
done


# If git tag is provided, tag all images with VERSION, and push them to Docker Hub
if [[ -n "${TRAVIS_TAG}" ]]; then
  if [[ -z "${DOCKER_USER}" ]] || [[ -z "${DOCKER_PASS}" ]]; then
    echo "For deployment to Docker Hub to work both DOCKER_USER and DOCKER_PASS must be provided in Travis build settings."
    exit 1
  fi

  # Login to Docker Hub
  echo "${DOCKER_PASS}" | docker login -u="${DOCKER_USER}" --password-stdin

  # Tag `:latest` with a specific qemu version, and push both
  docker tag  "${SLUG}:latest" "${SLUG}:${TRAVIS_TAG}"
  docker push "${SLUG}:latest"
  docker push "${SLUG}:${TRAVIS_TAG}"

  # Tag `:register` with specific qemu version, and push both
  docker tag  "${SLUG}:register" "${SLUG}:register-${TRAVIS_TAG}"
  docker push "${SLUG}:register"
  docker push "${SLUG}:register-${TRAVIS_TAG}"

  # For each architecture, create a versioned tag, and push all
  for guest_arch in ${guest_architectures}; do
    docker tag  "${SLUG}:${guest_arch}"  "${SLUG}:${guest_arch}-${TRAVIS_TAG}"

    docker push "${SLUG}:${guest_arch}"
    docker push "${SLUG}:${guest_arch}-${TRAVIS_TAG}"
  done
fi
