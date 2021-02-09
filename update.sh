#!/bin/bash

set -e

DOCKER_BUILD=${DOCKER_BUILD:-1}
DOCKER_PUSH=${DOCKER_PUSH:-0}

BASE_DIR="$( cd "$(dirname "$0")" && pwd )"

source "${BASE_DIR}/versions.sh"

tags=""

rm -rf "${BASE_DIR}/images" "${BASE_DIR}/docker-compose-links"

for dolibarrVersion in "${DOLIBARR_VERSIONS[@]}"; do
  echo "Generate Dockerfile for Dolibarr ${dolibarrVersion}"

  tags="${tags}\n\*"
  dolibarrMajor=$(echo ${dolibarrVersion} | cut -d. -f1)

  # Mapping version according https://wiki.dolibarr.org/index.php/Versions
  # Regarding PHP Supported version : https://www.php.net/supported-versions.php
  if [ "${dolibarrMajor}" = "7" ]; then
    php_base_images=( "5.6-apache-stretch" "7.2-apache-stretch" )
  elif [ "${dolibarrMajor}" = "8" ]; then
    php_base_images=( "5.6-apache-stretch" "7.2-apache-stretch" )
  elif [ "${dolibarrMajor}" = "9" ]; then
    php_base_images=( "5.6-apache-stretch" "7.3-apache-stretch" )
  elif [ "${dolibarrMajor}" = "10" ]; then
    php_base_images=( "5.6-apache-stretch" "7.3-apache-stretch" )
  elif [ "${dolibarrMajor}" = "11" ]; then
    php_base_images=( "5.6-apache-stretch" "7.4-apache" )
  elif [ "${dolibarrMajor}" = "12" ]; then
    php_base_images=( "5.6-apache-stretch" "7.4-apache" )
  else
    php_base_images=( "7.4-apache" )
  fi

  for php_base_image in "${php_base_images[@]}"; do
    php_version=$(echo "${php_base_image}" | cut -d\- -f1)

    if [ "${dolibarrVersion}" = "develop" ]; then
      currentTag="${dolibarrVersion}"
    else
      currentTag="${dolibarrVersion}-php${php_version}"
      tags="${tags} ${currentTag}"
    fi

    dir="${BASE_DIR}/images/${currentTag}"

    if [ "${php_version}" = "7.4" ]; then
      gd_config_args="\-\-with\-freetype\ \-\-with\-jpeg"
    else
      gd_config_args="\-\-with\-png\-dir=\/usr\ \-\-with-jpeg-dir=\/usr"
    fi

    mkdir -p "${dir}"
    sed 's/%PHP_BASE_IMAGE%/'"${php_base_image}"'/;' "${BASE_DIR}/Dockerfile.template" | \
    sed 's/%DOLI_VERSION%/'"${dolibarrVersion}"'/;' | \
    sed 's/%GD_CONFIG_ARG%/'"${gd_config_args}"'/;' \
    > "${dir}/Dockerfile"

    cp "${BASE_DIR}/docker-run.sh" "${dir}/docker-run.sh"

    if [ "${DOCKER_BUILD}" = "1" ]; then
      docker build --compress --tag "tuxgasy/dolibarr:${currentTag}" "${dir}"
    fi
    if [ "${DOCKER_PUSH}" = "1" ]; then
      docker push "tuxgasy/dolibarr:${currentTag}"
    fi
  done

  if [ "${DOCKER_BUILD}" = "1" ]; then
    docker tag "tuxgasy/dolibarr:${currentTag}" "tuxgasy/dolibarr:${dolibarrVersion}"
    docker tag "tuxgasy/dolibarr:${currentTag}" "tuxgasy/dolibarr:${dolibarrMajor}"
    if [ "${dolibarrVersion}" = "${DOLIBARR_LATEST_TAG}" ]; then
      docker tag "tuxgasy/dolibarr:${currentTag}" tuxgasy/dolibarr:latest
    fi
  fi
  if [ "${DOCKER_PUSH}" = "1" ]; then
    docker push "tuxgasy/dolibarr:${dolibarrVersion}"
    docker push "tuxgasy/dolibarr:${dolibarrMajor}"
    if [ "${dolibarrVersion}" = "${DOLIBARR_LATEST_TAG}" ]; then
      docker push tuxgasy/dolibarr:latest
    fi
  fi

  if [ "${dolibarrVersion}" = "develop" ]; then
    tags="${tags} develop"
  else
    tags="${tags} ${dolibarrVersion} ${dolibarrMajor}"
  fi
  if [ "${dolibarrVersion}" = "${DOLIBARR_LATEST_TAG}" ]; then
    tags="${tags} latest"
  fi
done

sed 's/%TAGS%/'"${tags}"'/' "${BASE_DIR}/README.template" > "${BASE_DIR}/README.md"
