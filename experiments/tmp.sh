set -e

export QJS_VERSION="2020-11-08"
export QJS_HOME="soft/quickjs-$QJS_VERSION"

prepared_for_build() {

# dependencies
quickjs_installed
build_folder_created

bash <<'EOF'
  echo
  echo "Compiling with $($QJS_HOME/qjsc | grep version)..."
  echo
EOF

}

built_for_prod() {

# dependencies
prepared_for_build

bash <<'EOF'
  echo 'Compiling release build...'

  cd build

  #    -fno-json \
  #    -fno-module-loader \
  #    -fno-regexp \
  #    -fno-eval \
  $QJS_HOME/qjsc \
    -flto \
    -fno-date \
    -fno-proxy \
    -fno-promise \
    -fno-map \
    -fno-typedarray \
    -fno-string-normalize \
    -fno-bigint \
    -o jsqry ../jsqry-cli.js

  ls -lh jsqry
EOF

}

built_for_test() {

# dependencies
prepared_for_build

bash <<'EOF'
  echo 'Compiling test build...'

  cd build

  $QJS_HOME/qjsc -o jsqry ../jsqry-cli.js

  ls -lh jsqry
EOF

}

build_folder_created() {

# dependencies


bash <<'EOF'
  if [[ -d "build" ]]; then
    echo "goal 'build_folder_created' is already satisfied"
    return
  fi
  mkdir build
EOF

}

soft_folder_created() {

# dependencies


bash <<'EOF'
  if [[ -d "soft" ]]; then
    echo "goal 'soft_folder_created' is already satisfied"
    return
  fi
  mkdir soft
EOF

}

tush_installed() {

# dependencies
soft_folder_created

bash <<'EOF'
  if [[ -f "soft/tush/bin/tush-check" ]]; then
    echo "goal 'tush_installed' is already satisfied"
    return
  fi
  echo
  echo "Fetching tush..."
  echo

  cd "soft"

  wget https://github.com/adolfopa/tush/archive/master.zip -O./tush.zip
  unzip ./tush.zip
  rm ./tush.zip
  mv tush-master tush
EOF

}

quickjs_installed() {

# dependencies
soft_folder_created

bash <<'EOF'
  if [[ -f "soft/quickjs-$QJS_VERSION/qjsc" ]]; then
    echo "goal 'quickjs_installed' is already satisfied"
    return
  fi
  echo
  echo "Fetching QJS..."
  echo

  QJS=quickjs-$QJS_VERSION
  wget https://bellard.org/quickjs/$QJS.tar.xz
  tar xvf ./$QJS.tar.xz
  rm ./$QJS.tar.xz

  echo
  echo "Compile QJSC..."
  echo

  cd "$QJS"

  make qjsc libquickjs.a libquickjs.lto.a
EOF

}

soft_installed() {

# dependencies
tush_installed
quickjs_installed
}

cleaned() {

# dependencies


bash <<'EOF'
  rm "build/jsqry"
EOF

}

built() {

# dependencies
built_for_prod
tested
}

tested() {

# dependencies
built_for_test
tush_installed

bash <<'EOF'
  export PATH="build:$PATH:soft/tush/bin"

  tush-check tests.tush && echo 'TESTS PASSED' || (
    echo '!!! TESTS FAILED !!!'
    exit 1
  )
EOF

}

default() {

# dependencies
built
}
default
