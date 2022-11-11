#!/bin/bash

set -e

BASE_DIR="$( cd "$(dirname "$0")" && pwd )"

DOLI_VER=${1}
PHP_VER=${2:-""}

echo "Testing for:"
echo " - Dolibarr ${DOLI_VER}"
if [ "${PHP_VER}" = "" ]; then
  echo " - PHP most recent"
  echo "Building image ..."
  DOLI_VERSION=${DOLI_VER} PHP_VERSION="" docker-compose -f "${BASE_DIR}/docker-compose.yml" down 1> /dev/null 2>/dev/null
  DOLI_VERSION=${DOLI_VER} PHP_VERSION="" docker-compose -f "${BASE_DIR}/docker-compose.yml" build web
  DOLI_VERSION=${DOLI_VER} PHP_VERSION="" docker-compose -f "${BASE_DIR}/docker-compose.yml" up --force-recreate web cron
  DOLI_VERSION=${DOLI_VER} PHP_VERSION="" docker-compose -f "${BASE_DIR}/docker-compose.yml" down
else
  echo " - PHP ${PHP_VER}"
  echo "Building image ..."
  DOLI_VERSION=${DOLI_VER} PHP_VERSION="-php${PHP_VER}" docker-compose -f "${BASE_DIR}/docker-compose.yml" down 1> /dev/null
  DOLI_VERSION=${DOLI_VER} PHP_VERSION="-php${PHP_VER}" docker-compose -f "${BASE_DIR}/docker-compose.yml" build web
  DOLI_VERSION=${DOLI_VER} PHP_VERSION="-php${PHP_VER}" docker-compose -f "${BASE_DIR}/docker-compose.yml" up --force-recreate web cron
  DOLI_VERSION=${DOLI_VER} PHP_VERSION="-php${PHP_VER}" docker-compose -f "${BASE_DIR}/docker-compose.yml" down
fi
