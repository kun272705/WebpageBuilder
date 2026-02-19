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

build_jar() {

  local input="$1"
  local output="$2"

  if [ -f "$input" ]; then

    echo -e "\n'$input' -> '$output'"

    local indir="${input%/*}/"
    local outdir="${output%/*}/"
    local name="${input##*/}"
    name="${name%.*}"

    javac -cp "java_packages/*.jar" "$input" -d "$outdir"

    local args=("-C" "$outdir" "Handler.class")

    if [ -f "${indir}${name}.html" ]; then

      if [[ "${NODE_ENV:-production}" == development ]]; then

        npx ejs "${indir}${name}.html" -o "${outdir}template.html"
      else

        npx ejs "${indir}${name}.html" -o "${outdir}template.html" -w
      fi

      args+=("-C" "$outdir" "template.html")
    fi

    if [ -d "${indir}locales/" ]; then

      args+=("-C" "$indir" "locales/")
    fi

    jar -c -f "$output" "${args[@]}"

    rm "${outdir}Handler.class"
    rm -f "${outdir}template.html"
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
