#! /bin/bash

xcodebuild -scheme EonilPco -configuration Debug clean build test
xcodebuild -scheme EonilPco -configuration Release clean build
