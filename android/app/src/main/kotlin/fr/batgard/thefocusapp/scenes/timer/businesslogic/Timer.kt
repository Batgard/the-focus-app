package fr.batgard.thefocusapp.scenes.timer.businesslogic

import android.os.CountDownTimer

interface Timer {
    fun toggle()
    fun getPomodoroDuration(): Duration
    fun setRemainingTimeListener(listener: (remainingTime: Duration) -> Unit)
    fun isRunning(): Boolean
    fun resetWithDuration(durationInMin: Int)
    fun onActivityChange(listener: (newActivity: ActivityType) -> Unit)
}

class TimerImpl(private val initialTimerInfo: TimerInfo): Timer {

    private var currentActivity: Activity = initialTimerInfo.currentActivity
    private var completedPomodoroCount = 0
    private var countDown: CountDownTimer? = null
    private var running: Boolean = false

    override fun toggle() {
        if (isRunning()) {
            countDown?.cancel()
        } else {
            startCountDown(currentActivity.remainingTime)
        }
        running = !running
    }

    override fun getPomodoroDuration(): Duration {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun setRemainingTimeListener(listener: (remainingTime: Duration) -> Unit) {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun isRunning(): Boolean {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun resetWithDuration(durationInMin: Int) {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun onActivityChange(listener: (newActivity: ActivityType) -> Unit) {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    private fun startCountDown(duration: Duration) {
        countDown = object : CountDownTimer(duration.asMillis(), 1000) {
            override fun onFinish() {
                currentActivity = getNextActivity()
                startCountDown(currentActivity.remainingTime)
            }

            override fun onTick(millisUntilFinished: Long) {
                currentActivity.remainingTime.decrementOneSecond()
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
