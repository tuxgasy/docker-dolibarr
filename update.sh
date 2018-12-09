#!/bin/bash

set -e

versions=( "5.0.7" "6.0.8" "7.0.4" "8.0.3" )
tags=""

rm -rf images/

for version in ${versions[@]}; do
  echo "Generate Dockerfile for Dolibarr $version"

  tags="${tags}\* "

  for php_version in "5.6" "7.0" "7.1"; do
    if [ "$php_version" = "5.6" ]; then
      dir="images/${version}"
      tags="${tags}${version} "
    else
      dir="images/${version}-php${php_version}"
      tags="${tags}${version}-php${php_version} "
    fi

    mkdir -p $dir

    sed '
          s/%PHP_VERSION%/'"$php_version"'-apache/;
          s/%VERSION%/'"$version"'/;
    ' Dockerfile.template > $dir/Dockerfile

    cp docker-run.sh $dir/

    #docker build -t tuxgasy/dolibarr:$version $dir
    #docker push tuxgasy/dolibarr:$version
  done

  tags="${tags}\n"
done

sed 's/%TAGS%/'"${tags}"'/' README.template > README.md
