# Android first, iOS brought up later

The app targets Android and iOS, but v1 is built and verified on Android only. Development happens on Windows with a physical Android phone, and building or running for iOS requires a Mac, which is not available yet. Code is written to be platform-neutral (Flutter makes most of it so), but the iOS-only setup is collected in a separate iOS bring-up ticket for when Mac access exists: an Apple Developer account, Sign in with Apple, an APNs key for push notifications, and testing on an iPhone.

Sign in with Apple moves to that ticket too. Apple requires it in iOS apps that offer Google sign-in, so it only matters once the app ships on iOS. On Android, Google plus the email one-time code is enough.

The web and desktop platform folders are removed. Adding one back later is `flutter create --platforms=<name> .`.

## Considered Options

- **Drop iOS from v1 entirely**: rejected, because keeping the code platform-neutral costs little and the bring-up ticket keeps the remaining work visible.
- **Cloud Mac build service (such as Codemagic)**: possible for the bring-up ticket, but it does not replace testing on a real iPhone.
