plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.tivoo"
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.tivoo"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // Banuba Face AR needs Android 8.0+.
        minSdk = maxOf(flutter.minSdkVersion, 26)
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

val bnbSdkVersion = rootProject.extra["bnb_sdk_version"] as String

dependencies {
    // Banuba face tracking + background segmentation for AR effects.
    implementation("com.banuba.sdk:face_tracker:$bnbSdkVersion")
    implementation("com.banuba.sdk:background:$bnbSdkVersion")
}

// Banuba loads effects from assets/bnb-resources/effects: copy the project's effects/ folder there.
val copyBanubaEffects by tasks.registering(Copy::class) {
    from(rootProject.file("../effects"))
    into(layout.projectDirectory.dir("src/main/assets/bnb-resources/effects"))
}
tasks.named("preBuild") { dependsOn(copyBanubaEffects) }
