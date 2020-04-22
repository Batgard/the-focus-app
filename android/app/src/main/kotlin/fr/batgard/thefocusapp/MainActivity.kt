package fr.batgard.thefocusapp

import android.content.ComponentName
import android.content.Intent
import android.content.ServiceConnection
import android.os.Build
import android.os.Bundle
import android.os.IBinder
import android.os.PersistableBundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {

    private var timerNotification: TimerNotification? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }

    override fun onCreate(savedInstanceState: Bundle?, persistentState: PersistableBundle?) {
        super.onCreate(savedInstanceState, persistentState)

        MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger, "fr.batgard.thefocusapp.notificationChannel")
                .setMethodCallHandler { methodCall, _ ->
            when(methodCall.method) {
                "startTimerNotification" -> {
                    startService()
                }
                "stopTimerNotification" -> {
                    stopService()
                }
            }
        }
    }

    private fun startService() {
        val intent = Intent(context, TimerService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }

    private fun stopService() {
        val intent = Intent(context, TimerService::class.java)
        stopService(intent)
    }

    /** Defines callbacks for service binding, passed to bindService()  */
    private val connection = object : ServiceConnection {

        override fun onServiceConnected(className: ComponentName, service: IBinder) {
            // We've bound to LocalService, cast the IBinder and get LocalService instance
            val binder = service as TimerService.TimerServiceBinder
            timerNotification = binder.getRef()
            timerNotification.updateContent(NotificationContent())
        }

        override fun onServiceDisconnected(arg0: ComponentName) {

        }
    }
}
