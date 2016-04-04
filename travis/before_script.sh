#!/bin/sh
set -e

brew update

# brew install xctool || brew outdated xctool || brew upgrade xctool
brew uninstall --force xctool
brew install --HEAD xctool