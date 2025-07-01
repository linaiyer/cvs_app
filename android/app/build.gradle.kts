import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("com.google.gms.google-services") version "4.4.1"
    id("dev.flutter.flutter-gradle-plugin")
}

repositories {
    google()
    mavenCentral()
    maven { url = uri("${buildDir}/host/outputs/repo") }
    maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
}

android {
    namespace = "com.research.cvs"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.research.cvs"
        minSdk = 23
        targetSdk = 35
        versionCode = 5
        versionName = "1.0.0"
        multiDexEnabled = true
        ndk {
            abiFilters.addAll(listOf("armeabi-v7a", "arm64-v8a", "x86", "x86_64"))
        }
    }

    signingConfigs {
        create("release") {
            val kPropsFile = rootProject.file("key.properties")
            if (kPropsFile.exists()) {
                val k = Properties()
                kPropsFile.inputStream().use { k.load(it) }
                keyAlias = k["keyAlias"] as String?
                keyPassword = k["keyPassword"] as String?
                storeFile = (k["storeFile"] as? String)?.let { v -> project.file(v) }
                storePassword = k["storePassword"] as String?
            }
        }
    }
    buildTypes {
        getByName("release") {
            // Uncomment to enable signing for release
            // signingConfig = signingConfigs.getByName("release")
        }
    }
    lint {
        disable.addAll(listOf("InvalidPackage", "Instantiatable"))
        checkReleaseBuilds = false
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    implementation("org.jetbrains.kotlin:kotlin-stdlib")
    debugImplementation("io.flutter:flutter_embedding_debug:1.0.0-3316dd8728419ad3534e3f6112aa6291f587078a")
    profileImplementation("io.flutter:flutter_embedding_profile:1.0.0-3316dd8728419ad3534e3f6112aa6291f587078a")
    releaseImplementation("io.flutter:flutter_embedding_release:1.0.0-3316dd8728419ad3534e3f6112aa6291f587078a")
    implementation("androidx.multidex:multidex:2.0.1")
    implementation(platform("com.google.firebase:firebase-bom:33.1.1"))
    implementation("com.google.firebase:firebase-analytics-ktx")
    implementation("com.google.firebase:firebase-auth-ktx")
    implementation("com.google.firebase:firebase-messaging-ktx")
    implementation("com.jakewharton.threetenabp:threetenabp:1.4.5")
    testImplementation("junit:junit:4.13.2")
    androidTestImplementation("androidx.test:runner:1.5.2")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.5.1")
}

// Apply Google Services plugin
// apply(plugin = "com.google.gms.google-services")
