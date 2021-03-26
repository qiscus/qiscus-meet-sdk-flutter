# qiscus_meet

Qiscus Meet is a WebRTC compatible, free and Open Source video conferencing system that provides browsers and mobile applications with Real Time Communications capabilities.
## Getting Started

## Configuration

<a name="ios"></a>
### IOS
* Note: Example compilable with XCode 12.2 & Flutter 1.22.4.

#### Podfile
Ensure in your Podfile you have an entry like below declaring platform of 11.0 or above.
```
platform :ios, '11.0'
```

#### Info.plist
Add NSCameraUsageDescription and NSMicrophoneUsageDescription to your
Info.plist.

```text
<key>NSCameraUsageDescription</key>
<string>$(PRODUCT_NAME) MyApp needs access to your camera for meetings.</string>
<key>NSMicrophoneUsageDescription</key>
<string>$(PRODUCT_NAME) MyApp needs access to your microphone for meetings.</string>
```

<a name="android"></a>
### Android

#### Gradle
Set dependencies of build tools gradle to minimum 3.6.3:
```gradle
dependencies {
    classpath 'com.android.tools.build:gradle:3.6.3' <!-- Upgrade this -->
    classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
}
```

Set distribution gradle wrapper to minimum 5.6.4.
```gradle
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-5.6.4-all.zip <!-- Upgrade this -->
```

Add Java 1.8 compatibility support to your project by adding the following lines into your build.gradle file:
```gradle
compileOptions {
    sourceCompatibility JavaVersion.VERSION_1_8
    targetCompatibility JavaVersion.VERSION_1_8
}
```

#### AndroidManifest.xml
Qiscus Meet's SDK AndroidManifest.xml will conflict with your project, namely
the application:label field. To counter that, go into
`android/app/src/main/AndroidManifest.xml` and add the tools library
and `tools:replace="android:label"` to the application tag.

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="yourpackage.com"
    xmlns:tools="http://schemas.android.com/tools"> <!-- Add this -->
    <application
        tools:replace="android:label"
        android:name="your.application.name"
        android:label="My Application"
        android:icon="@mipmap/ic_launcher">
        ...
    </application>
...
</manifest>
```

#### Minimum SDK Version 23
Update your minimum sdk version to 23 in android/app/build.gradle
```groovy
defaultConfig {
    applicationId "com.qiscus.qiscusmeet"
    minSdkVersion 23 //Required for QiscusMeet
    targetSdkVersion 28
    versionCode flutterVersionCode.toInteger()
    versionName flutterVersionName
}
```

#### Proguard

Qiscus SDK enables proguard, but without a proguard-rules.pro file, your release
apk build will be missing the Flutter Wrapper as well as react-native code.
In your Flutter project's android/app/build.gradle file, add proguard support

```groovy
buildTypes {
    release {
        // TODO: Add your own signing config for the release build.
        // Signing with the debug keys for now, so `flutter run --release` works.
        signingConfig signingConfigs.debug

        // Add below 3 lines for proguard
        minifyEnabled true
        useProguard true
        proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
    }
}
```

Then add a file in the same directory called proguard-rules.pro. See the example
app's [proguard-rules.pro](example/android/app/proguard-rules.pro) file to know what to paste in.

*Note*
If you do not create the proguard-rules.pro file, then your app will
crash when you try to join a meeting or the meeting screen tries to open
but closes immediately. You will see one of the below errors in logcat.

```
## App crashes ##
java.lang.RuntimeException: Parcel android.os.Parcel@8530c57: Unmarshalling unknown type code 7536745 at offset 104
    at android.os.Parcel.readValue(Parcel.java:2747)
    at android.os.Parcel.readSparseArrayInternal(Parcel.java:3118)
    at android.os.Parcel.readSparseArray(Parcel.java:2351)
    .....
```

```
## Meeting won't open and you go to previous screen ##
W/unknown:ViewManagerPropertyUpdater: Could not find generated setter for class com.BV.LinearGradient.LinearGradientManager
W/unknown:ViewManagerPropertyUpdater: Could not find generated setter for class com.facebook.react.uimanager.g
W/unknown:ViewManagerPropertyUpdater: Could not find generated setter for class com.facebook.react.views.art.ARTGroupViewManager
W/unknown:ViewManagerPropertyUpdater: Could not find generated setter for class com.facebook.react.views.art.a
.....
```


##Setup Call

 @override
  void initState() {
    super.initState();
    MeetInfo.addListener(QiscusMeetListener(
        onConferenceWillJoin: _onConferenceWillJoin,
        onConferenceJoined: _onConferenceJoined,
        onConferenceTerminated: _onConferenceTerminated,
        onPictureInPictureWillEnter: _onPictureInPictureWillEnter,
        onPictureInPictureTerminated: _onPictureInPictureTerminated,
        onError: _onError));
  }

_joinMeeting() async {
    QiscusMeet.setup("meetstage-iec22sd", "https://call.qiscus.com");
    MeetJwtConfig meetJwtConfig = MeetJwtConfig();
    meetJwtConfig.setEmail("marco@qiscus.com");
    meetJwtConfig.build();
    QiscusMeet.config().setJwtConfig(meetJwtConfig);
    await QiscusMeet.call(
            roomText.text,
            nameText.text,
            "https://d1.awsstatic.com/events/aws-hosted-events/2020/APAC/case-studies/case-study-logo-qiscus.5433a4b9da2693dd49766a971aac887ece8c6d18.png",
            "Qiscus Meet : ${roomText.text}",
            false)
        .build();
  }
<a name="qiscusmeetingoptions"></a>

## Meet Jwt Config
| Field             | Required  | Default           | Description |
 ------------------ | --------- | ----------------- | ----------- |
| email             | Yes       | N/A               | User's email |
| displayName       | Yes       | N/A               | User's display name. |

### QiscusMeet Call Parameter

| Field             | Required  | Default           | Description |
 ------------------ | --------- | ----------------- | ----------- |
| roomId            | Yes       | N/A               | Unique room name that will be appended to serverURL. Valid characters: alphanumeric, dashes, and underscores. |
| displayName       | Yes       | N/A               | User's display name. |
| avatar            | Yes       | "Qiscus logo"     | User's avatar URL. |
| isMuted           | Yes       | false             | Start meeting with audio muted. Can be turned on in meeting. |


### Listening to Meeting Events

Events supported

| Name                   | Description  |
| :--------------------- | :----------- |
| onConferenceWillJoin   | Meeting is loading. |
| onConferenceJoined     | User has joined meeting. |
| onConferenceTerminated | User has exited the conference. |
| onPictureInPictureWillEnter | User entered PIP mode. |
| onPictureInPictureTerminated | User exited PIP mode. |
| onError                | Error has occurred with listening to meeting events. |


  @override
  void dispose() {
    super.dispose();
    MeetInfo.removeAllListeners();
  }


_onConferenceWillJoin({message}) {
  debugPrint("_onConferenceWillJoin broadcasted");
}

_onConferenceJoined({message}) {
  debugPrint("_onConferenceJoined broadcasted");
}

_onConferenceTerminated({message}) {
  debugPrint("_onConferenceTerminated broadcasted");
}

_onPictureInPictureWillEnter({message}) {
debugPrint("_onPictureInPictureWillEnter broadcasted with message: $message");
}

_onPictureInPictureTerminated({message}) {
debugPrint("_onPictureInPictureTerminated broadcasted with message: $message");
}

_onError(error) {
  debugPrint("_onError broadcasted");
}
```

### Closing a Meeting Programmatically
```dart
QiscusMeet.endCall();
```