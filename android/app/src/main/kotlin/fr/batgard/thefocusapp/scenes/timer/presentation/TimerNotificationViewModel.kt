package fr.batgard.thefocusapp.scenes.timer.presentation

import fr.batgard.thefocusapp.scenes.timer.businesslogic.Duration
import fr.batgard.thefocusapp.scenes.timer.businesslogic.Timer

interface TimerNotificationViewModel{
    fun getTitle(): String
    fun getBody(): String
    fun getButtonLabel(): String
    fun setTitleChangeListener(listener: (String) -> Unit)
    fun setBodyChangeListener(listener: (String) -> Unit)
    fun setPlayPauseButtonStateChangeListener(listener:(buttonState: ButtonState) -> Unit)
    fun onPlayPauseButtonTap()
}

class TimerNotificationViewModelImpl(private val pomodoroTimer: Timer): TimerNotificationViewModel {

    private var _titleChangeListener: ((String) -> Unit)? = null
    private var _bodyChangeListener: ((String) -> Unit)? = null
    private var _playPauseButtonStateChangeListener: ((buttonState: ButtonState) -> Unit)? = null
    private var currentActivityRemainingTime: Duration = pomodoroTimer.getPomodoroDuration()

    init {
        pomodoroTimer.setRemainingTimeListener {duration ->
            currentActivityRemainingTime = duration
            _titleChangeListener?.let { listener ->
                listener(formatRemainingTime(currentActivityRemainingTime))
            }
        }
    }

    override fun setTitleChangeListener(listener: (String) -> Unit) {
        _titleChangeListener = listener
    }

    override fun setBodyChangeListener(listener: (String) -> Unit) {
        _bodyChangeListener = listener
    }

    override fun setPlayPauseButtonStateChangeListener(listener: (buttonState: ButtonState) -> Unit) {
        _playPauseButtonStateChangeListener = listener
    }

    override fun onPlayPauseButtonTap() {
        pomodoroTimer.toggle()
        //TODO: Update button
    }

    override fun getTitle(): String {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun getBody(): String {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun getButtonLabel(): String {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    private fun formatRemainingTime(duration: Duration): String {
        return "${duration.minutes}:${duration.seconds}"
    }
}