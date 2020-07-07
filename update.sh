#!/bin/bash

set -e

versions=( "6.0.8" "7.0.5" "8.0.6" "9.0.4" "10.0.7" "11.0.5" "12.0.1" )
tags=""

rm -rf images/

for version in ${versions[@]}; do
  echo "Generate Dockerfile for Dolibarr ${version}"

  tags="${tags}\n\* "

  # Mapping version according https://wiki.dolibarr.org/index.php/Versions
  # Regarding PHP Supported version : https://www.php.net/supported-versions.php
  if [ "$version" = "6.0.8" ]; then #Version discontinued
    php_versions=( "7.1" )
  elif [ "$version" = "7.0.5" ]; then
    php_versions=( "7.2" )
  elif [ "$version" = "8.0.6" ]; then
    php_versions=( "7.2" )
  elif [ "$version" = "9.0.4" ]; then
    php_versions=( "7.2" "7.3" )
  elif [ "$version" = "10.0.7" ]; then
    php_versions=( "7.2" "7.3" )
  elif [ "$version" = "11.0.5" ]; then
    php_versions=( "7.2" "7.3" "7.4" )
  elif [ "$version" = "12.0.1" ]; then
    php_versions=( "7.2" "7.3" "7.4" )
  else
    php_versions=( "7.3" "7.4" )
  fi

  for php_version in ${php_versions[@]}; do
    currentTag="${version}-php${php_version}"
    dir="images/${currentTag}"
    tags="${tags}${currentTag} "

    mkdir -p $dir

    if [ -f Dockerfile_${php_version}.template ]; then
      sed 's/%PHP_VERSION%/'"${php_version}"'/;' Dockerfile_${php_version}.template > ${dir}/Dockerfile
    else
      sed 's/%PHP_VERSION%/'"${php_version}"'/;' Dockerfile.template > ${dir}/Dockerfile
    fi

    cp docker-run.sh ${dir}/docker-run.sh

    #docker build --compress --tag tuxgasy/dolibarr:${currentTag} --build-arg DOLI_VERSION=${version} ${dir}
    #docker push tuxgasy/dolibarr:${currentTag}
  done

  #docker tag tuxgasy/dolibarr:${currentTag} tuxgasy/dolibarr:${version}
  #docker push tuxgasy/dolibarr:${version}

  tags="${tags}${version}"
done

#docker tag tuxgasy/dolibarr:${version} tuxgasy/dolibarr:latest
#docker push tuxgasy/dolibarr:latest
tags="${tags} latest"

sed 's/%TAGS%/'"${tags}"'/' README.template > README.md
