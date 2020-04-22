package fr.batgard.thefocusapp.scenes.timer.businesslogic

data class Configuration(val pomodoroDurationInMin: Int,
                    val shortBreakDurationInMin: Int,
                    val longBreakDurationInMin: Int,
                    val longBreakFrequency: Int)