import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.reader(Charsets.UTF_8).use { reader -> localProperties.load(reader) }
}

android {
    namespace = "com.dem.wizzy"
    compileSdk = 36 // Mis à jour pour les plugins récents

    

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        // CHANGE ICI : Passe de VERSION_1_8 à VERSION_17
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        
        jvmTarget = "17"
    }
    
   

    defaultConfig {
        applicationId = "com.dem.wizzy"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        multiDexEnabled = true
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
