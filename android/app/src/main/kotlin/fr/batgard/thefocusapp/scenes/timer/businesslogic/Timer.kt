package fr.batgard.thefocusapp.scenes.timer.businesslogic

import android.os.CountDownTimer

interface Timer {
    fun toggle()
    fun getPomodoroDuration(): Duration
    fun getCurrentActivity(): Activity
    fun isRunning(): Boolean
    fun onActivityChange(listener: (newActivity: Activity) -> Unit)
}

class TimerImpl(private val initialTimerInfo: TimerInfo): Timer {

    private var currentActivity: Activity = initialTimerInfo.currentActivity
    private var completedPomodoroCount = 0
    private var countDown: CountDownTimer? = null
    private var listener: ((newActivity: Activity) -> Unit)? = null

    init {
        if (currentActivity.running) {
            startCountDown(currentActivity.remainingTime)
        }
    }
    
    override fun toggle() {
        if (isRunning()) {
            countDown?.cancel()
        } else {
            startCountDown(currentActivity.remainingTime)
        }
        currentActivity = currentActivity.getNewToggledActivity()
        listener?.invoke(currentActivity)
    }
    
    override fun getPomodoroDuration(): Duration = currentActivity.remainingTime

    override fun getCurrentActivity(): Activity = currentActivity

    override fun isRunning(): Boolean = currentActivity.running

    override fun onActivityChange(listener: (newActivity: Activity) -> Unit) {
        this.listener = listener
    }

    private fun startCountDown(duration: Duration) {
        countDown = object : CountDownTimer(duration.asMillis(), 1000) {
            override fun onFinish() {
                currentActivity = getNextActivity()
                startCountDown(currentActivity.remainingTime)
                listener?.invoke(currentActivity)
            }

            override fun onTick(millisUntilFinished: Long) {
                currentActivity.remainingTime.decrementOneSecond()
                listener?.invoke(currentActivity)
            }
        }
        countDown?.start()
    }

    private fun getNextActivity(): Activity {
        return when(currentActivity.type) {
            ActivityType.POMODORO -> {
                if (completedPomodoroCount % initialTimerInfo.configuration.longBreakFrequency == 0) {
                    Activity(ActivityType.LONG_BREAK,
                            currentActivity.running,
                            Duration(initialTimerInfo.configuration.longBreakDurationInMin)
                    )
                } else {
                    Activity(ActivityType.SHORT_BREAK,
                            currentActivity.running,
                            Duration(initialTimerInfo.configuration.shortBreakDurationInMin)
                    )
                }
            }
            else ->
                Activity(ActivityType.POMODORO,
                        currentActivity.running,
                        Duration(initialTimerInfo.configuration.pomodoroDurationInMin)
                )
        }

    }

}
