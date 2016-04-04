#!/bin/sh
set -e

PLATFORM="platform=iOS Simulator,OS=9.3,name=iPhone 6s"
SDK="iphonesimulator9.3"
WORKSPACE="StudyBox_iOS.xcworkspace"
SCHEME="StudyBox_iOS"


xctool \
    -workspace "$WORKSPACE" \
    -scheme "$SCHEME" \
    -sdk "$SDK" \
    -destination "$PLATFORM" \
    build test
