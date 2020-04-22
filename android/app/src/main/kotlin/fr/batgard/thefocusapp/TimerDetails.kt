package fr.batgard.thefocusapp

import kotlin.time.Duration

data class TimerDetails(val currentActivity: ActivityType,
                        val remainingTimeInSec: Int,
                        val pomodoroDuration: Int,
                        val shortBreakDuration: Int,
                        val longBreakDuration: Int,
                        val longBreakFrequency: Int)

enum class ActivityType {
    POMODORO,
    SHORT_BREAK,
    LONG_BREAK
}