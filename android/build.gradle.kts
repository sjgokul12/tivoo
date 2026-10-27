// Native Banuba Face AR SDK version used by the banuba_sdk Flutter plugin.
extra["bnb_sdk_version"] = "1.18.5"

allprojects {
    repositories {
        google()
        mavenCentral()
        // Banuba Face AR SDK
        maven { url = uri("https://nexus.banuba.net/repository/maven-releases") }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
// banuba_sdk hard-codes compileSdkVersion 31, but its AndroidX dependencies need 34+.
// Raise it after the plugin's own build file has run (this must come before evaluationDependsOn).
subprojects {
    if (name == "banuba_sdk") {
        val raiseCompileSdk = {
            extensions.findByType(com.android.build.api.dsl.LibraryExtension::class.java)?.compileSdk = 37
        }
        if (state.executed) raiseCompileSdk() else afterEvaluate { raiseCompileSdk() }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
