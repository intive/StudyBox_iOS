#!/bin/sh
set -e

PLATFORM="platform=iOS Simulator,OS=9.3,name=iPhone 6s"
WORKSPACE="StudyBox_iOS.xcworkspace"
SCHEME="StudyBox_iOS"

xcodebuild \
    -workspace "$WORKSPACE" \
    -scheme "$SCHEME" \
	-destination "$PLATFORM" \
    -hideShellScriptEnvironment \
	test \
	| xcpretty
