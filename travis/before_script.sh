#!/bin/sh
set -e

brew update
brew install xctool || brew outdated xctool || brew upgrade xctool
brew install xcpretty || brew outdated xcpretty || brew upgrade xcpretty
