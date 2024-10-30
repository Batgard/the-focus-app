package fr.batgard.thefocusapp.scenes.timer.businesslogic

import kotlinx.serialization.Serializable

@Serializable
data class TimerInfo(val currentActivity: Activity,
                     val configuration: Configuration)