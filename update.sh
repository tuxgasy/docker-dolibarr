#!/bin/bash

versions=( "4.0.0" "4.0.1" "4.0.2" "4.0.3" "4.0.4" )

for version in ${versions[@]}; do
  echo "Generate Dockerfile for Dolibarr $version"

  mkdir -p images/$version

  sed 's/%VERSION%/'"$version"'/g;' Dockerfile.template > images/$version/Dockerfile

  cp docker-run.sh images/$version/

  #docker build -t tuxgasy/dolibarr:$version images/$version/
done
