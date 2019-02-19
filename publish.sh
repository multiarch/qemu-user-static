#!/bin/bash -e

[ -z "$VERSION" ] && VERSION="3.1.0-2"
[ -z "$REPO" ] && REPO="multiarch/qemu-user-static"

echo "VER: $VERSION"
echo "REPO: $REPO"

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

for file in *; do
    content_type=$(file --mime-type -b ${file})
    curl -sL \
        -H "Authorization: token ${GITHUB_TOKEN}" \
        -H "Content-Type: ${content_type}" \
        --upload-file ${file} \
        "https://uploads.github.com/repos/${REPO}/releases/${release_id}/assets?name=${file}"
done
