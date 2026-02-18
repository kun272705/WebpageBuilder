#!/usr/bin/env bash

set -euo pipefail

copy_file() {

  local src="$1"
  local dst="$2"

  if [ -f "$src" ]; then

    echo -e "\n'$src' -> '$dst'"

    mkdir -p "${dst%/*}"

    cp "$src" "$dst"
  fi
}

build_html() {

  local input="$1"
  local output="$2"

  if [ -f "$input" ]; then
    
    echo -e "\n'$input' -> '$output'"

    mkdir -p "${output%/*}"

    if [[ "${NODE_ENV:-production}" == development ]]; then

      npx ejs "$input" -o "$output"
    else

      npx ejs "$input" -o "$output" -w
    fi
  fi
}

build_css() {

  local input="$1"
  local output="$2"

  if [ -f "$input" ]; then
    
    echo -e "\n'$input' -> '$output'"

    if [[ "${NODE_ENV:-production}" == development ]]; then

      npx lightningcss "$input" -o "$output" --bundle --browserslist
    else

      npx lightningcss "$input" -o "$output" --bundle --browserslist --minify
    fi
  fi
}

build_js() {

  local input="$1"
  local output="$2"

  if [ -f "$input" ]; then

    echo -e "\n'$input' -> '$output'"

    npx rollup --jsx preserve -i "$input" -o "${output/%.js/.combined.js}" -f iife --failAfterWarnings

    npx swc "${output/%.js/.combined.js}" -o "${output/%.js/.transpiled.js}"
    
    sed -i -e "/^import/d" "${output/%.js/.transpiled.js}"

    if [[ "${NODE_ENV:-production}" == development ]]; then

      cp "${output/%.js/.transpiled.js}" "$output"
    else

      npx terser "${output/%.js/.transpiled.js}" -o "${output/%.js/.compressed.js}" -c -m

      cp "${output/%.js/.compressed.js}" "$output"
    fi

    rm "${output/%.js/.combined.js}"
    rm "${output/%.js/.transpiled.js}"
    rm -f "${output/%.js/.compressed.js}"
  fi
}

build_java() {

  local input="$1"
  local output="$2"

  if [ -f "$input" ]; then

    echo -e "\n'$input' -> '$output'"

    local indir="${input%/*}"
    local outdir="${output%/*}"

    javac -cp "java_modules/*.jar" "$indir/*.java" -d "$outdir/classes/"

    if [ -d "$indir/locales/" ]; then

      jar -c -v -f "$output" -C "$outdir/classes/" ./ -C "$indir/" locales/
    else

      jar -c -v -f "$output" -C "$outdir/classes/" ./
    fi

    rm -r "$outdir/classes/"
  fi
}
