package fr.batgard.thefocusapp.scenes.timer.businesslogic

data class Activity(val type: ActivityType, val running: Boolean, val remainingTime: Duration)