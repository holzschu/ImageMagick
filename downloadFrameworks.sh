#! /bin/sh

curl -OL https://github.com/holzschu/ios_system/releases/download/v2.7.0/ios_error.h
mkdir -p Python-aux
pushd Python-aux
curl -OL https://github.com/holzschu/Python-aux/releases/download/1.0/libjpeg.xcframework.zip
curl -OL https://github.com/holzschu/Python-aux/releases/download/1.0/libtiff.xcframework.zip
curl -OL https://github.com/holzschu/Python-aux/releases/download/1.0/freetype.xcframework.zip
curl -OL https://github.com/holzschu/Python-aux/releases/download/1.0/harfbuzz.xcframework.zip
curl -OL https://github.com/holzschu/Python-aux/releases/download/1.0/libpng.xcframework.zip
curl -OL https://github.com/holzschu/ios_system/releases/download/v2.7.0/ios_system.xcframework.zip

rm -rf libffi.xcframework crypto.xcframework openssl.xcframework ios_system.xcframework libzmq.xcframework libjpeg.xcframework libtiff.xcframework freetype.xcframework harfbuzz.xcframework libpng.xcframework libxslt.xcframework libexslt.xcframework
unzip -q libjpeg.xcframework.zip
unzip -q libtiff.xcframework.zip
unzip -q freetype.xcframework.zip
unzip -q harfbuzz.xcframework.zip
unzip -q libpng.xcframework.zip
unzip -q ios_system.xcframework.zip

popd

PREFIX=$PWD
XCFRAMEWORKS_DIR=$PREFIX/Python-aux/
mkdir -p Frameworks_iphoneos
mkdir -p Frameworks_iphoneos/include
mkdir -p Frameworks_iphoneos/lib
rm -rf Frameworks_iphoneos/ios_system.framework
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
rm -rf Frameworks_iphonesimulator/ios_system.framework
cp -r $XCFRAMEWORKS_DIR/ios_system.xcframework/ios-arm64_x86_64-simulator/ios_system.framework $PREFIX/Frameworks_iphonesimulator
cp -r $XCFRAMEWORKS_DIR/freetype.xcframework/ios-x86_64-simulator/freetype.framework $PREFIX/Frameworks_iphonesimulator
cp -r $XCFRAMEWORKS_DIR/harfbuzz.xcframework/ios-x86_64-simulator/harfbuzz.framework $PREFIX/Frameworks_iphonesimulator
cp -r $XCFRAMEWORKS_DIR/libpng.xcframework/ios-x86_64-simulator/libpng.framework $PREFIX/Frameworks_iphonesimulator
cp -r $XCFRAMEWORKS_DIR/libjpeg.xcframework/ios-x86_64-simulator/Headers/* $PREFIX/Frameworks_iphonesimulator/include/
cp -r $XCFRAMEWORKS_DIR/libtiff.xcframework/ios-x86_64-simulator/Headers/* $PREFIX/Frameworks_iphonesimulator/include/
cp -r $XCFRAMEWORKS_DIR/freetype.xcframework/ios-x86_64-simulator/freetype.framework/Headers/* $PREFIX/Frameworks_iphonesimulator/include/
# Need to copy all libs after each make clean: 
cp $XCFRAMEWORKS_DIR/libjpeg.xcframework/ios-x86_64-simulator/libjpeg.a $PREFIX/Frameworks_iphonesimulator/lib/
cp $XCFRAMEWORKS_DIR/libtiff.xcframework/ios-x86_64-simulator/libtiff.a $PREFIX/Frameworks_iphonesimulator/lib/

