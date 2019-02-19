#!/bin/bash -e

cd "$(dirname $0)"

#--

update () {
  if [ -z "$VERSION" ]; then
      echo "usage: $0 -v VERSION" 2>&1
      echo "check https://github.com/${REPO}/releases for available versions" 2>&1
      exit 1
  fi

  from_arch="x86_64"
  to_archs="aarch64 alpha arm armeb cris hppa i386 m68k microblaze microblazeel mips mips64 mips64el mipsel mipsn32 mipsn32el nios2 or1k ppc ppc64 ppc64abi32 ppc64le s390x sh4 sh4eb sparc sparc32plus sparc64 x86_64"

  for to_arch in $to_archs; do
      if [ "$from_arch" != "$to_arch" ]; then
          mkdir -p archs/$from_arch-$to_arch
          cat > archs/$from_arch-$to_arch/Dockerfile <<EOF
FROM scratch
ADD https://github.com/${REPO}/releases/download/v${VERSION}/${from_arch}_qemu-${to_arch}-static.tar.gz /usr/bin
EOF
          docker build -t ${REPO}:$from_arch-$to_arch archs/$from_arch-$to_arch
          docker tag ${REPO}:$from_arch-$to_arch ${REPO}:$to_arch
      fi
  done

  docker build -t ${REPO}:register register
}

#--

generate () {
  rm -rf releases
  mkdir -p releases
  # find . -regex './qemu-.*' -not -regex './qemu-system-.*' -exec cp {} releases \;
  cp ./usr/bin/qemu-*-static releases/
  cd releases/
  for file in *; do
      tar -czf $file.tar.gz $file;
      cp $file.tar.gz x86_64_$file.tar.gz
  done
  cd ..
}

#--

publish () {
    [ -z "$GITHUB_TOKEN" ] && {
      echo "Environment variable $GITHUB_TOKEN is empty."
      echo "  Skipping deployment of artifacts to GitHub Releases."
      exit 0
    }
    # create a release
    release_id=$(curl -sL -X POST \
        -H "Content-Type: application/json" \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: token ${GITHUB_TOKEN}" \
        -H "Cache-Control: no-cache" -d "{
      \"tag_name\": \"v${VERSION}\",
      \"target_commitish\": \"master\",
      \"name\": \"v${VERSION}\",
      \"body\": \"# \`qemu-*-static\` @ ${VERSION}\",
      \"draft\": false,
      \"prerelease\": false
    }" "https://api.github.com/repos/${REPO}/releases" | jq -r ".id")
    if [ "$release_id" = "null" ]; then
        # get the existing release id
        release_id=$(set -x; curl -sL \
        -H "Content-Type: application/json" \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: token ${GITHUB_TOKEN}" \
        -H "Cache-Control: no-cache" \
        "https://api.github.com/repos/${REPO}/releases" | jq -r --arg version "${VERSION}" '.[] | select(.name == "v"+$version).id')
    fi
    cd releases/
    for file in *; do
        content_type=$(file --mime-type -b ${file})
        curl -sL \
            -H "Authorization: token ${GITHUB_TOKEN}" \
            -H "Content-Type: ${content_type}" \
            --upload-file ${file} \
            "https://uploads.github.com/repos/${REPO}/releases/${release_id}/assets?name=${file}"
    done
    cd ..
}

#--

[ -z "$VERSION" ] && VERSION="3.1.0-2"
[ -z "$REPO" ] && REPO="multiarch/qemu-user-static"

echo "VER: $VERSION"
echo "REPO: $REPO"

case "$1" in
  "-g") generate ;;
  "-p") publish  ;;
  "-u") update   ;;
  *)
    echo "Unknown option <$1>."
    exit 1
esac
