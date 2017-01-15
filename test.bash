#! /bin/bash
set -e errexit
set -o pipefail
xcodebuild -scheme EonilPco -configuration Debug clean build test
xcodebuild -scheme EonilPco -configuration Release clean build
