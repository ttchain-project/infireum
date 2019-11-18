fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV -n /usr/local/bin
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios addBuild
```
fastlane ios addBuild
```
Description of what the lane does

Update All Build Number
### ios match_sit_dev
```
fastlane ios match_sit_dev
```
Match SIT Dev
### ios match_sit_adhoc
```
fastlane ios match_sit_adhoc
```
Match SIT ADHOC
### ios adhoc_sit
```
fastlane ios adhoc_sit
```
Build adhoc .ipa [SIT]
### ios hockey_sit
```
fastlane ios hockey_sit
```
upload adhoc .ipa [SIT] to hockey
### ios match_uat_dev
```
fastlane ios match_uat_dev
```
Match UAT DEV
### ios match_uat_adhoc
```
fastlane ios match_uat_adhoc
```
Match UAT ADHOC
### ios adhoc_uat
```
fastlane ios adhoc_uat
```
Build adhoc .ipa [uat]
### ios hockey_uat
```
fastlane ios hockey_uat
```
upload adhoc .ipa [UAT] to hockey
### ios match_prd_dev
```
fastlane ios match_prd_dev
```
Match PRD DEV
### ios match_prd_adhoc
```
fastlane ios match_prd_adhoc
```
Match PRD ADHOC
### ios adhoc_prd
```
fastlane ios adhoc_prd
```
Build adhoc .ipa [PRD]
### ios hockey_prd
```
fastlane ios hockey_prd
```
upload adhoc .ipa [PRD] to hockey
### ios release
```
fastlane ios release
```

### ios adhoc_sit_uat
```
fastlane ios adhoc_sit_uat
```
Create test(SIT/UAT) adhoc
### ios adhoc_all
```
fastlane ios adhoc_all
```
Create all adhoc
### ios match_all
```
fastlane ios match_all
```
Create all matches

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
