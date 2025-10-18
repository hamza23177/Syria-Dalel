plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter plugin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.untitled2"
    compileSdk = flutter.compileSdkVersion

    ndkVersion = "27.0.12077973"

    compileOptions {
        // ✅ دعم Java 8
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8

        // ✅ الطريقة الصحيحة في Kotlin DSL لتفعيل desugaring
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.untitled2"
        minSdk = 21
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ✅ مكتبة desugaring المطلوبة - آخر إصدار متوافق
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

