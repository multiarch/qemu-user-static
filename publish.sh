#!/bin/bash -e

# A POSIX variable
OPTIND=1 # Reset in case getopts has been used previously in the shell.

while getopts "v:t:r:" opt; do
    case "$opt" in
        v)  VERSION=$OPTARG
        ;;
        t)  GITHUB_TOKEN=$OPTARG
        ;;
        r)  REPO=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

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
