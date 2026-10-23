#!/bin/bash
set -euo pipefail

curl --fail --location --retry 3 -O https://github.com/holzschu/ios_system/releases/download/v3.0.5/ios_error.h
echo '51d46b912eb30399cbb5c36c8c8f15eb1a44adcfc9ee581304ac9d3739a84716  ios_error.h' | shasum -a 256 -c -
# Reuse the pinned producer recipes for universal Simulator dependencies.
PYTHON_AUX_COMMIT=8d8dba3a6d4e86d7c670df584cec602650cfaede
SOURCE_DIR="$PWD/build/Python-aux-$PYTHON_AUX_COMMIT"
rm -rf "$SOURCE_DIR"
mkdir -p "$SOURCE_DIR" Python-aux
git -C "$SOURCE_DIR" init -q
git -C "$SOURCE_DIR" fetch --depth=1 --filter=blob:none https://github.com/holzschu/Python-aux.git "$PYTHON_AUX_COMMIT"
git -C "$SOURCE_DIR" checkout --detach FETCH_HEAD
[[ $(git -C "$SOURCE_DIR" rev-parse HEAD) == "$PYTHON_AUX_COMMIT" ]]
git -C "$SOURCE_DIR" submodule update --init --depth 1 harfbuzz
pushd "$SOURCE_DIR"
nice -n 15 bash build_libpng.sh
nice -n 15 bash build_freetype.sh
nice -n 15 bash build_libjpg.sh
nice -n 15 bash build_libtiff.sh
for name in libpng freetype harfbuzz; do
    xcodebuild -create-xcframework \
        -framework "build/Release-iphoneos/$name.framework" \
        -framework "build/Release-iphonesimulator/$name.framework" \
        -output "$name.xcframework"
done
popd
for name in libpng freetype harfbuzz libjpeg libtiff; do
    rm -rf "Python-aux/$name.xcframework"
    cp -R "$SOURCE_DIR/$name.xcframework" Python-aux/
done
pushd Python-aux
curl --fail --location --retry 3 -O https://github.com/holzschu/ios_system/releases/download/v3.0.5/ios_system.xcframework.zip
echo 'd429e68102926f58bedd8e8b7105dcd169478cd6da1cef494a5f468482d1c8f5  ios_system.xcframework.zip' | shasum -a 256 -c -
rm -rf ios_system.xcframework
unzip -q ios_system.xcframework.zip
popd

PREFIX=$PWD
XCFRAMEWORKS_DIR=$PREFIX/Python-aux/
mkdir -p Frameworks_iphoneos
mkdir -p Frameworks_iphoneos/include
mkdir -p Frameworks_iphoneos/lib
rm -rf Frameworks_iphoneos/{ios_system,freetype,harfbuzz,libpng}.framework
cp -r $XCFRAMEWORKS_DIR/ios_system.xcframework/ios-arm64/ios_system.framework $PREFIX/Frameworks_iphoneos
cp -r $XCFRAMEWORKS_DIR/freetype.xcframework/ios-arm64/freetype.framework $PREFIX/Frameworks_iphoneos
cp -r $XCFRAMEWORKS_DIR/harfbuzz.xcframework/ios-arm64/harfbuzz.framework $PREFIX/Frameworks_iphoneos
cp -r $XCFRAMEWORKS_DIR/libpng.xcframework/ios-arm64/libpng.framework $PREFIX/Frameworks_iphoneos
cp -r $XCFRAMEWORKS_DIR/libjpeg.xcframework/ios-arm64/Headers/* $PREFIX/Frameworks_iphoneos/include/
cp -r $XCFRAMEWORKS_DIR/libtiff.xcframework/ios-arm64/Headers/* $PREFIX/Frameworks_iphoneos/include/
cp -r $XCFRAMEWORKS_DIR/freetype.xcframework/ios-arm64/freetype.framework/Headers/* $PREFIX/Frameworks_iphoneos/include/
# Need to copy all libs after each make clean: 
cp $XCFRAMEWORKS_DIR/libjpeg.xcframework/ios-arm64/libjpeg.a $PREFIX/Frameworks_iphoneos/lib/
cp $XCFRAMEWORKS_DIR/libtiff.xcframework/ios-arm64/libtiff.a $PREFIX/Frameworks_iphoneos/lib/

mkdir -p Frameworks_iphonesimulator
mkdir -p Frameworks_iphonesimulator/include
mkdir -p Frameworks_iphonesimulator/lib
rm -rf Frameworks_iphonesimulator/{ios_system,freetype,harfbuzz,libpng}.framework
cp -r $XCFRAMEWORKS_DIR/ios_system.xcframework/ios-arm64_x86_64-simulator/ios_system.framework $PREFIX/Frameworks_iphonesimulator
cp -r $XCFRAMEWORKS_DIR/freetype.xcframework/ios-arm64_x86_64-simulator/freetype.framework $PREFIX/Frameworks_iphonesimulator
cp -r $XCFRAMEWORKS_DIR/harfbuzz.xcframework/ios-arm64_x86_64-simulator/harfbuzz.framework $PREFIX/Frameworks_iphonesimulator
cp -r $XCFRAMEWORKS_DIR/libpng.xcframework/ios-arm64_x86_64-simulator/libpng.framework $PREFIX/Frameworks_iphonesimulator
cp -r $XCFRAMEWORKS_DIR/libjpeg.xcframework/ios-arm64_x86_64-simulator/Headers/* $PREFIX/Frameworks_iphonesimulator/include/
cp -r $XCFRAMEWORKS_DIR/libtiff.xcframework/ios-arm64_x86_64-simulator/Headers/* $PREFIX/Frameworks_iphonesimulator/include/
cp -r $XCFRAMEWORKS_DIR/freetype.xcframework/ios-arm64_x86_64-simulator/freetype.framework/Headers/* $PREFIX/Frameworks_iphonesimulator/include/
# Need to copy all libs after each make clean: 
cp $XCFRAMEWORKS_DIR/libjpeg.xcframework/ios-arm64_x86_64-simulator/libjpeg.a $PREFIX/Frameworks_iphonesimulator/lib/
cp $XCFRAMEWORKS_DIR/libtiff.xcframework/ios-arm64_x86_64-simulator/libtiff.a $PREFIX/Frameworks_iphonesimulator/lib/


# Configure discovers TIFF and SDK zlib through pkg-config, without macOS packages.
for platform in iphoneos iphonesimulator; do
    pkgdir="$PREFIX/Frameworks_$platform/lib/pkgconfig"
    mkdir -p "$pkgdir"
    awk '
        /^prefix=/ {print "prefix=${pcfiledir}/../.."; next}
        /^Requires.private:/ {next}
        {print}
    ' "$SOURCE_DIR/tiff-4.7.0/libtiff-4.pc" > "$pkgdir/libtiff-4.pc"
    sdkroot=$(xcrun --sdk "$platform" --show-sdk-path)
    zlib_version=$(awk '/^#define ZLIB_VERSION / {gsub(/"/, "", $3); print $3}' "$sdkroot/usr/include/zlib.h")
    [[ -n $zlib_version ]]
    cat > "$pkgdir/zlib.pc" <<PC
Name: zlib
Description: Target SDK compression library
Version: $zlib_version
Libs: -lz
PC
done
