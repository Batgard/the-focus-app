package fr.batgard.thefocusapp

import android.app.Notification
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Binder
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import fr.batgard.thefocusapp.scenes.timer.businesslogic.TimerImpl
import fr.batgard.thefocusapp.scenes.timer.businesslogic.TimerInfo
import fr.batgard.thefocusapp.scenes.timer.presentation.TimerNotificationViewModel
import fr.batgard.thefocusapp.scenes.timer.presentation.TimerNotificationViewModelImpl

interface TimerNotification {
    fun setupConfiguration(timerInfo: TimerInfo)
}

interface NotificationContent {
    fun getTitle(): String
    fun getBody(): String
    fun setTitle(title: String)
    fun setBody(body: String)
}

class TimerService: Service(), TimerNotification {

    companion object {
        const val BROADCAST_ACTION = "fr.batgard.thefocusapp.PLAY_PAUSE_ACTION"
    }

    private var viewModel: TimerNotificationViewModel? = null

    var notificationManager: NotificationManager? = null
    private val notificationBuilder = NotificationCompat.Builder(this, getString(R.string.notification_channel_id))

    inner class TimerServiceBinder : Binder() {
        fun getRef(): TimerNotification {
            return this@TimerService
        }
    }

    private val binder = TimerServiceBinder()

    private lateinit var notification: Notification

    override fun onCreate() {
        super.onCreate()
        registerBroadcastReceiver()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            notificationManager = getSystemService(NotificationManager::class.java)
        }
        startForegroundWithNotification()
    }

    override fun onBind(intent: Intent?): IBinder? {
        startForegroundWithNotification()
        return binder
    }


    //region timerInfo

    override fun setupConfiguration(timerInfo: TimerInfo) {
        viewModel = TimerNotificationViewModelImpl(TimerImpl(timerInfo))
        startForegroundWithNotification()
    }

    //endregion timerInfo

    private fun registerBroadcastReceiver() {
        registerReceiver(MyBroadcastReceiver(::onPlayPauseAction), IntentFilter(BROADCAST_ACTION))
    }

    private fun onPlayPauseAction() {
        viewModel?.onPlayPauseButtonTap()
    }

    private fun startForegroundWithNotification() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationBuilder = NotificationCompat.Builder(this, getString(R.string.notification_channel_id))
            notificationBuilder
                    .setContentText(viewModel?.getTitle())
                    .setContentTitle(viewModel?.getBody())
                    .setSmallIcon(R.drawable.ic_tomato_timer)
                    .addAction(NotificationCompat.Action(null, viewModel?.getButtonLabel(),
                            playPauseButtonPendingIntent
                            ))
            notification = notificationBuilder.build()
            startForeground(1, notification)
        } else {
//            content = NotificationContent()
//            updateContent()
        }
    }

    private val actionIntent = Intent(this, MyBroadcastReceiver::class.java).apply {
        action = BROADCAST_ACTION
    }

    private val playPauseButtonPendingIntent: PendingIntent =
            PendingIntent.getBroadcast(this, 0, actionIntent, 0)

    private fun makeNotification(content: NotificationContent): Notification {
        return notificationBuilder.setContentText(content.getBody())
                .setContentTitle(content.getTitle())
                .setSmallIcon(R.drawable.ic_tomato_timer)
                .build()
    }
}

class MyBroadcastReceiver(private val actionListener: () -> Unit): BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        actionListener.invoke()
    }
}