package fr.batgard.thefocusapp.scenes.timer.businesslogic

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
enum class ActivityType {
    @SerialName("pomodoro")
    POMODORO,
    @SerialName("shortBreak")
    SHORT_BREAK,
    @SerialName("longBreak")
    LONG_BREAK
}