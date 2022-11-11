#!/bin/bash

set -e

DOCKER_BUILD=${DOCKER_BUILD:-0}
DOCKER_PUSH=${DOCKER_PUSH:-0}
DOCKER_BUILD_MULTI_ARCH=${DOCKER_BUILD_MULTI_ARCH:-${DOCKER_PUSH}}

BASE_DIR="$( cd "$(dirname "$0")" && pwd )"
source "${BASE_DIR}/base.sh"
source "${BASE_DIR}/versions.sh"

tags=""
for dolibarrVersion in "${DOLIBARR_VERSIONS[@]}"; do
  tags="${tags}\n\*"
  dolibarrMajor=$(getDolibarrMajorVersion "${dolibarrVersion}")

  if [[ "${dolibarrVersion}" == "develop" ]]; then
    currentTag="${dolibarrVersion}"
  else
    php_base_image=$(getPhpBaseImage "${dolibarrVersion}")
    php_version=$(getPHPVersion "${php_base_image}")

    currentTag="${dolibarrVersion}-php${php_version}"
    tags="${tags} ${currentTag}"
  fi

  /bin/bash -c "${BASE_DIR}/build.sh ${dolibarrVersion}"

  if [[ "${dolibarrVersion}" == "develop" ]]; then
    tags="${tags} develop"
  else
    tags="${tags} ${dolibarrVersion} ${dolibarrMajor}"
  fi

  if [[ "${dolibarrVersion}" = "${DOLIBARR_LATEST_TAG}" ]]; then
    tags="${tags} latest"
  fi
done

echo "Generate Readme file ..."
sed 's/%TAGS%/'"${tags}"'/' "${BASE_DIR}/README.template" > "${BASE_DIR}/README.md"