-keep class proguard.annotation.** { *; }
-keep class com.razorpay.** { *; }
-keepclassmembers class com.razorpay.** { *; }
-dontwarn com.razorpay.**
# Keep Flutter Local Notifications Plugin
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class androidx.core.app.** { *; }
-keep class androidx.core.content.** { *; }

# Keep Alarm Manager related classes
-keep class android.app.AlarmManager { *; }
-keep class android.app.PendingIntent { *; }
-keep class android.content.BroadcastReceiver { *; }
-keep class androidx.work.** { *; }

# Keep your MainActivity class
-keep class com.thesanatanapp.quotes.MainActivity { *; }
-keep class io.flutter.app.FlutterApplication { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.view.** { *; }

# For error handling service
-keep class com.thesanatanapp.quotes.ErrorHandlingService { *; }