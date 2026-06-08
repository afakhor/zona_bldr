plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.heruwngchn.addhmescrn"
    compileSdk = 34
    ndkVersion = "26.3.11579264"  // Tambahin ini

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.heruwngchn.addhmescrn"
        minSdk = 21
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
        debug {
            // Biar debug juga jelas
        }
    }
}

flutter {
    source = "../.."
}

dependencies {}

subprojects {
    afterEvaluate { project ->
        if (project.hasProperty("android")) {
            project.android {
                compileSdkVersion 34
                buildToolsVersion "34.0.0"
            }
        }
    }
}