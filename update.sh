#!/bin/bash

set -e

DOCKER_BUILD=${DOCKER_BUILD:-0}
DOCKER_PUSH=${DOCKER_PUSH:-0}
DOCKER_BUILD_MULTI_ARCH=${DOCKER_BUILD_MULTI_ARCH:-${DOCKER_PUSH}}

BASE_DIR="$( cd "$(dirname "$0")" && pwd )"

source "${BASE_DIR}/versions.sh"

tags=""

for dolibarrVersion in "${DOLIBARR_VERSIONS[@]}"; do
  tags="${tags}\n\*"
  dolibarrMajor=$(echo ${dolibarrVersion} | cut -d. -f1)

  # Mapping version according https://wiki.dolibarr.org/index.php/Versions
  # Regarding PHP Supported version : https://www.php.net/supported-versions.php
  if [ "${dolibarrMajor}" = "16" ] || [ "${dolibarrVersion}" = "develop" ]; then
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
  done

  /bin/bash ${BASE_DIR}/build.sh ${dolibarrVersion}

  if [ "${dolibarrVersion}" = "develop" ]; then
    tags="${tags} develop"
  else
    tags="${tags} ${dolibarrVersion} ${dolibarrMajor}"
  fi
  if [ "${dolibarrVersion}" = "${DOLIBARR_LATEST_TAG}" ]; then
    tags="${tags} latest"
  fi
done

echo "Generate Readme file ..."
sed 's/%TAGS%/'"${tags}"'/' "${BASE_DIR}/README.template" > "${BASE_DIR}/README.md"
