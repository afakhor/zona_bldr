plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.zona_bldr" // Ganti sesuai package kamu
    compileSdk = 34
    
    defaultConfig {
        minSdk = 21
        targetSdk = 34
    }
}