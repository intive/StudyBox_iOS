#!/bin/sh
set -e

brew update
brew install xctool || brew outdated xctool || brew upgrade xctool

gem install xcpretty
