package fr.batgard.thefocusapp.scenes.timer.presentation

import fr.batgard.thefocusapp.core.presentation.StringResourceProvider
import fr.batgard.thefocusapp.scenes.timer.businesslogic.Activity
import fr.batgard.thefocusapp.scenes.timer.businesslogic.ActivityType
import fr.batgard.thefocusapp.scenes.timer.businesslogic.Duration
import fr.batgard.thefocusapp.scenes.timer.businesslogic.Timer
import fr.batgard.thefocusapp.scenes.timer.presentation.labels.NotificationLabel

interface TimerNotificationViewModel {
    fun getTitle(): String
    fun getBody(): String
    fun getButtonState(): ButtonState
    fun getButtonLabel(): String
    fun setNotificationChangeListener(listener: () -> Unit)
    fun setNotificationActionStateChangeListener(listener: (buttonState: ButtonState) -> Unit)
    fun onPlayPauseButtonTap()
    fun onNotificationTap()
}

class TimerNotificationViewModelImpl(private val pomodoroTimer: Timer,
private val resourceProvider: StringResourceProvider
) : TimerNotificationViewModel {

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
        notificationActionChangesListener?.invoke(getButtonState())
    }

    override fun onNotificationTap() {
        pomodoroTimer.toggle()
    }

    override fun getTitle(): String = formatTitle(pomodoroTimer.getCurrentActivity())

    override fun getBody(): String = formatBody(pomodoroTimer.getCurrentActivity())

    override fun getButtonState(): ButtonState {
        return if(pomodoroTimer.isRunning()) {
            ButtonState.PLAYING
        } else {
            ButtonState.PAUSED
        }
    }

    override fun getButtonLabel(): String { 
        return if(pomodoroTimer.isRunning()) {
          resourceProvider.getSimple(NotificationLabel.ACTION_PAUSE.resourceId)
      } else {
          resourceProvider.getSimple(NotificationLabel.ACTION_RESUME.resourceId)
      }
    }
    
    private fun formatRemainingTime(duration: Duration): String {
        return "${duration.minutes}:${duration.seconds.toString().padStart(2, '0')}"
    }

    private fun formatTitle(activity: Activity): String {
        val title = StringBuilder(when (activity.type) {
            ActivityType.POMODORO ->
                resourceProvider.getSimple(NotificationLabel.BODY_POMODORO.resourceId)
            ActivityType.SHORT_BREAK ->
                resourceProvider.getSimple(NotificationLabel.BODY_SHORT_BREAK.resourceId)
            ActivityType.LONG_BREAK ->
                resourceProvider.getSimple(NotificationLabel.BODY_LONG_BREAK.resourceId)
        })

        title.append(if (activity.running) resourceProvider.getSimple(NotificationLabel.BODY_ACTIVITY_ON_GOING.resourceId) 
        else resourceProvider.getSimple(NotificationLabel.BODY_ACTIVITY_PAUSED.resourceId) 
        )

        return title.toString()
    }

    private fun formatBody(activity: Activity): String {
        return formatRemainingTime(activity.remainingTime)
    }
}