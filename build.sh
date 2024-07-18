#!/usr/bin/env bash

if [[ -z "$ANDROID_NDK" ]]; then
  echo "Please specify the Android NDK environment variable \"NDK\"."
  exit 1
fi

cd protobuf

NDK_TOOLCHAIN="$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64"
STRIP="$NDK_TOOLCHAIN/bin/llvm-strip"
CLEAN=termux-elf-cleaner

TARGET_ABI="$1"
TARGET_API="21"
PWD="$(pwd)"
generationDir="$PWD/build"
mkdir -p "${generationDir}"

cmake -GNinja -B "$generationDir" \
  -DANDROID_NDK="$ANDROID_NDK" \
  -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK/build/cmake/android.toolchain.cmake" \
  -DANDROID_ABI="$TARGET_ABI" \
  -DANDROID_NATIVE_API_LEVEL="$TARGET_API" \
  -DCMAKE_SYSTEM_NAME="Android" \
  -DCMAKE_BUILD_TYPE="Release" \
  -DCFLAGS="-fPIE -fPIC" \
  -DLDFLAGS="-llog -lz -lc++_shared -Wl,--hash-style=sysv" \
  -DANDROID_STL="c++_shared" \
  -Dprotobuf_BUILD_TESTS=OFF \
  -Dprotobuf_INSTALL=ON \
  -Dprotobuf_BUILD_LITE=ON \
  -Dprotobuf_BUILD_SHARED_LIBS=ON
  
#cmake --build .
ninja -C "$generationDir" "-j$(nproc)" || exit 1

#cd "${generationDir}"
#cmake -DCMAKE_INSTALL_PREFIX="$generationDir/protobuff_install" -P cmake_install.cmake

tree "$generationDir"

# protoc="$generationDir/protoc"
# $STRIP --strip-all "$protoc" || exit 1
# $CLEAN --api-level "$TARGET_API" "$protoc" || exit 1
