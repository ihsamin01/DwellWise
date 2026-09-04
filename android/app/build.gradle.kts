plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.dwell_wise"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications schedules against java.time, which
        // older Android versions do not carry; desugaring supplies it.
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.dwell_wise"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // record (voice) + geolocator need API 23+.
        minSdk = maxOf(flutter.minSdkVersion, 23)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        // Shared debug key, committed to the repo on purpose.
        //
        // Flutter's default debug key lives in each developer's own
        // ~/.android/debug.keystore, so every machine produces a different
        // SHA-1. Google Sign-In checks that SHA-1 against the Android OAuth
        // client, so builds from any machine but the one registered in Google
        // Cloud Console fail with ApiException 10 (DEVELOPER_ERROR). Signing
        // with one key the whole team shares keeps that fingerprint stable.
        //
        // This is a debug key only — it must never sign a Play Store release.
        getByName("debug") {
            storeFile = file("../keystore/dwellwise-debug.jks")
            storePassword = "dwellwise"
            keyAlias = "dwellwise"
            keyPassword = "dwellwise"
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
