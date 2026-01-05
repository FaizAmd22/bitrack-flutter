import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// ✅ ambil GOOGLE_MAPS_API_KEY dari local.properties
val localProperties = Properties().apply {
    val f = rootProject.file("local.properties")
    if (f.exists()) f.inputStream().use { load(it) }
}

val googleMapsApiKey: String =
    (localProperties.getProperty("GOOGLE_MAPS_API_KEY") ?: "").trim()

android {
    namespace = "com.example.bitrack_mobile_flutter"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.bitrack_mobile_flutter"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // ✅ Kotlin DSL: manifestPlaceholders adalah MutableMap
        manifestPlaceholders.putAll(
            mapOf("GOOGLE_MAPS_API_KEY" to googleMapsApiKey)
        )
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
