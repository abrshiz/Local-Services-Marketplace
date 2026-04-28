plugins {
    alias(libs.plugins.android.application)
}

android {
    namespace = "com.example.localservicemarketplace"

    compileSdk = 32

    defaultConfig {
        applicationId = "com.example.localservicemarketplace"
        minSdk = 24
        targetSdk = 32

        versionCode = 1
        versionName = "1.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
}

dependencies {

    // Core Android libraries (SAFE for API 32)
    implementation("androidx.core:core-ktx:1.10.1")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.9.0")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")

    // Activity (compatible version)
    implementation("androidx.activity:activity:1.7.2")

    // Lifecycle (stable for API 32)
    implementation("androidx.lifecycle:lifecycle-runtime:2.6.1")

    // Testing
    testImplementation("junit:junit:4.13.2")
    androidTestImplementation("androidx.test.ext:junit:1.1.5")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.5.1")
}