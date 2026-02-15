
build_js() {

  local input="$1"
  local output="$2"

  if [ -f "$input" ]; then

    echo -e "\n$input -> $output"

    npx rollup -i "$input" -o "${output/%.js/.combined.js}" --failAfterWarnings

    npx babel --presets @babel/preset-env "${output/%.js/.combined.js}" -o "${output/%.js/.transpiled.js}"

    npx rollup -p node-resolve -p commonjs -i "${output/%.js/.transpiled.js}" -o "${output/%.js/.bundled.js}" --failAfterWarnings

    npx terser "${output/%.js/.bundled.js}" -o "${output/%.js/.compressed.js}" -c -m

    cp "${output/%.js/.compressed.js}" "$output"

    rm -rf ${output/%.js/.*.js}
  fi
}

build_html() {
}

build_css() {
}
