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
