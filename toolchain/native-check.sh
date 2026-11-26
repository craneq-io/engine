#!/bin/sh
# Run from the checked-out engine in a Yureisha native build job.
set -eu
: "${YUREI_BUILD_JOB:?requires a queued build job}" "${K3SM_ROOTFS:?requires a native pod}"
test "$(uname -sm)" = "Darwin arm64"
export PATH=/usr/bin:/bin:/usr/sbin:/sbin
engine=$(cd "$(dirname "$0")/.." && pwd -P)
cd "$engine"
revision=$(git rev-parse --verify HEAD)
# Both tracked content and staging must match the revision named in the receipt.
git diff --quiet "$revision" -- || { echo 'tracked checkout differs from HEAD' >&2; exit 1; }
git diff --cached --quiet "$revision" -- || { echo 'index differs from HEAD' >&2; exit 1; }
git ls-files --error-unmatch toolchain/native-check.sh toolchain/sources.lock toolchain/no-optional-tools.patch >/dev/null
test "$(cat lean-toolchain)" = 'leanprover/lean4:v4.35.0'
commit=eb6cafb7290e8bd5f2937522d8d804f58f02bafc
ref=refs/tags/v4.35.0
test "$(git ls-remote --refs https://github.com/leanprover/lean4.git "$ref" | cut -f1)" = "$commit"

work=$(mktemp -d "$engine/.native-build.XXXXXX")
trap 'rm -rf "$work"' EXIT
prefix="$work/prefix"
mkdir -p "$prefix" "$work/tmp"
export TMPDIR="$work/tmp"
while read -r name digest url; do
    archive="$work/$name.archive"
    curl --fail --location --silent --show-error --retry 2 "$url" -o "$archive"
    printf '%s  %s\n' "$digest" "$archive" | shasum -a 256 -c -
    mkdir "$work/$name"
    tar -xf "$archive" --strip-components 1 -C "$work/$name"
done < "$engine/toolchain/sources.lock"

jobs=${CRANEQ_BUILD_JOBS:-2}
case "$jobs" in ''|0*|*[!0-9]*) echo 'CRANEQ_BUILD_JOBS must be a positive integer' >&2; exit 1;; esac
export CC=/usr/bin/clang CXX=/usr/bin/clang++
(cd "$work/cmake" && ./bootstrap --prefix="$prefix" --parallel="$jobs" -- -DCMAKE_USE_OPENSSL=OFF &&
    make -j"$jobs" && make install)
export PATH="$prefix/bin:$PATH"
(cd "$work/pkgconf" && ./configure --prefix="$prefix" && make -j"$jobs" && make install)
(cd "$work/openssl" && ./Configure darwin64-arm64-cc no-shared no-tests --prefix="$prefix" --libdir=lib &&
    make -j"$jobs" && make install_sw)
cmake -S "$work/libuv" -B "$work/uv-build" -DCMAKE_INSTALL_PREFIX="$prefix" -DLIBUV_BUILD_TESTS=OFF
cmake --build "$work/uv-build" --parallel "$jobs"
cmake --install "$work/uv-build"

export PKG_CONFIG_LIBDIR="$prefix/lib/pkgconfig"
unset PKG_CONFIG_PATH
(cd "$work/lean4" && patch -p1 < "$engine/toolchain/no-optional-tools.patch")
cmake -S "$work/lean4" -B "$work/lean-build" -G 'Unix Makefiles' \
    -DBUILD_AUXILIARY_TOOLS=OFF -DUSE_MIMALLOC=OFF -DUSE_GMP=OFF -DUSE_LAKE_CACHE=OFF \
    -DUSE_GITHASH=OFF -DSTAGE0_USE_GITHASH=OFF \
    -DPKG_CONFIG_EXECUTABLE="$prefix/bin/pkgconf" \
    -DOPENSSL_ROOT_DIR="$prefix" -DSTAGE0_OPENSSL_ROOT_DIR="$prefix"
cmake --build "$work/lean-build" --target stage1 --parallel "$jobs"
export PATH="$work/lean-build/stage1/bin:$PATH"
lean --version
lake --version
# Use a clean copy of the committed source so cached .oleans cannot mask failures.
mkdir "$work/engine"
git archive --output="$work/engine.tar" "$revision"
tar -xf "$work/engine.tar" -C "$work/engine"
(cd "$work/engine" && lake build)
printf 'job=%s engine=%s lean_source=%s\n' "$YUREI_BUILD_JOB" "$revision" "$commit"
