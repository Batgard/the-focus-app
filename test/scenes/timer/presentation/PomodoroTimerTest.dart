import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:thefocusapp/scenes/timer/data/ActivityType.dart';
import 'package:thefocusapp/scenes/timer/data/TimerDuration.dart';
import 'package:thefocusapp/scenes/timer/presentation/TimerScreenViewModel.dart';

void main() {
  test("Initial value should be 25:00", () {
    //Given
    var pomodoroTimer = PomodoroTimer(notification: MockNotification());
    //Then
    expect(pomodoroTimer.getInitialValue(), equals("25:00"));
  });

  test("Seconds should always be displayed as two digits", () {
    //Given
    var pomodoroTimer =
        PomodoroTimer(configuration: TimerConfiguration(
            pomodoroDuration: TimerDuration(minutes: 0, seconds: 10),
            shortBreakDuration: TimerDuration(minutes: 0,seconds: 10),
            longBreakDuration: TimerDuration(minutes: 0, seconds: 10),
            numberOfCompletedPomodorosRequiredForLongBreak: 4
          ),
            notification: MockNotification()
        );
    //When
    pomodoroTimer.toggle();
    //Then
    expect(pomodoroTimer.displayableValue(), emitsInOrder(["0:09", "0:08"]));
  });

  test("When creating new PomodoroTimer Then timer is paused", () {
    //When
    var pomodoroTimer = PomodoroTimer(notification: MockNotification());
    //Then
    expect(pomodoroTimer.isRunning(), isFalse);
  });

  test("When timer is running Then timer should emit value", () {
    //When
    var pomodoroTimer = PomodoroTimer(notification: MockNotification());
    //When
    pomodoroTimer.toggle();
    //Then
    expect(pomodoroTimer.displayableValue(), emitsInOrder(["24:59"]));
  });

  test("Given Pomodoro is paused When toggling Then timer should be running",
      () {
    //Given
    var pomodoroTimer = PomodoroTimer(notification: MockNotification());
    //When
    pomodoroTimer.toggle();
    //Then
    expect(pomodoroTimer.isRunning(), isTrue);
  });

  test("Given Pomodoro on going When toggling Then pause timer", () {
    //Given
    var pomodoroTimer = PomodoroTimer(notification: MockNotification());
    pomodoroTimer.toggle();
    //When
    pomodoroTimer.toggle();
    //Then
    expect(pomodoroTimer.isRunning(), isFalse);
  });

  test(
      "When I have not completed any pomodoro Then completed pomodoro count equals 0",
      () {
    //Given
    var pomodoroTimer = PomodoroTimer(notification: MockNotification());
    //Then
    expect(pomodoroTimer.getCompletedPomodoroCount(), 0);
  });

  test(
      "Given completed pomodoro count equals 0 When I complete a pomodoro Then count equals 1",
      () {
    //Given
    var pomodoroTimer =
        PomodoroTimer(
            configuration: TimerConfiguration(
                pomodoroDuration: TimerDuration(minutes: 0, seconds: 1),
                shortBreakDuration: TimerDuration(minutes: 0,seconds: 1),
                longBreakDuration: TimerDuration(minutes: 0, seconds: 1),
                numberOfCompletedPomodorosRequiredForLongBreak: 4
            ),
            notification: MockNotification()
        );
    //When
    pomodoroTimer.toggle();
    //Then
    pomodoroTimer.timerTypeChanges().listen(expectAsync1((activity) {
        expect(pomodoroTimer.getCompletedPomodoroCount(), 1);
      }, count: 1, max: 1)
    );
  });

  test("When I complete a pomodoro Then start a break", () {
    //Given
    var pomodoroTimer =
        PomodoroTimer(
            configuration: TimerConfiguration(
                pomodoroDuration: TimerDuration(minutes: 0, seconds: 1),
                shortBreakDuration: TimerDuration(minutes: 0,seconds: 1),
                longBreakDuration: TimerDuration(minutes: 0, seconds: 1),
                numberOfCompletedPomodorosRequiredForLongBreak: 4
            ),
            notification: MockNotification()
        );
    //When
    pomodoroTimer.toggle();
    //Then
    pomodoroTimer.timerTypeChanges().listen(expectAsync1((activity) {
        expect(activity.type, ActivityType.shortBreak);
      }, count: 1, max: 1) // NB: The framework is buggy and calls the method more than 1 time before considering the test complete, when it should not.
    );
  });

  test("Given I have completed 2 Pomodoros When I complete the 3rd one I get a long break", () {
    var pomodoroTimer =
    PomodoroTimer(
        configuration: TimerConfiguration(
            pomodoroDuration: TimerDuration(minutes: 0, seconds: 1),
            shortBreakDuration: TimerDuration(minutes: 0,seconds: 1),
            longBreakDuration: TimerDuration(minutes: 0, seconds: 10),
            numberOfCompletedPomodorosRequiredForLongBreak: 3
        ),
        notification: MockNotification()
    );
    //When
    pomodoroTimer.toggle();
    //Then
    var pomodoroEmission = "0:00";
    var shortBreakEmission = "0:00";
    var longBreakEmission = "0:09";
    expect(pomodoroTimer.displayableValue(), emitsInOrder(
        [
          pomodoroEmission,
          shortBreakEmission,
          pomodoroEmission,
          shortBreakEmission,
          pomodoroEmission,
          longBreakEmission
        ]
    ));
  });

  test("Verify call once to show notification on new activity start", () {
    //Given
    var mockNotification = MockNotification();
    var pomodoroTimer =
    PomodoroTimer(
        configuration: TimerConfiguration(
            pomodoroDuration: TimerDuration(minutes: 0, seconds: 1),
            shortBreakDuration: TimerDuration(minutes: 0,seconds: 1),
            longBreakDuration: TimerDuration(minutes: 0, seconds: 1),
            numberOfCompletedPomodorosRequiredForLongBreak: 4
        ),
        notification: mockNotification
    );
    //When
    pomodoroTimer.toggle();
    //Then
    pomodoroTimer.timerTypeChanges().listen(expectAsync1((activity) {
      verify(mockNotification.showNewActivityStartNotification(argThat(anything))).called(1);
    }, count: 2, max: 2)
    );
  });

  test("Verify call to update notification", () {
    //Given
    var mockNotification = MockNotification();
    var pomodoroTimer =
    PomodoroTimer(
        configuration: TimerConfiguration(
            pomodoroDuration: TimerDuration(minutes: 0, seconds: 3),
            shortBreakDuration: TimerDuration(minutes: 0,seconds: 1),
            longBreakDuration: TimerDuration(minutes: 0, seconds: 1),
            numberOfCompletedPomodorosRequiredForLongBreak: 4
        ),
        notification: mockNotification
    );
    //When
    pomodoroTimer.toggle();
    //Then
    pomodoroTimer.displayableValue().listen(expectAsync1((activity) {
      verify(mockNotification.updateExistingNotification(argThat(anything))).called(1);
    }, count: 2, max: 2)
    );
  });

  test("Verify call to pause notification", () {

    //Given
    var mockNotification = MockNotification();
    var pomodoroTimer =
    PomodoroTimer(
        configuration: TimerConfiguration(
            pomodoroDuration: TimerDuration(minutes: 0, seconds: 3),
            shortBreakDuration: TimerDuration(minutes: 0,seconds: 1),
            longBreakDuration: TimerDuration(minutes: 0, seconds: 1),
            numberOfCompletedPomodorosRequiredForLongBreak: 4
        ),
        notification: mockNotification
    );
    //When
    pomodoroTimer.toggle();
    pomodoroTimer.toggle();
    //Then
    verify(
        mockNotification.updateExistingNotificationActivityPaused(
            argThat(anything)
        )
    ).called(1);
  });
}


class MockNotification extends Mock implements TimerNotification {

}
