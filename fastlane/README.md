fastlane documentation
================
# Installation
```
sudo gem install fastlane
```
# Available Actions
## iOS
### ios test
```
fastlane ios test
```
Run unit tests
### ios demo
```
fastlane ios demo
```
Build the demo app
### ios lint
```
fastlane ios lint
```
Lint the source code and other linteable artifacts
### ios update_docs
```
fastlane ios update_docs
```
Update documentation and publish them
### ios ci_all
```
fastlane ios ci_all
```
Execute all CI lanes

This action can be configured using the following environment variable:



- `LINT`:           Whether the sources and certain artifacts should be linted defaults to `YES`

- `RUN_TESTS`:      Whether unit tests should be run, defaults to `YES`

- `BUILD_DEMO_APP`: Whether the demo app should be built or not, defaults to `YES`

- `RUN_DANGER`:     Whether Danger should be run or not, defaults to `YES`

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [https://fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [GitHub](https://github.com/fastlane/fastlane/tree/master/fastlane).
