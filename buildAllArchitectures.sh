PREFIX=$PWD
IOS_SDKROOT=$(xcrun --sdk iphoneos --show-sdk-path)
SIM_SDKROOT=$(xcrun --sdk iphonesimulator --show-sdk-path)

# 1) build for iOS:
# 1a) configure with all the right flags:
make distclean
env CC=clang CXX=clang++ \
	CPPFLAGS="-arch arm64 -miphoneos-version-min=14.0 -isysroot $IOS_SDKROOT -I$PREFIX/Frameworks_iphoneos/include -F$PREFIX/Frameworks_iphoneos " \
	CFLAGS="-arch arm64 -miphoneos-version-min=14.0 -isysroot $IOS_SDKROOT -I$PREFIX/Frameworks_iphoneos/include -F$PREFIX/Frameworks_iphoneos " \
	CXXFLAGS="-arch arm64 -miphoneos-version-min=14.0 -isysroot $IOS_SDKROOT -I$PREFIX/Frameworks_iphoneos/include " \
	LDFLAGS="-dynamiclib -arch arm64 -miphoneos-version-min=14.0 -isysroot $IOS_SDKROOT -F$PREFIX/Frameworks_iphoneos -framework ios_system -L$PREFIX/Frameworks_iphoneos/lib -lz" \
	LDSHARED="clang -v -undefined error -dynamiclib -isysroot $IOS_SDKROOT -F$PREFIX/Frameworks_iphoneos -framework ios_system -L$PREFIX/Frameworks_iphoneos/lib" \
	PATH="/usr/bin:/bin:/usr/sbin:/sbin" \
	PLATFORM=iphoneos \
	./configure --disable-shared \
	--host arm-apple-darwin --build x86_64-apple-darwin --with-quantum-depth=8 --disable-installed --without-modules --disable-hdri --with-lzma=no --with-fftw=no --with-pango=no --with-openexr=no --with-gslib=no --with-dps=no --with-png=yes  PNG_CFLAGS="-F$PREFIX/Frameworks_iphoneos" PNG_LIBS="-framework libpng"  PSDelegateDefault="no" --with-freetype FREETYPE_LIBS="-framework freetype"  FREETYPE_CFLAGS="-F$PREFIX/Frameworks_iphoneos" ac_cv_func_fork=no ac_cv_func_fork_works=no ac_cv_func_vfork=no ac_cv_func_vfork_works=no 

# 1b) make:
make
# utilities/magick is now a dynamic library containing everything (and linking libpng, freetype, ios_system, SystemB, libz and libbz2)
# Let's make a framework out of that:

binary=magick
FRAMEWORK_DIR=build/Release-iphoneos/$binary.framework
rm -rf ${FRAMEWORK_DIR}
mkdir -p ${FRAMEWORK_DIR}
cp utilities/magick ${FRAMEWORK_DIR}/$binary
cp basic_Info.plist ${FRAMEWORK_DIR}/Info.plist
plutil -replace CFBundleExecutable -string $binary ${FRAMEWORK_DIR}/Info.plist
plutil -replace CFBundleName -string $binary ${FRAMEWORK_DIR}/Info.plist
plutil -replace CFBundleIdentifier -string Nicolas-Holzschuch.$binary  ${FRAMEWORK_DIR}/Info.plist
install_name_tool -id @rpath/$binary.framework/$binary   ${FRAMEWORK_DIR}/$binary

# 2) build for iOS simulator:
# 2a) configure with all the right flags:
make distclean
env CC=clang CXX=clang++ \
	CPPFLAGS="-arch x86_64 -miphonesimulator-version-min=14.0 -isysroot $SIM_SDKROOT -I$PREFIX/Frameworks_iphonesimulator/include -F$PREFIX/Frameworks_iphonesimulator " \
	CFLAGS="-arch x86_64 -miphonesimulator-version-min=14.0 -isysroot $SIM_SDKROOT -I$PREFIX/Frameworks_iphonesimulator/include -F$PREFIX/Frameworks_iphonesimulator " \
	CXXFLAGS="-arch x86_64 -miphonesimulator-version-min=14.0 -isysroot $SIM_SDKROOT -I$PREFIX/Frameworks_iphonesimulator/include " \
	LDFLAGS="-dynamiclib -arch x86_64 -miphonesimulator-version-min=14.0 -isysroot $SIM_SDKROOT -F$PREFIX/Frameworks_iphonesimulator -framework ios_system -L$PREFIX/Frameworks_iphonesimulator/lib -lz" \
	LDSHARED="clang -v -undefined error -dynamiclib -isysroot $SIM_SDKROOT -F$PREFIX/Frameworks_iphonesimulator -framework ios_system -L$PREFIX/Frameworks_iphonesimulator/lib" \
	PATH="/usr/bin:/bin:/usr/sbin:/sbin" \
	PLATFORM=iphonesimulator \
	./configure --disable-shared \
	--host x86_64-apple-darwin --with-quantum-depth=8 --disable-installed --without-modules --disable-hdri --with-lzma=no --with-fftw=no --with-pango=no --with-openexr=no --with-gslib=no --with-dps=no --with-png=yes  PNG_CFLAGS="-F$PREFIX/Frameworks_iphonesimulator" PNG_LIBS="-framework libpng"  PSDelegateDefault="no" --with-freetype FREETYPE_LIBS="-framework freetype"  FREETYPE_CFLAGS="-F$PREFIX/Frameworks_iphonesimulator" ac_cv_func_fork=no ac_cv_func_fork_works=no ac_cv_func_vfork=no ac_cv_func_vfork_works=no 

# 2b) make:
make
# utilities/magick is now a dynamic library containing everything (and linking libpng, freetype, ios_system, SystemB, libz and libbz2)

# Let's make a framework out of that:

binary=magick
FRAMEWORK_DIR=build/Release-iphonesimulator/$binary.framework
rm -rf ${FRAMEWORK_DIR}
mkdir -p ${FRAMEWORK_DIR}
cp utilities/magick ${FRAMEWORK_DIR}/$binary
cp basic_Info.plist ${FRAMEWORK_DIR}/Info.plist
plutil -replace CFBundleExecutable -string $binary ${FRAMEWORK_DIR}/Info.plist
plutil -replace CFBundleName -string $binary ${FRAMEWORK_DIR}/Info.plist
plutil -replace CFBundleIdentifier -string Nicolas-Holzschuch.$binary  ${FRAMEWORK_DIR}/Info.plist
install_name_tool -id @rpath/$binary.framework/$binary   ${FRAMEWORK_DIR}/$binary

framework=magick
rm -rf $framework.xcframework
xcodebuild -create-xcframework -framework build/Release-iphoneos/$framework.framework -framework build/Release-iphonesimulator/$framework.framework -output $framework.xcframework
rm -f $framework.xcframework.zip
zip -rq $framework.xcframework.zip $framework.xcframework
swift package compute-checksum $framework.xcframework.zip

