#!/bin/sh

scons platform=ios || exit 1
scons platform=ios ios_arch=x86_64 || exit 1

lipo -create -output bin/liblocalnotification.fat.a bin/liblocalnotification_arm64.a bin/liblocalnotification_x86_64.a

rm bin/liblocalnotification_arm64.a
rm bin/liblocalnotification_x86_64.a
