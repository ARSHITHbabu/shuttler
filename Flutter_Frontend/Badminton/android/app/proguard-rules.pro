# Flutter engine
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.**

# Flutter plugins
-keep class io.flutter.plugins.** { *; }

# Keep annotations and signatures for reflection
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes SourceFile,LineNumberTable
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# OkHttp (used by Dio internally on Android)
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }

# Kotlin
-keep class kotlin.** { *; }
-dontwarn kotlin.**

# App classes
-keep class com.example.badminton.** { *; }

# Firebase (FCM push notifications)
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Razorpay payment SDK (B12)
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-keepattributes JavascriptInterface
-keep public class com.razorpay.** { *; }
-dontwarn com.razorpay.**
-keep class proguard.annotation.Keep
-keep class proguard.annotation.KeepClassMembers

# SSL/TLS security classes — required for certificate pinning (E4)
-keep class javax.net.ssl.** { *; }
-keep class java.security.** { *; }
-keep class sun.security.** { *; }

# Prevent obfuscation of crash-reporting stack traces
-renamesourcefileattribute SourceFile
