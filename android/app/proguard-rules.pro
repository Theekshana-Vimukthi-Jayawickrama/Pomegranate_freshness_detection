# TensorFlow Lite GPU Delegate - Keep all classes
-keep class org.tensorflow.lite.gpu.** { *; }
-dontwarn org.tensorflow.lite.gpu.GpuDelegateFactory$Options
-dontwarn org.tensorflow.lite.gpu.**

# TensorFlow Lite - Keep necessary classes
-keep class org.tensorflow.lite.** { *; }
-keep class com.google.mediapipe.** { *; }

# Guava - ListenableFuture
-keep class com.google.common.util.concurrent.ListenableFuture { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Flutter plugins
-keep class io.flutter.** { *; }
-keep class com.google.android.gms.** { *; }

# Image picker and camera
-keep class io.flutter.plugins.imagepicker.** { *; }

# Permission handler
-keep class com.baseflow.permissionhandler.** { *; }

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep classes with native methods and their constructors
-keepclasseswithmembers class * {
    *** *(...);
}
