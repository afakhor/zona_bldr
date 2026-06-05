plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

// Menggunakan ApplicationExtension sesuai perintah eror robot
configure<com.android.build.api.dsl.ApplicationExtension> {
    namespace = "com.heruwngchn.addhmescrn"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // Menggunakan compilerOptions baru untuk menggantikan kotlinOptions yang usang
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }

    defaultConfig {
        applicationId = "com.heruwngchn.addhmescrn"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
