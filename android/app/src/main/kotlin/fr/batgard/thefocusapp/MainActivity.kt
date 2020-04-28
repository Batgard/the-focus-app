package fr.batgard.thefocusapp

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.IBinder
import androidx.annotation.NonNull
import fr.batgard.thefocusapp.scenes.timer.businesslogic.TimerInfo
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonConfiguration


class MainActivity : FlutterActivity() {

    private var timerNotification: TimerNotification? = null
    private var initialTimerInfo: TimerInfo? = null
    private val json = Json(JsonConfiguration.Stable)
    private lateinit var methodChannel: MethodChannel

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "fr.batgard.thefocusapp.notificationChannel")
        methodChannel
                .setMethodCallHandler { methodCall, _ ->
                    when (methodCall.method) {
                        "startTimerNotification" -> {
                            startService(methodCall.arguments.toString())
                        }
                        "stopTimerNotification" -> {
                            stopService()
                        }
                    }
                }
    }

    private fun startService(rawTimerInfo: String?) {

        require(rawTimerInfo != null)

        initialTimerInfo = json.parse(TimerInfo.serializer(), rawTimerInfo)

        if (timerNotification != null) {
            initialTimerInfo?.let {
                timerNotification?.setupConfiguration(it)
            }
        } else {
            val intent = Intent(context, TimerService::class.java)

            bindService(intent,
                    connection,
                    Context.BIND_AUTO_CREATE)
        }
    }

    private fun stopService() {
        unbindService(connection)
        timerNotification = null
    }

    /** Defines callbacks for service binding, passed to bindService()  */
    private val connection = object : ServiceConnection {

        override fun onServiceConnected(className: ComponentName, service: IBinder) {
            // We've bound to LocalService, cast the IBinder and get LocalService instance
            val binder = service as TimerService.TimerServiceBinder
            timerNotification = binder.getRef()
            initialTimerInfo?.let {
                timerNotification?.setupConfiguration(it)
            }
            timerNotification?.setNotificationTapListener {
                startActivity(Intent(context, MainActivity::class.java))
                stopService()
            }
            timerNotification?.setNotificationActionPauseTapsListener {
                methodChannel.invokeMethod("pause", null)
            }
            timerNotification?.setNotificationActionPlayTapsListener {
                methodChannel.invokeMethod("resume", null)
            }
        }

        override fun onServiceDisconnected(arg0: ComponentName) {
        }
    }
}
