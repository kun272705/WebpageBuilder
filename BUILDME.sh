#!/usr/bin/env bash

set -euo pipefail

source .builder.sh

npm install

mvn dependency:copy-dependencies -DoutputDirectory=java_packages/ -DincludeScope=test

for file in src/pub/res/*; do

  copy_file "$file" "tgt/pub/${file##*/}"
done

for file in src/pub/lib.*/*; do

  copy_file "$file" "tgt/pub/lib/${file##*/}"
done

mvn dependency:copy-dependencies -DoutputDirectory=tgt/lib/ -DincludeScope=runtime

for dir in src/pub/*/; do
 
  item="${dir/src/tgt/}"
  item="${item//./\/}"
  item="${item%/}"

  name="${item##*/}"

  if [ -f "${dir}${name}.java" ]; then

    build_jar "${dir}${name}.java" "${item}.jar"

    build_css "${dir}${name}.css" "${item}.css"

    build_js "${dir}${name}.js" "${item}.js"
  fi
done

echo -e "\nDone"
