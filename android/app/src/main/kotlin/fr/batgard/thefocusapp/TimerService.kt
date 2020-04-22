package fr.batgard.thefocusapp

import android.app.Notification
import android.app.NotificationManager
import android.app.Service
import android.content.ComponentName
import android.content.Intent
import android.content.ServiceConnection
import android.os.Binder
import android.os.Build
import android.os.CountDownTimer
import android.os.IBinder
import androidx.core.app.NotificationCompat

interface TimerNotification {
    fun setupConfiguration(timerDetails: TimerDetails)
    fun updateContent(content: NotificationContent)
}

interface NotificationContent {
    fun getTitle(): String
    fun getBody(): String
    fun setTitle(title: String)
    fun setBody(body: String)
}

class TimerService: Service(), TimerNotification {
    
    var notificationManager: NotificationManager? = null
    private val notificationBuilder = NotificationCompat.Builder(this, getString(R.string.notification_channel_id))

    inner class TimerServiceBinder: Binder() {
        fun getRef(): TimerNotification {
            return this@TimerService
        }
    }

    private val binder = TimerServiceBinder()

    private var configuration: TimerDetails? = null

    private lateinit var notification: Notification

    override fun onCreate() {
        super.onCreate()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            notificationManager = getSystemService(NotificationManager::class.java)
        }
        startForegroundWithNotification()
    }

    override fun onBind(intent: Intent?): IBinder? {
        startForegroundWithNotification()
        return binder
    }


    //region timerNotification
    override fun updateContent(content: NotificationContent) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            notificationManager?.notify(1, makeNotification(content))
        } else {
            //FIXME: Find way for prior versions of Android to send notification
        }
    }

    override fun setupConfiguration(timerDetails: TimerDetails) {
        configuration = timerDetails
        startForegroundWithNotification()
    }

    //endregion timerNotification


    private fun startForegroundWithNotification() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationBuilder = NotificationCompat.Builder(this, getString(R.string.notification_channel_id))
            notificationBuilder.setContentText("Time remaining: ").setContentTitle("Timer type:")
                    .setSmallIcon(R.drawable.ic_tomato_timer)
            notification = notificationBuilder.build()
            startForeground(1, notification)
        } else {
//            content = NotificationContent()
//            updateContent()
        }
    }

    private fun startCountDown() {
        val countDown =  object: CountDownTimer(0, 1000) {
            override fun onFinish() {
                TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
            }

            override fun onTick(millisUntilFinished: Long) {
                TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
            }
        }
    }

    private fun makeNotification(content: NotificationContent): Notification {
        return notificationBuilder.setContentText(content.getBody())
                .setContentTitle(content.getTitle())
                .setSmallIcon(R.drawable.ic_tomato_timer)
                .build()
    }
}