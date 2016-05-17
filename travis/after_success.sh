#!/bin/sh

set -e

if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
  echo "This is a pull request. No deployment will be done."
  exit 0
fi
if [[ "$TRAVIS_BRANCH" != "master" ]]; then
  echo "Testing on a branch other than master. No deployment will be done."
  exit 0
fi

echo "Decrypt files"

APPLE_CERTIFICATE="$PWD/travis/certs/apple.cer"
CERTIFICATE="$PWD/travis/certs/dist.cer"
PRIVATE_KEY="$PWD/travis/certs/dist.p12"
PROFILE="$PWD/travis/profile/profile.mobileprovision"

# encrypt files with:
# openssl aes-256-cbc -k ENCRYPTION_SECRET -in FILE -out FILE.enc -a
#
# certificate and private key must be valid and matching the provisioning profile
#
# add encrypted key to travis:
# travis encrypt "ENCRYPTION_SECRET=somekey" --add

openssl aes-256-cbc -k "$ENCRYPTION_SECRET" -in "$PROFILE.enc" -d -a -out "$PROFILE"
openssl aes-256-cbc -k "$ENCRYPTION_SECRET" -in "$CERTIFICATE.enc" -d -a -out "$CERTIFICATE"
openssl aes-256-cbc -k "$ENCRYPTION_SECRET" -in "$PRIVATE_KEY.enc" -d -a -out "$PRIVATE_KEY"

echo "Create constants"

PLIST_BUDDY="/usr/libexec/PlistBuddy"
INFO_PLIST="$PWD/StudyBox_iOS/Info.plist"

WORKSPACE="StudyBox_iOS.xcworkspace"
SCHEME="StudyBox_iOS"
APP_NAME="StudyBox_iOS"
CONFIGURATION="Release"

UUID=`$PLIST_BUDDY -c Print:UUID /dev/stdin <<< \`security cms -D -i $PROFILE\``
PROFILES_PATH="$HOME/Library/MobileDevice/Provisioning Profiles"
PROFILE_TARGET="$PROFILES_PATH/$UUID.mobileprovision"

KEYCHAIN_NAME="ios-build.keychain"
KEYCHAIN_PATH="$HOME/Library/Keychains/$KEYCHAIN_NAME"
DEVELOPER_NAME="iPhone Developer: Piotr Tobolski (JZG64W4RK3)"

ARCHIVE_PATH="$PWD/build/$APP_NAME.xcarchive"
DSYM_PATH="$ARCHIVE_PATH/dSYMs/$APP_NAME.app.dSYM"
IPA_PATH="$PWD/build/$APP_NAME.ipa"

FABRIC="$PWD/Pods/Fabric/upload-symbols"
CRASHLYTICS="$PWD/Pods/Crashlytics/submit"
FABRIC_GROUP_ALIASES="patronage-2016-qa"

echo "Update build number"

"$PLIST_BUDDY" -c "Set :CFBundleVersion travis-$TRAVIS_BUILD_NUMBER" "$INFO_PLIST"

echo "Setting up certificates and keys"

if [[ -f "$KEYCHAIN_PATH" ]]; then
    security delete-keychain "$KEYCHAIN_NAME"
fi

security create-keychain -p travis "$KEYCHAIN_NAME"
security default-keychain -s "$KEYCHAIN_NAME"
security unlock-keychain -p travis "$KEYCHAIN_NAME"
security set-keychain-settings -t 3600 -l "$KEYCHAIN_PATH"
security import "$APPLE_CERTIFICATE" -k "$KEYCHAIN_PATH" -T /usr/bin/codesign
security import "$CERTIFICATE" -k "$KEYCHAIN_PATH" -T /usr/bin/codesign
security import "$PRIVATE_KEY" -k "$KEYCHAIN_PATH" -P "$KEY_PASSWORD" -T /usr/bin/codesign

# Put the provisioning profile in place
mkdir -p "$PROFILES_PATH"
cp "$PROFILE" "$PROFILE_TARGET"

echo "Building and archiving"

xcodebuild \
    -workspace "$WORKSPACE" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
	-hideShellScriptEnvironment \
    ONLY_ACTIVE_ARCH="NO" \
    CODE_SIGN_IDENTITY="$DEVELOPER_NAME" \
    PROVISIONING_PROFILE="$UUID" \
    archive -archivePath "$ARCHIVE_PATH"

echo "Creating IPA"

xcrun xcodebuild \
    -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$IPA_PATH" \
    -exportFormat ipa \
    -hideShellScriptEnvironment

echo "Uploading IPA"

"$CRASHLYTICS" \
    "$FABRIC_API_KEY" \
    "$FABRIC_BUILD_SECRET" \
    -ipaPath "$IPA_PATH" \
    -notifications "YES" \
	-groupAliases "$FABRIC_GROUP_ALIASES" \
    -debug "YES"

echo "Uploading dSYM"

"$FABRIC" \
    --api-key "$FABRIC_API_KEY" \
    --platform ios \
    -- \
    "$DSYM_PATH"

security delete-keychain ios-build.keychain
