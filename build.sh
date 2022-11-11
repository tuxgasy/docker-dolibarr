#!/bin/bash

set -e

DOCKER_BUILD=${DOCKER_BUILD:-0}
DOCKER_PUSH=${DOCKER_PUSH:-0}
DOCKER_BUILD_MULTI_ARCH=${DOCKER_BUILD_MULTI_ARCH:-${DOCKER_PUSH}}

BASE_DIR="$( cd "$(dirname "$0")" && pwd )"
source "${BASE_DIR}/base.sh"
source "${BASE_DIR}/versions.sh"

dolibarrVersion=${1:-DOLIBARR_LATEST_TAG}

if [ "${DOCKER_BUILD_MULTI_ARCH}" = "1" ]; then
  docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
  docker buildx create --driver docker-container --use
  docker buildx inspect --bootstrap
fi

echo "Generate docker image tag for Dolibarr ${dolibarrVersion} ..."

tags="${tags}\n\*"
dolibarrMajor=$(getDolibarrMajorVersion "${dolibarrVersion}")
php_base_image=$(getPhpBaseImage "${dolibarrVersion}")

if [[ "${dolibarrVersion}" == "develop" ]]; then
  currentTag="${dolibarrVersion}"
else
  php_version=$(getPHPVersion "${php_base_image}")
  currentTag="${dolibarrVersion}-php${php_version}"
  tags="${tags} ${currentTag}"
fi

buildOptionTags="--tag ${TAG_NAMESPACE}/dolibarr:${currentTag}"
if [[ "${dolibarrVersion}" != "develop" ]]; then
  buildOptionTags="${buildOptionTags} --tag ${TAG_NAMESPACE}/dolibarr:${dolibarrVersion} --tag ${TAG_NAMESPACE}/dolibarr:${dolibarrMajor}"
fi
if [ "${dolibarrVersion}" = "${DOLIBARR_LATEST_TAG}" ]; then
  buildOptionTags="${buildOptionTags} --tag ${TAG_NAMESPACE}/dolibarr:latest"
fi

dir="${BASE_DIR}/docker"

if [ "${DOCKER_BUILD}" = "1" ]; then
  if [ "${DOCKER_PUSH}" = "1" ]; then
    docker buildx build \
      --push \
      --compress \
      --platform linux/arm/v7,linux/arm64,linux/amd64 \
      --build-arg DOLI_VERSION=${dolibarrVersion} \
      --build-arg PHP_BASE_IMAGE=${php_base_image} \
      ${buildOptionTags} \
      "${dir}"
  else
    if [ "${DOCKER_BUILD_MULTI_ARCH}" = "1" ]; then
      docker buildx build \
        --compress \
        --platform linux/arm/v7,linux/arm64,linux/amd64 \
        --build-arg DOLI_VERSION=${dolibarrVersion} \
        --build-arg PHP_BASE_IMAGE=${php_base_image} \
        ${buildOptionTags} \
        "${dir}"
    else
      docker build \
        --compress \
        --build-arg DOLI_VERSION=${dolibarrVersion} \
        --build-arg PHP_BASE_IMAGE=${php_base_image} \
        ${buildOptionTags} \
        "${dir}"
    fi
  fi
fi

