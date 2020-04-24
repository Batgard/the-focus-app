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
import fr.batgard.thefocusapp.scenes.timer.presentation.NotificationContent
import fr.batgard.thefocusapp.scenes.timer.presentation.TimerNotificationViewModel
import fr.batgard.thefocusapp.scenes.timer.presentation.TimerNotificationViewModelImpl

interface TimerNotification {
    fun setupConfiguration(timerInfo: TimerInfo)
}

class TimerService : Service(), TimerNotification {

    companion object {
        const val BROADCAST_ACTION = "fr.batgard.thefocusapp.PLAY_PAUSE_ACTION"
        const val NOTIFICATION_ID = 1
    }

    private var viewModel: TimerNotificationViewModel? = null
    private var serviceNotificationActionBroadcastReceiver: MyBroadcastReceiver? = null

    var notificationManager: NotificationManager? = null

    inner class TimerServiceBinder : Binder() {
        fun getRef(): TimerNotification {
            return this@TimerService
        }
    }

    private val binder = TimerServiceBinder()

    private lateinit var playPauseButtonPendingIntent: PendingIntent

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

    override fun onUnbind(intent: Intent?): Boolean {
        unregisterBroadcastReceiver()
        return super.onUnbind(intent)
    }

//region timerInfo

    override fun setupConfiguration(timerInfo: TimerInfo) {
        viewModel = TimerNotificationViewModelImpl(TimerImpl(timerInfo))
        viewModel?.setNotificationChangeListener {
            updateNotification(it)
        }
        startForegroundWithNotification()
    }

    //endregion timerInfo

    private fun registerBroadcastReceiver() {
        serviceNotificationActionBroadcastReceiver = MyBroadcastReceiver(::onPlayPauseAction)
        registerReceiver(serviceNotificationActionBroadcastReceiver, IntentFilter(BROADCAST_ACTION))
    }

    private fun unregisterBroadcastReceiver() {
        unregisterReceiver(serviceNotificationActionBroadcastReceiver)
    }

    private fun onPlayPauseAction() {
        viewModel?.onPlayPauseButtonTap()
    }

    private fun startForegroundWithNotification() {
        val actionIntent = Intent().apply {
            action = BROADCAST_ACTION
        }

        playPauseButtonPendingIntent =
                PendingIntent.getBroadcast(this, 0, actionIntent, 0)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForeground(NOTIFICATION_ID, getNotification())
        } else {
//            content = NotificationContent()
//            updateContent()
        }
    }

    private fun updateNotification(content: NotificationContent) {
        val notification = getNotification()
        notificationManager?.notify(NOTIFICATION_ID, notification)
    }

    private fun getNotification(): Notification? {
        return NotificationCompat.Builder(this, getString(R.string.notification_channel_id))
                .setContentText(viewModel?.getTitle())
                .setContentTitle(viewModel?.getBody())
                .setSmallIcon(R.drawable.ic_tomato_timer)
                .addAction(
                        NotificationCompat.Action(null,
                                viewModel?.getButtonLabel()?.name,
                                playPauseButtonPendingIntent
                        )
                ).build()
    }
}

class MyBroadcastReceiver(private val actionListener: () -> Unit) : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        actionListener.invoke()
    }
}