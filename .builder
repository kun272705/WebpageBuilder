
copy_entry() {

  local input="$1"
  local output="$2"

  if [ -e "$input" ]; then

    echo -e "\n'$input' -> '$output'"

    install -D "$input" "$output"
  fi
}

build_html() {

  local input="$1"
  local output="$2"

  if [ -f "$input" ]; then
    
    echo -e "\n'$input' -> '$output'"
  fi
}

build_css() {

  local input="$1"
  local output="$2"

  if [ -f "$input" ]; then
    
    echo -e "\n'$input' -> '$output'"

    if [[ ${NODE_ENV:="production"} == "development" ]]; then

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

    npx rollup -c -i "$input" -o "${output/%.js/.combined.js}" --failAfterWarnings

    npx swc "${output/%.js/.combined.js}" -o "${output/%.js/.transpiled.js}"
    
    sed -i -e "/^import/d" "${output/%.js/.transpiled.js}"

    if [[ ${NODE_ENV:="production"} == "development" ]]; then

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
