#!/bin/bash

versions=( "4.0.0" "4.0.1" "4.0.2" "4.0.3" "4.0.4" "4.0.5" "5.0.0" "5.0.1" "5.0.2" "5.0.3" )

for version in ${versions[@]}; do
  echo "Generate Dockerfile for Dolibarr $version"

  for php_version in "5.6" "7.0" "7.1"; do
    if [ "$php_version" = "5.6" ]; then
      dir="images/${version}"
    else
      dir="images/${version}-php${php_version}"
    fi

    mkdir -p $dir

    sed '
          s/%PHP_VERSION%/'"$php_version"'-apache/;
          s/%VERSION%/'"$version"'/;
    ' Dockerfile.template > $dir/Dockerfile

    cp docker-run.sh $dir/

    #docker build -t tuxgasy/dolibarr:$version $dir
  done
done
