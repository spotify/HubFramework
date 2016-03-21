# The Hub Framework

[![Code coverage](https://codecov.spotify.net/github_enterprise/iOS/HubFramework/coverage.svg?branch=master)](https://codecov.spotify.net/github_enterprise/iOS/HubFramework?branch=master)

The Hub Framework is a Spotify feature developer toolkit that aims to reduce a lot of the boilerplate and code duplication involved in developing a feature for the iOS app. The goal is to  automate a series of repetitive developer tasks and let feature developers focus on what makes their feature awesome.

This repository contains Hub Framework functionality that has no dependencies on client-ios and can operate independently.

Over time, more and more functionality will be moved from the HubFeature in client-ios into this repository.

## Xcode file templates

The Hub Framework comes with a set of Xcode file templates that make it easy to create the boilerplate for components, content providers, etc. To install, copy the `Hub Framework` folder located in `templates/xcode` to `~/Library/Developer/Xcode/Templates/File Templates` (You may need to create the last two folders in that path).
