#!/usr/bin/env bash

set -euo pipefail

source .builder.sh

npm install

mvn dependency:copy-dependencies -DoutputDirectory=java_modules/

for file in src/pub/res/*; do

  copy_file "$file" "tgt/pub/${file##*/}"
done

for file in src/pub/lib.*/*; do

  copy_file "$file" "tgt/pub/lib/${file##*/}"
done

mvn dependency:copy-dependencies -DoutputDirectory=tgt/lib/ -DincludeScope=runtime

for dir in src/pub/*/; do
 
  item="tgt/pub/${dir#src/pub/}"
  item="${item//.//}"
  item="${item%/}"

  name="${item##*/}"

  if [ -f "$dir$name.java" ]; then

    build_html "$dir$name.html" "$item.html"

    build_css "$dir$name.css" "$item.css"

    build_js "$dir$name.js" "$item.js"

    build_java "$dir$name.java" "$item.jar"
  fi
done

echo -e "\nDone"
