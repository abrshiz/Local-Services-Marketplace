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
    // Core Android libraries
    implementation("androidx.core:core-ktx:1.10.1")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.9.0")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")

    // Material Design 3 Components
    implementation("com.google.android.material:material:1.9.0")

    // CardView and RecyclerView
    implementation("androidx.cardview:cardview:1.0.0")
    implementation("androidx.recyclerview:recyclerview:1.3.0")

    // Activity and Lifecycle
    implementation("androidx.activity:activity:1.7.2")
    implementation("androidx.lifecycle:lifecycle-runtime:2.6.1")

    // Image Loading
    implementation("com.github.bumptech.glide:glide:4.15.1")

    // Circular ImageView
    implementation("de.hdodenhof:circleimageview:3.1.0")

    // Testing
    testImplementation("junit:junit:4.13.2")
    androidTestImplementation("androidx.test.ext:junit:1.1.5")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.5.1")
}