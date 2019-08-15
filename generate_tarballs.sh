#!/usr/bin/env bash

#
## This script compresses all qemu binaries, and prepares them for upload to Github Release later in the deploy step.

if [[ -z "${TRAVIS_TAG}" ]]; then
  echo "TRAVIS_TAG not specified.  Skipping tarball generation."
  exit 0
fi

rm -rf releases
mkdir -p releases

for file in ./usr/bin/qemu-*-static; do
  name="$(basename "${file}").tgz"
  tar -cvzf "releases/${TRAVIS_TAG}-${name}" "${file}"
done
