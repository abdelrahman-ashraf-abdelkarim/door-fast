# Flutter Local Notifications fix
-keep class com.dexterous.** { *; }
-keep class androidx.lifecycle.** { *; }
-keep class androidx.core.** { *; }
-keep class androidx.annotation.** { *; }

# Keep timezone
-keep class com.bewithme.timezone.** { *; }
-keep class org.threeten.bp.** { *; }

# Kotlin metadata (important)
-keep class kotlin.Metadata { *; }

# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keepattributes *Annotation*

# Keep app classes
-keep class com.doorfast.captain.** { *; }

# Prevent stripping of JSON models and reflective signatures
-keepattributes Signature
-keepattributes *Annotation*

# HydratedBloc / Hive
-keep class hive.** { *; }

# Optional Flutter deferred component / logging classes not bundled in APK
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task
-dontwarn org.slf4j.impl.StaticLoggerBinder
