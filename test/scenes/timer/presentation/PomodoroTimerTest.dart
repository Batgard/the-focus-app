import 'package:test/test.dart';
import 'package:thefocusapp/scenes/timer/presentation/TimerScreenViewModel.dart';

void main() {

  test("Initial value should be 25:00", () {
    //Given
    var pomodoroTimer = PomodoroTimer();
    //Then
    expect(pomodoroTimer.getInitialValue(), equals("25:00"));
  });

  test("Seconds should always be displayed as two digits", () {
    //Given
    var pomodoroTimer = PomodoroTimer(value: TimerValue(minutes: 0, seconds: 10));
    //When
    pomodoroTimer.toggle();
    //Then
    expect(pomodoroTimer.displayableValue(), emitsInOrder(["0:09","0:08"]));
  });

  test("When creating new PomodoroTimer Then timer is paused", () {
    //When
    var pomodoroTimer = PomodoroTimer();
    //Then
    expect(pomodoroTimer.isRunning(), isFalse);
  });

  test(
      "When timer is running Then timer should emit value",
      () {
    //When
    var pomodoroTimer = PomodoroTimer();
    //When
    pomodoroTimer.toggle();
    //Then
    pomodoroTimer.displayableValue().listen(
        expectAsync1((displayedValue) {
          expect(displayedValue, equals("24:59"));
      })
    );
  });

  test("Given Pomodoro is paused When toggling Then timer should be running",
      () {
    //Given
    var pomodoroTimer = PomodoroTimer();
    //When
    pomodoroTimer.toggle();
    //Then
    expect(pomodoroTimer.isRunning(), isTrue);
  });

  test("Given Pomodoro on going When toggling Then pause timer", () {
    //Given
    var pomodoroTimer = PomodoroTimer();
    pomodoroTimer.toggle();
    //When
    pomodoroTimer.toggle();
    //Then
    expect(pomodoroTimer.isRunning(), isFalse);
  });
}
