#!/bin/bash

set -e

versions=( "5.0.7" "6.0.8" "7.0.4" "8.0.3" )
tags=""

rm -rf images/

for mode in "apache" "cli"; do
  for version in ${versions[@]}; do
    echo "Generate Dockerfile for Dolibarr $version"

    if [ "$mode" = "apache" ]; then
      tags="${tags}\* "
    fi

    for php_version in "5.6" "7.0" "7.1"; do
      dir="images/${version}-php${php_version}"

      if [ "$mode" = "cli" ]; then
        dir="${dir}-cli"
      else
        tags="${tags}${version}-php${php_version} "
      fi

      mkdir -p $dir

      sed '
            s/%PHP_VERSION%/'"$php_version"'-'"$mode"'/;
            s/%VERSION%/'"$version"'/;
      ' Dockerfile.template > $dir/Dockerfile

      cp docker-run.sh $dir/

      #docker build -t tuxgasy/dolibarr:$version $dir
      #docker push tuxgasy/dolibarr:$version
    done

    if [ "$mode" = "apache" ]; then
      tags="${tags}\n"
    fi
  done
done

sed 's/%TAGS%/'"${tags}"'/' README.template > README.md
