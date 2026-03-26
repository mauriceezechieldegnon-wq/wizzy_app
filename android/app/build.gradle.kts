plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}

def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader('UTF-8') { reader ->
        localProperties.load(reader)
    }
}

def flutterVersionCode = localProperties.getProperty('flutter.versionCode')
if (flutterVersionCode == null) {
    flutterVersionCode = '1'
}

def flutterVersionName = localProperties.getProperty('flutter.versionName')
if (flutterVersionName == null) {
    flutterVersionName = '1.0'
}

android {
    namespace "com.dem.wizzy" // VÉRIFIE QUE C'EST BIEN TON ID
    compileSdk 34 // Mis à jour pour 2026

    compileOptions {
        // --- ACTIVATION DU DESUGARING POUR LES NOTIFICATIONS ---
        coreLibraryDesugaringEnabled true
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = '1.8'
    }

    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }

    defaultConfig {
        applicationId "com.dem.wizzy" // VÉRIFIE QUE C'EST BIEN TON ID
        minSdkVersion 21 // Requis pour la plupart des plugins
        targetSdkVersion 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
        
        // --- REQUIS POUR LES GROSSES APPS ---
        multiDexEnabled true
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug // Pour tes tests APK
            shrinkResources false
            minifyEnabled false
        }
    }
}

flutter {
    source '../..'
}

dependencies {
    // --- LA BIBLIOTHÈQUE MAGIQUE POUR FIXER L'ERREUR DE BUILD ---
    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.0.3'
}