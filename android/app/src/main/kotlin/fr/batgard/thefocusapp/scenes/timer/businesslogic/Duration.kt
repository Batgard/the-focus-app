package fr.batgard.thefocusapp.scenes.timer.businesslogic

import kotlinx.serialization.Serializable

@Serializable
data class Duration(var minutes: Int, var seconds: Int = 0) {
    fun asMillis(): Long {
        return minutes.toLong()* 60 * 1000 + seconds * 1000
    }
    fun decrementOneSecond() {
        if (seconds == 0) {
            if (minutes > 0) {
                minutes--
                seconds = 59
            }
        } else {
            seconds--
        }
    }

    fun isZero() = minutes == 0 && seconds == 0
}