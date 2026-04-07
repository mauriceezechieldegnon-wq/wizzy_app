import java.util.Properties // AJOUTÉ : Import explicite pour régler l'erreur 'util'

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties() // Changé ici (plus besoin du préfixe java.util)
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.reader(Charsets.UTF_8).use { reader ->
        localProperties.load(reader)
    }
}

val flutterVersionCode = localProperties.getProperty("flutter.versionCode") ?: "1"
val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0"

android {
    namespace = "com.dem.wizzy" // Ton identifiant unique
    compileSdk = 36

    compileOptions {
        // --- ACTIVATION DU DESUGARING POUR LES NOTIFS ---
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.dem.wizzy"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName
        
        // --- REQUIS POUR LES NOTIFICATIONS ---
        multiDexEnabled = true
    }

    buildTypes {
        getByName("release") {
            // Utilisation du signing de debug pour que l'APK soit installable tout de suite
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // --- LA BIBLIOTHÈQUE MAGIQUE POUR LES NOTIFS ET LES DATES ---
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
