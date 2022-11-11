#!/bin/bash

set -e

function getDolibarrMajorVersion() {
  echo "${1}" | cut -d. -f1
  exit 0
}

function getPHPVersion() {
  echo "${1}" | cut -d\- -f1
  exit 0
}

function getPhpBaseImage() {
  local dolibarrVersion="${1}"
  local dolibarrMajor=$(getDolibarrMajorVersion "${dolibarrVersion}")

  # Mapping version according https://wiki.dolibarr.org/index.php/Versions
  # Regarding PHP Supported version : https://www.php.net/supported-versions.php
  if [[ "${dolibarrMajor}" == "16" || "${dolibarrVersion}" = "develop" ]]; then
    echo "8.1-apache-buster"
  else
    echo "7.4-apache-buster"
  fi
  exit 0
}

