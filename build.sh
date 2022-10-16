#!/bin/bash

set -e

BASE_DIR="$( cd "$(dirname "$0")" && pwd )"
source "${BASE_DIR}/versions.sh"

DOCKER_BUILD=${DOCKER_BUILD:-0}
DOCKER_PUSH=${DOCKER_PUSH:-0}
DOCKER_BUILD_MULTI_ARCH=${DOCKER_BUILD_MULTI_ARCH:-${DOCKER_PUSH}}

dolibarrVersion=${1:-DOLIBARR_LATEST_TAG}

tags=""

if [ "${DOCKER_BUILD_MULTI_ARCH}" = "1" ]; then
  docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
  docker buildx create --driver docker-container --use
  docker buildx inspect --bootstrap
fi

echo "Generate docker image tag for Dolibarr ${dolibarrVersion} ..."

tags="${tags}\n\*"
dolibarrMajor=$(echo ${dolibarrVersion} | cut -d. -f1)

# Mapping version according https://wiki.dolibarr.org/index.php/Versions
# Regarding PHP Supported version : https://www.php.net/supported-versions.php
if [ "${dolibarrMajor}" = "16" ] || [ ${dolibarrVersion} = "develop" ]; then
  php_base_images=( "8.1-apache-buster" )
else
  php_base_images=( "7.4-apache-buster" )
fi

for php_base_image in "${php_base_images[@]}"; do
  php_version=$(echo "${php_base_image}" | cut -d\- -f1)

  if [ "${dolibarrVersion}" = "develop" ]; then
    currentTag="${dolibarrVersion}"
  else
    currentTag="${dolibarrVersion}-php${php_version}"
    tags="${tags} ${currentTag}"
  fi

  buildOptionTags="--tag tuxgasy/dolibarr:${currentTag}"
  if [ "${dolibarrVersion}" != "develop" ]; then
    buildOptionTags="${buildOptionTags} --tag tuxgasy/dolibarr:${dolibarrVersion} --tag tuxgasy/dolibarr:${dolibarrMajor}"
  fi
  if [ "${dolibarrVersion}" = "${DOLIBARR_LATEST_TAG}" ]; then
    buildOptionTags="${buildOptionTags} --tag tuxgasy/dolibarr:latest"
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
done
