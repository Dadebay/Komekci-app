# Notification logo

- Reused the supplied KÖMEKÇI logo as the Android local notification large icon and replaced all referenced iOS app icon sizes with opaque, square versions. iOS displays its app icon beside push notifications.
- Added a transparent monochrome K mark for Android's small notification icon and set it as both the FCM default icon and the local notification icon. Android does not display a full-color image in the small status icon slot.
- Updated the appointment reminder test fake for the notification service members added earlier in the session.
- Verified: Android debug APK build, iOS simulator build, six notification/reminder tests, targeted Flutter analyzer, and all 19 iOS icon references present.
