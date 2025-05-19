import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localProperties.load(localPropertiesFile.inputStream())
}
val flutterVersionCode = localProperties["flutter.versionCode"]?.toString()?.toIntOrNull() ?: 1
val flutterVersionName = localProperties["flutter.versionName"]?.toString() ?: "1.0"

android {
    namespace = "com.example.reservini"

    compileSdk = 35
    ndkVersion = "29.0.13113456"

    defaultConfig {
        applicationId = "com.example.reservini"
        minSdk = 23
        targetSdk = 35
        versionCode = flutterVersionCode
        versionName = flutterVersionName
    }

    // ✅ ACTIVATION DU DESUGARING
    compileOptions {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
    isCoreLibraryDesugaringEnabled = true // ✅ syntaxe correcte en Kotlin DSL
}


    kotlinOptions {
        jvmTarget = "17"
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

dependencies {
    // ✅ DÉPENDANCE NÉCESSAIRE POUR flutter_local_notifications
 coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
