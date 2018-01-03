#!/bin/bash

versions=( "5.0.7" "6.0.4" )

rm -rf images/

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
