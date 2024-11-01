package fr.batgard.thefocusapp.scenes.timer.businesslogic

import kotlinx.serialization.Serializable

@Serializable
data class Configuration(val pomodoroDurationInMin: Int,
                    val shortBreakDurationInMin: Int,
                    val longBreakDurationInMin: Int,
                    val longBreakFrequency: Int)