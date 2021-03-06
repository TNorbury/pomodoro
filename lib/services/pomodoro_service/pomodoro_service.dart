import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro/models/pomodoro.dart';

final pomodoroServiceProvider =
    ChangeNotifierProvider((ref) => PomodoroService());

class PomodoroService extends ChangeNotifier {
  Timer? _timer;

  Pomodoro pomodoro = Pomodoro();

  void setPomodoroStage(PomodoroStage stage) {
    pomodoro.currentStage = stage;
    stopTimer();
    notifyListeners();
  }

  /// starts the pomodoro timer
  void startTimer() {
    notifyListeners();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (pomodoro.tick()) {
        timer.cancel();

        // sound the alarm.

        switch (pomodoro.currentStage) {
          case PomodoroStage.work:
            setPomodoroStage(PomodoroStage.shortBreak);
            break;
          case PomodoroStage.shortBreak:
            setPomodoroStage(PomodoroStage.work);
            break;
          case PomodoroStage.longBreak:
            setPomodoroStage(PomodoroStage.work);
            break;
        }
      }

      notifyListeners();
    });
  }

  /// stops the timer
  void stopTimer() {
    _timer?.cancel();
    notifyListeners();
  }

  bool get timerRunning => _timer?.isActive ?? false;

  PomodoroStage get currentStage => pomodoro.currentStage;

  /// Configures the time for the given stage. This will reset the timer
  void setTimeForStage({required PomodoroStage stage, required int minutes}) {
    switch (stage) {
      case PomodoroStage.work:
        pomodoro.workMin = minutes;
        break;
      case PomodoroStage.shortBreak:
        pomodoro.shortBreakMin = minutes;
        break;
      case PomodoroStage.longBreak:
        pomodoro.longBreakMin = minutes;
        break;
    }

    stopTimer();
    notifyListeners();
  }
}
