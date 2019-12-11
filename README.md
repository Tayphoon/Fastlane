### Overview

**fastlane** is a collection of `fastlane` lanes and custom actions used in projects.

### Lanes

- `buildConfiguration` - Build app and generate archive if needed.
- `runTests` - Run unit tests.
- `fabric` - Upload build to Fastlane.
- `appleTestflight` - Upload build to Testflight.
- `plistInfoPath` - Get plist info file path.

### Requirements

https://github.com/libimobiledevice/ideviceinstaller

### Custom Actions

- `adhoc_html_generator` - Generate html page and plist file for OTA installation.
- `git_checkout` - Checkouts the branch.
- `git_checkout_release` - Checkouts the latest release or hotfix branch - or creates a new one.
- `git_reset` - Performs a git reset.
- `idevice_debug` - Wrapper under idevicedebug tool.
- `idevice_installer` - Wrapper under ideviceinstaller tool.
- `multiple_tags` - Creates and pushes multple git tags at once.
- `telegram` - Sends a message to our Telegram chat.

### License

MIT Tayphoon
