#!/bin/bash
# === LSPosed List Animations - self-extracting project ===
# Paste this whole file into GitHub as 'project_selfextract.sh', commit,
# then run it (or open in GitPod/Codespace) to recreate the project.
set -e
mkdir -p project
cd project
mkdir -p "$(dirname "build.gradle")"
cat > "build.gradle" <<'KAI_EOF'
// Top-level build file
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.5.2'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.24"
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url 'https://api.xposed.info/' }
    }
}

task clean(type: Delete) {
    delete rootProject.buildDir
}
KAI_EOF
mkdir -p "$(dirname "settings.gradle")"
cat > "settings.gradle" <<'KAI_EOF'
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
        maven { url 'https://api.xposed.info/' }
    }
}
rootProject.name = "LSPosedListAnimations"
include ':app'
KAI_EOF
mkdir -p "$(dirname "gradle.properties")"
cat > "gradle.properties" <<'KAI_EOF'
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
android.nonTransitiveRClass=true
kotlin.code.style=official
KAI_EOF
mkdir -p "$(dirname "build_apk.sh")"
cat > "build_apk.sh" <<'KAI_EOF'
#!/bin/bash
set -e
cd "$(dirname "$0")"
echo "Starting Gradle build..."
if [ ! -f gradlew ]; then
  echo "gradlew missing, generating wrapper..."
  gradle wrapper --gradle-version 8.9 || true
fi
chmod +x gradlew
./gradlew :app:assembleDebug --no-daemon
echo "APK built at: app/build/outputs/apk/debug/app-debug.apk"
find app/build/outputs -name "*.apk"
KAI_EOF
mkdir -p "$(dirname ".gitpod.yml")"
cat > ".gitpod.yml" <<'KAI_EOF'
image: gitpod/workspace-android
tasks:
  - init: |
      sdkmanager "build-tools;35.0.0" "platforms;android-35" || true
    command: |
      echo "Run ./build_apk.sh to build the APK"
github:
  prebuild:
    - command: echo "prebuild"
KAI_EOF
mkdir -p "$(dirname "README.md")"
cat > "README.md" <<'KAI_EOF'
# LSPosed List Animations Module

An LSPosed module that applies selectable entrance animations to RecyclerView
and ListView items in any scoped app.

## Animations
- none, fade, slide_up, slide_right, scale, flip, cascade

## Build
Open in Android Studio, or use the cloud build (GitPod / GitHub Actions).
Target SDK is 35 (Android 15). To target Android 16 (API 36) once stable,
change compileSdk/targetSdk in app/build.gradle to 36.

## Install
Build the debug APK, install it, enable in LSPosed, scope your apps, then
open the module's app to pick the animation + duration.
KAI_EOF
mkdir -p "$(dirname "app/build.gradle")"
cat > "app/build.gradle" <<'KAI_EOF'
plugins {
    id 'com.android.application'
    id 'org.jetbrains.kotlin.android'
}

android {
    namespace 'com.example.listanim'
    compileSdk 35

    defaultConfig {
        applicationId 'com.example.listanim'
        minSdk 26
        targetSdk 35
        versionCode 1
        versionName '1.0'
    }

    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
        debug {
            minifyEnabled false
        }
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = '17'
    }
    buildFeatures {
        viewBinding true
    }
    packagingOptions {
        resources {
            excludes += ['META-INF/*.version', 'META-INF/LICENSE*', 'META-INF/NOTICE*']
        }
    }
}

dependencies {
    implementation 'androidx.core:core-ktx:1.13.1'
    implementation 'androidx.appcompat:appcompat:1.7.0'
    implementation 'com.google.android.material:material:1.12.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.4'
    compileOnly 'de.robv.android.xposed:api:82'
    compileOnly 'de.robv.android.xposed:api:82:sources'
    compileOnly 'org.lsposed:lsposed-api:1.0'
}
KAI_EOF
mkdir -p "$(dirname "app/src/main/AndroidManifest.xml")"
cat > "app/src/main/AndroidManifest.xml" <<'KAI_EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <application
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:supportsRtl="true"
        android:theme="@style/Theme.Material3.DayNight">

        <activity
            android:name=".SettingsActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <!-- LSPosed module declaration -->
        <meta-data
            android:name="xposedmodule"
            android:value="true" />
        <meta-data
            android:name="xposeddescription"
            android:value="@string/module_description" />
        <meta-data
            android:name="xposedminversion"
            android:value="93" />
        <meta-data
            android:name="xposedmaxversion"
            android:value="93" />
        <meta-data
            android:name="xposedscope"
            android:resource="@array/xposed_scope" />

    </application>
</manifest>
KAI_EOF
mkdir -p "$(dirname "app/src/main/assets/META-INF/xposed.properties")"
cat > "app/src/main/assets/META-INF/xposed.properties" <<'KAI_EOF'
xposedminversion=93
xposedmaxversion=93
xposeddescription=List Animations module
KAI_EOF
mkdir -p "$(dirname "app/src/main/assets/xposed_init")"
cat > "app/src/main/assets/xposed_init" <<'KAI_EOF'
com.example.listanim.ListAnimModule
KAI_EOF
mkdir -p "$(dirname "app/src/main/res/values/strings.xml")"
cat > "app/src/main/res/values/strings.xml" <<'KAI_EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">List Anim</string>
    <string name="module_description">Applies selectable entrance animations to app list items.</string>
    <string name="settings_title">List Animations</string>
    <string name="anim_label">Animation</string>
    <string name="duration_label">Duration (ms)</string>
    <string name="save">Save</string>
    <string name="saved_toast">Settings saved. Restart target apps.</string>
</resources>
KAI_EOF
mkdir -p "$(dirname "app/src/main/res/values/arrays.xml")"
cat > "app/src/main/res/values/arrays.xml" <<'KAI_EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string-array name="anim_entries">
        <item>None</item>
        <item>Fade</item>
        <item>Slide Up</item>
        <item>Slide Right</item>
        <item>Scale Pop</item>
        <item>Flip</item>
        <item>Cascade</item>
    </string-array>
    <string-array name="anim_values">
        <item>none</item>
        <item>fade</item>
        <item>slide_up</item>
        <item>slide_right</item>
        <item>scale</item>
        <item>flip</item>
        <item>cascade</item>
    </string-array>
    <string-array name="xposed_scope">
        <item>android</item>
        <item>com.android.settings</item>
    </string-array>
</resources>
KAI_EOF
mkdir -p "$(dirname "app/src/main/res/layout/activity_settings.xml")"
cat > "app/src/main/res/layout/activity_settings.xml" <<'KAI_EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:padding="24dp"
    android:gravity="center_horizontal">

    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="@string/settings_title"
        android:textSize="22sp"
        android:textStyle="bold"
        android:layout_marginBottom="24dp" />

    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="@string/anim_label" />

    <Spinner
        android:id="@+id/spinnerAnim"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginBottom="16dp" />

    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="@string/duration_label" />

    <SeekBar
        android:id="@+id/seekDuration"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:max="1000"
        android:progress="300"
        android:layout_marginBottom="24dp" />

    <Button
        android:id="@+id/btnSave"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="@string/save" />

</LinearLayout>
KAI_EOF
mkdir -p "$(dirname "app/src/main/java/com/example/listanim/BuildConfigFinal.kt")"
cat > "app/src/main/java/com/example/listanim/BuildConfigFinal.kt" <<'KAI_EOF'
package com.example.listanim

/**
 * Module package name used inside hooked processes (where the generated
 * BuildConfig of the module is not directly accessible).
 */
object BuildConfigFinal {
    const val MODULE_PACKAGE = "com.example.listanim"
}
KAI_EOF
mkdir -p "$(dirname "app/src/main/java/com/example/listanim/ListAnimModule.kt")"
cat > "app/src/main/java/com/example/listanim/ListAnimModule.kt" <<'KAI_EOF'
package com.example.listanim

import android.app.AndroidAppHelper
import android.os.Build
import android.view.View
import android.view.ViewGroup
import android.widget.ListView
import de.robv.android.xposed.IXposedModification
import de.robv.android.xposed.XC_MethodHook
import de.robv.android.xposed.XposedBridge
import de.robv.android.xposed.XposedHelpers
import de.robv.android.xposed.callbacks.XC_LoadPackage

class ListAnimModule {

    companion object {
        @JvmStatic
        fun handleLoadPackage(lpparam: XC_LoadPackage.LoadPackageParam) {
            try {
                hookRecyclerView(lpparam)
                hookListView(lpparam)
            } catch (t: Throwable) {
                XposedBridge.log("[ListAnim] error in ${lpparam.packageName}: $t")
            }
        }

        private fun hookRecyclerView(lpparam: XC_LoadPackage.LoadPackageParam) {
            val recyclerClass = XposedHelpers.findClassIfExists(
                "androidx.recyclerview.widget.RecyclerView", lpparam.classLoader
            ) ?: return
            XposedHelpers.findAndHookMethod(
                recyclerClass,
                "dispatchChildAttached",
                View::class.java,
                object : XC_MethodHook() {
                    override fun afterHookedMethod(param: MethodHookParam) {
                        val child = param.args[0] as? View ?: return
                        applyAnim(child, lpparam.packageName)
                    }
                }
            )
        }

        private fun hookListView(lpparam: XC_LoadPackage.LoadPackageParam) {
            XposedHelpers.findAndHookMethod(
                ListView::class.java,
                "layoutChildren",
                object : XC_MethodHook() {
                    override fun afterHookedMethod(param: MethodHookParam) {
                        val lv = param.thisObject as ListView
                        val count = lv.childCount
                        for (i in 0 until count) {
                            val child = lv.getChildAt(i) ?: continue
                            if (child.getTag(R.id.tag_animated) == null) {
                                child.setTag(R.id.tag_animated, true)
                                applyAnim(child, lpparam.packageName, i)
                            }
                        }
                    }
                }
            )
        }

        private fun applyAnim(view: View, pkg: String, index: Int = 0) {
            val (type, duration) = Prefs.read(pkg)
            ListAnimations.play(view, type, duration, index)
        }
    }
}

// Keep IXposedModification import used to avoid unused warning on some builds.
@Suppress("unused")
private fun ensureIxposed(api: IXposedModification?) = api
</arg_value:6124c78e>
</tool_call:6124c78e>
</tool_calls:6124c78e>
