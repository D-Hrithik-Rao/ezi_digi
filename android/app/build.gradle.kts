plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.ezi_cable_digi"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
         isCoreLibraryDesugaringEnabled = true   
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.ezi_cable_digi"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    flavorDimensions += "default"

    productFlavors {
        create("ezy") {
            dimension = "default"
            applicationId = "com.ezy.cable.digi"
            resValue("string", "app_name", "Ezy Cable Digi")
        }

        create("magik") {
            dimension = "default"
            applicationId = "com.magik.cable.digi"
            resValue("string", "app_name", "Magik Digi")
        }
    }
}

flutter {
    source = "../.."
}
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
