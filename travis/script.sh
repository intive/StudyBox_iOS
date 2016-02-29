#!/bin/sh
set -e

PLATFORM="platform=iOS Simulator,OS=9.2,name=iPhone 6s"
SDK="iphonesimulator9.2"

xctool \
    -workspace StudyBox_iOS.xcworkspace \
    -scheme StudyBox_iOS \
    -sdk "$SDK" \
    -destination "$PLATFORM" \
    build test