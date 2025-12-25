plugins {
    id("com.android.application")
    id("kotlin-android")
    id("org.jetbrains.kotlin.plugin.serialization") version "2.1.0"
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.grammar_up"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.grammar_up"
        minSdk = flutter.minSdkVersion
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion  // Required for Google Sign In
        minSdk = flutter.minSdkVersion  // Minimum SDK for Google Sign In
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true  // Enable multidex for Google Sign In
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

dependencies {
    // Multidex support for Google Sign In
    implementation("androidx.multidex:multidex:2.0.1")
    // Core library desugaring (required by flutter_local_notifications)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    
    // Multidex support for Google Sign In
    implementation("androidx.multidex:multidex:2.0.1")
    
    // OkHttp for REST API calls (simpler than Supabase SDK)
    implementation("com.squareup.okhttp3:okhttp:4.12.0")
    
    // Coroutines
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.9.0")
    
    // JSON parsing
    implementation("org.json:json:20231013")
    
    // Firebase for push notifications
    implementation(platform("com.google.firebase:firebase-bom:33.7.0"))
    implementation("com.google.firebase:firebase-messaging-ktx")
    
    // Play services tasks (for FCM coroutines support)
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-play-services:1.9.0")
}

apply(plugin = "com.google.gms.google-services")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.11.0")
}

// ========================================
// GOOGLE SERVICES PLUGIN
// ========================================
// Uncomment dòng dưới sau khi:
// 1. Đã download google-services.json từ Firebase
// 2. Đã đặt file vào android/app/google-services.json
// 3. Đã cấu hình SHA-1 trong Firebase Console
//
// apply(plugin = "com.google.gms.google-services")
