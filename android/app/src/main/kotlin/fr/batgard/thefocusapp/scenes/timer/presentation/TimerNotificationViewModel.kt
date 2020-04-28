package fr.batgard.thefocusapp.scenes.timer.presentation

import fr.batgard.thefocusapp.scenes.timer.businesslogic.Activity
import fr.batgard.thefocusapp.scenes.timer.businesslogic.ActivityType
import fr.batgard.thefocusapp.scenes.timer.businesslogic.Duration
import fr.batgard.thefocusapp.scenes.timer.businesslogic.Timer

interface TimerNotificationViewModel {
    fun getTitle(): String
    fun getBody(): String
    fun getButtonLabel(): ButtonState
    fun setNotificationChangeListener(listener: () -> Unit)
    fun setNotificationActionStateChangeListener(listener: (buttonState: ButtonState) -> Unit)
    fun onPlayPauseButtonTap()
    fun onNotificationTap()
}

class TimerNotificationViewModelImpl(private val pomodoroTimer: Timer) : TimerNotificationViewModel {

    private var notificationContentListener: (() -> Unit)? = null
    private var notificationActionChangesListener: ((buttonState: ButtonState) -> Unit)? = null

    init {
        pomodoroTimer.onActivityChange {
            notificationContentListener?.invoke()
        }
    }

    override fun setNotificationChangeListener(listener: () -> Unit) {
        notificationContentListener = listener
    }

    override fun setNotificationActionStateChangeListener(listener: (buttonState: ButtonState) -> Unit) {
        notificationActionChangesListener = listener
    }

    override fun onPlayPauseButtonTap() {
        pomodoroTimer.toggle()
        notificationActionChangesListener?.invoke(getButtonLabel())
    }

    override fun onNotificationTap() {
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