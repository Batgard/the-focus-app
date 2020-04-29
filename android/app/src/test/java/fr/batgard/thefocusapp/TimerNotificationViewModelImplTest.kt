package fr.batgard.thefocusapp

import fr.batgard.thefocusapp.scenes.timer.businesslogic.Activity
import fr.batgard.thefocusapp.scenes.timer.businesslogic.ActivityType
import fr.batgard.thefocusapp.scenes.timer.businesslogic.Duration
import fr.batgard.thefocusapp.scenes.timer.businesslogic.Timer
import fr.batgard.thefocusapp.scenes.timer.presentation.TimerNotificationViewModelImpl
import io.mockk.every
import io.mockk.mockk
import junit.framework.Assert.assertEquals
import org.junit.Test

class TimerNotificationViewModelImplTest {
    @Test
    fun `Seconds should always be formatted with two digits`() {

        val mockedTimer = mockk<Timer>()
        every { mockedTimer.onActivityChange(any()) }.answers { } //I don't know this is necessary, but it has to be set
        every { mockedTimer.getCurrentActivity() }.answers {
            Activity(ActivityType.POMODORO, false, Duration(25, 0))
        }
        val timerViewModel = TimerNotificationViewModelImpl(mockedTimer, mockk())

        assertEquals("25:00", timerViewModel.getBody())
    }
}