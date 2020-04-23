package fr.batgard.thefocusapp

import fr.batgard.thefocusapp.scenes.timer.businesslogic.ActivityType
import fr.batgard.thefocusapp.scenes.timer.businesslogic.TimerInfo
import kotlinx.serialization.json.Json
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import java.io.File

class TimerInfoTest {
    @Test
    fun `Deserialisation From Json Activity Type is Pomodoro`() {
        val stringJson = File("./src/test/resources/scenes/timer/timerInfo.json").readText(Charsets.UTF_8)
        val timerInfo = Json.parse(TimerInfo.serializer(), stringJson)
        assertEquals(timerInfo.currentActivity.type, ActivityType.POMODORO)
    }

    @Test
    fun `Deserialisation From Json Activity is Running`() {
        val stringJson = File("./src/test/resources/scenes/timer/timerInfo.json").readText(Charsets.UTF_8)
        val timerInfo = Json.parse(TimerInfo.serializer(), stringJson)
        assertTrue(timerInfo.currentActivity.running)
    }

    @Test
    fun `Deserialisation From Json Activity time remaining is 4m30s`() {
        val stringJson = File("./src/test/resources/scenes/timer/timerInfo.json").readText(Charsets.UTF_8)
        val timerInfo = Json.parse(TimerInfo.serializer(), stringJson)
        assertEquals(timerInfo.currentActivity.remainingTime.minutes, 4)
        assertEquals(timerInfo.currentActivity.remainingTime.seconds, 30)
    }

    @Test
    fun `Deserialisation From Json configuration pomodoro duration is 25m`() {
        val stringJson = File("./src/test/resources/scenes/timer/timerInfo.json").readText(Charsets.UTF_8)
        val timerInfo = Json.parse(TimerInfo.serializer(), stringJson)
        assertEquals(timerInfo.configuration.pomodoroDurationInMin, 25)
    }

    @Test
    fun `Deserialisation From Json Activity configuration long break duration is 15m`() {
        val stringJson = File("./src/test/resources/scenes/timer/timerInfo.json").readText(Charsets.UTF_8)
        val timerInfo = Json.parse(TimerInfo.serializer(), stringJson)
        assertEquals(timerInfo.configuration.longBreakDurationInMin, 15)
    }

    @Test
    fun `Deserialisation From Json configuration short break duration is 5m`() {
        val stringJson = File("./src/test/resources/scenes/timer/timerInfo.json").readText(Charsets.UTF_8)
        val timerInfo = Json.parse(TimerInfo.serializer(), stringJson)
        assertEquals(timerInfo.configuration.shortBreakDurationInMin, 5)
    }

    @Test
    fun `Deserialisation From Json configuration long break frequency duration is 4`() {
        val stringJson = File("./src/test/resources/scenes/timer/timerInfo.json").readText(Charsets.UTF_8)
        val timerInfo = Json.parse(TimerInfo.serializer(), stringJson)
        assertEquals(timerInfo.configuration.longBreakFrequency, 4)
    }
}