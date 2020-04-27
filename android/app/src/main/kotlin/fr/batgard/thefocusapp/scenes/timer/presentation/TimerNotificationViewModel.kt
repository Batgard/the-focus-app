package fr.batgard.thefocusapp.scenes.timer.presentation

import fr.batgard.thefocusapp.scenes.timer.businesslogic.Activity
import fr.batgard.thefocusapp.scenes.timer.businesslogic.ActivityType
import fr.batgard.thefocusapp.scenes.timer.businesslogic.Duration
import fr.batgard.thefocusapp.scenes.timer.businesslogic.Timer

interface TimerNotificationViewModel {
    fun getTitle(): String
    fun getBody(): String
    fun getButtonLabel(): ButtonState
    fun setNotificationChangeListener(listener: (content: NotificationContent) -> Unit)
    fun onPlayPauseButtonTap()
}

class TimerNotificationViewModelImpl(private val pomodoroTimer: Timer) : TimerNotificationViewModel {

    private var notificationContentListener: ((content: NotificationContent) -> Unit)? = null

    init {
        pomodoroTimer.onActivityChange {
            notificationContentListener?.invoke(
                    NotificationContent(
                            title = formatTitle(it),
                            body = formatBody(it),
                            buttonState = getButtonLabel()
                    )
            )
        }
    }

    override fun setNotificationChangeListener(listener: (content: NotificationContent) -> Unit) {
        notificationContentListener = listener
    }

    override fun onPlayPauseButtonTap() {
        pomodoroTimer.toggle()
    }

    override fun getTitle(): String = formatTitle(pomodoroTimer.getCurrentActivity())

    override fun getBody(): String = formatBody(pomodoroTimer.getCurrentActivity())

    override fun getButtonLabel(): ButtonState {
      return if(pomodoroTimer.isRunning()) ButtonState.PLAYING else {ButtonState.PAUSED}
    }

    private fun formatRemainingTime(duration: Duration): String {
        return "${duration.minutes}:${duration.seconds.toString().padStart(2, '0')}"
    }

    private fun formatTitle(activity: Activity): String {
        val title = StringBuilder(when (activity.type) {
            ActivityType.POMODORO ->
                ActivityType.POMODORO.name
            ActivityType.SHORT_BREAK ->
                ActivityType.SHORT_BREAK.name
            ActivityType.LONG_BREAK -> ActivityType.LONG_BREAK.name
        })

        title.append(if (activity.running) "- on going" else "- paused")

        return title.toString()
    }

    private fun formatBody(activity: Activity): String {
        return formatRemainingTime(activity.remainingTime)
    }
}