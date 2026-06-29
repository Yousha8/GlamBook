allprojects {
    repositories {
        google()
        mavenCentral()
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
subprojects {
    project.evaluationDependsOn(":app")
    val applyNdk = {
        val android = project.extensions.findByName("android") as? com.android.build.gradle.BaseExtension
        android?.ndkVersion = "30.0.14904198"
    }
    if (project.state.executed) {
        applyNdk()
    } else {
        project.afterEvaluate { applyNdk() }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
