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
import android.util.Log
import androidx.core.app.NotificationCompat
import fr.batgard.thefocusapp.core.presentation.AndroidResourceMapper
import fr.batgard.thefocusapp.core.presentation.StringResourceProviderImpl
import fr.batgard.thefocusapp.scenes.timer.businesslogic.TimerImpl
import fr.batgard.thefocusapp.scenes.timer.businesslogic.TimerInfo
import fr.batgard.thefocusapp.scenes.timer.presentation.ButtonState
import fr.batgard.thefocusapp.scenes.timer.presentation.TimerNotificationViewModel
import fr.batgard.thefocusapp.scenes.timer.presentation.TimerNotificationViewModelImpl
import fr.batgard.thefocusapp.scenes.timer.presentation.labels.NotificationLabel

interface TimerNotification {
    fun setupConfiguration(timerInfo: TimerInfo)
    fun setNotificationTapListener(listener: () -> Unit)
    fun setNotificationActionPlayTapsListener(listener: () -> Unit)
    fun setNotificationActionPauseTapsListener(listener: () -> Unit)
    fun resetListeners()
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
        Log.d(TimerService::class.java.simpleName, "onCreate")
        registerBroadcastReceivers()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            notificationManager = getSystemService(NotificationManager::class.java)
        }
        startForegroundWithNotification()
    }

    override fun onBind(intent: Intent?): IBinder? {
        Log.d(TimerService::class.java.simpleName, "onBind")
        return binder
    }

    override fun onUnbind(intent: Intent?): Boolean {
        Log.d(TimerService::class.java.simpleName, "onUnbind")
        viewModel?.deinit()
        viewModel = null
        return super.onUnbind(intent)
    }

    override fun onDestroy() {
        Log.d(TimerService::class.java.simpleName, "onDestroy")
        unregisterBroadcastReceiver()
        super.onDestroy()
    }

    //region timerInfo

    override fun setupConfiguration(timerInfo: TimerInfo) {
        val resourceMapper = AndroidResourceMapper()
        resourceMapper.addEntry(NotificationLabel.ACTION_PAUSE.resourceId, R.string.timer_notification_action_button_pause)
        resourceMapper.addEntry(NotificationLabel.ACTION_RESUME.resourceId, R.string.timer_notification_action_button_resume)
        resourceMapper.addEntry(NotificationLabel.BODY_LONG_BREAK.resourceId, R.string.timer_notification_body_long_break)
        resourceMapper.addEntry(NotificationLabel.BODY_SHORT_BREAK.resourceId, R.string.timer_notification_body_short_break)
        resourceMapper.addEntry(NotificationLabel.BODY_POMODORO.resourceId, R.string.timer_notification_body_pomodoro)
        resourceMapper.addEntry(NotificationLabel.BODY_ACTIVITY_PAUSED.resourceId, R.string.timer_notification_body_activity_paused)
        resourceMapper.addEntry(NotificationLabel.BODY_ACTIVITY_ON_GOING.resourceId, R.string.timer_notification_body_activity_on_going)
        
        viewModel = TimerNotificationViewModelImpl(TimerImpl(timerInfo), StringResourceProviderImpl(resources, resourceMapper))
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

    override fun resetListeners() {
        pauseTapsListener = null
        playTapsListener = null
        notificationTapListener = null
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
                                viewModel?.getButtonLabel(),
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