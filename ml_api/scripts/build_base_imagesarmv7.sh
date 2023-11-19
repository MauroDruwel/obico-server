#!/bin/bash -e

VERSION=
PREFIX=thespaghettidetective
INSECURE=

while getopts v:p:i flag
do
    case "$flag" in
        v) VERSION=${OPTARG};;
        p) PREFIX=${OPTARG};;
        i) INSECURE="--insecure"
    esac
done

if [ -z "$VERSION" ]; then
    echo "USAGE: build_base_images.sh -v base_version [-p prefix] [-i]"
    echo "-v base_version: required, defines the version of the image"
    echo "-p prefix: optional, can be used to push images into private repository, ex: localhost:5000/obico"
    echo "-i: optional, adds --insecure flag to manifest create command, helps to resolve 'manifest not found' error if not using https"
    exit 1
fi

# CPU + GPU image for amd64
VERSION_BASE=${PREFIX}/ml_api_base:${VERSION}
echo Building $VERSION_BASE
docker buildx create --use
docker buildx build --platform linux/arm/v7 -f Dockerfile.base_armv7 -t ${VERSION_BASE}-linux-armv7 .
docker push ${VERSION_BASE}-linux-armv7
docker manifest create ${INSECURE} ${VERSION_BASE} --amend ${VERSION_BASE}-linux-armv7
docker manifest push ${INSECURE} ${VERSION_BASE}
