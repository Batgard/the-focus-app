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
import fr.batgard.thefocusapp.scenes.timer.presentation.ButtonState
import fr.batgard.thefocusapp.scenes.timer.presentation.NotificationContent
import fr.batgard.thefocusapp.scenes.timer.presentation.TimerNotificationViewModel
import fr.batgard.thefocusapp.scenes.timer.presentation.TimerNotificationViewModelImpl

interface TimerNotification {
    fun setupConfiguration(timerInfo: TimerInfo)
    fun setNotificationTapListener(listener: () -> Unit)
    fun setNotificationActionPlayTapsListener(listener: () -> Unit)
    fun setNotificationActionPauseTapsListener(listener: () -> Unit)
}

class TimerService : Service(), TimerNotification {

    companion object {
        const val BROADCAST_PLAY_PAUSE_ACTION = "fr.batgard.thefocusapp.PLAY_PAUSE_ACTION"
        const val BROADCAST_NOTIF_TAPPED_ACTION = "fr.batgard.thefocusapp.NOTIF_TAPPED_ACTION"
        const val NOTIFICATION_ID = 1
    }

    private var viewModel: TimerNotificationViewModel? = null
    private var notificationActionTapBroadcastReceiver: NotificationInteractionBroadcastReceiver? = null
    private var notificationTapBroadcastReceiver: NotificationInteractionBroadcastReceiver? = null

    var notificationManager: NotificationManager? = null

    inner class TimerServiceBinder : Binder() {
        fun getRef(): TimerNotification {
            return this@TimerService
        }
    }

    private val binder = TimerServiceBinder()
    private var notificationTapListener: (() -> Unit)? = null
    private var playTapsListener: (() -> Unit)? = null
    private var pauseTapsListener: (() -> Unit)? = null

    private lateinit var playPauseButtonPendingIntent: PendingIntent

    override fun onCreate() {
        super.onCreate()
        registerBroadcastReceivers()
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
            updateNotification()
        }
        viewModel?.setNotificationActionStateChangeListener { 
            notifyFlutterApp(it)
        }
        startForegroundWithNotification()
    }

    override fun setNotificationTapListener(listener: () -> Unit) {
        notificationTapListener = listener
    }

    override fun setNotificationActionPlayTapsListener(listener: () -> Unit) {
        playTapsListener = listener
    }

    override fun setNotificationActionPauseTapsListener(listener: () -> Unit) {
        pauseTapsListener = listener
    }

    //endregion timerInfo

    private fun notifyFlutterApp(buttonState: ButtonState) {
        when(buttonState) {
            ButtonState.PAUSED -> playTapsListener?.invoke()
            ButtonState.PLAYING -> pauseTapsListener?.invoke()
        }
    }
    
    private fun registerBroadcastReceivers() {
        notificationTapBroadcastReceiver = NotificationInteractionBroadcastReceiver(::onNotificationTapped)
        notificationActionTapBroadcastReceiver = NotificationInteractionBroadcastReceiver(::onPlayPauseAction)
        registerReceiver(notificationTapBroadcastReceiver, IntentFilter(BROADCAST_NOTIF_TAPPED_ACTION))
        registerReceiver(notificationActionTapBroadcastReceiver, IntentFilter(BROADCAST_PLAY_PAUSE_ACTION))
        
    }

    private fun unregisterBroadcastReceiver() {
        unregisterReceiver(notificationTapBroadcastReceiver)
        unregisterReceiver(notificationActionTapBroadcastReceiver)
    }

    private fun onNotificationTapped() {
        viewModel?.onNotificationTap()
        notificationTapListener?.invoke()
    }
    
    private fun onPlayPauseAction() {
        viewModel?.onPlayPauseButtonTap()
    }

    private fun startForegroundWithNotification() {
        val actionIntent = Intent().apply {
            action = BROADCAST_PLAY_PAUSE_ACTION
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

    private fun updateNotification() {
        val notification = getNotification()
        notificationManager?.notify(NOTIFICATION_ID, notification)
    }

    private fun getNotification(): Notification? {
        val actionIntent = Intent().apply {
            action = BROADCAST_NOTIF_TAPPED_ACTION
        }

        val notificationTapPendingIntent =
                PendingIntent.getBroadcast(this, 0, actionIntent, 0)


        return NotificationCompat.Builder(this, getString(R.string.notification_channel_id))
                .setContentText(viewModel?.getTitle())
                .setContentTitle(viewModel?.getBody())
                .setSmallIcon(R.drawable.ic_tomato_timer)
                .addAction(
                        NotificationCompat.Action(null,
                                viewModel?.getButtonLabel()?.name,
                                playPauseButtonPendingIntent
                        )
                )
                .setContentIntent(
                    notificationTapPendingIntent
                ).build()
    }
}

class NotificationInteractionBroadcastReceiver(private val actionListener: () -> Unit) : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        actionListener.invoke()
    }
}