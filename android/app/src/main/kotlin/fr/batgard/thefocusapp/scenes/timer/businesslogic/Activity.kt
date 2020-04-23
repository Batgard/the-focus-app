package fr.batgard.thefocusapp.scenes.timer.businesslogic

import kotlinx.serialization.Serializable

@Serializable
data class Activity(
        val type: ActivityType,
        val running: Boolean,
        val remainingTime: Duration
)