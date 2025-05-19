import 'dart:async';
import 'package:get/get.dart';

class ReservationTimerController extends GetxController {
  var timers = <int, Rx<Duration>>{}.obs; // key = index de la carte

  void startCountdown(int index, DateTime targetTime) {
    final now = DateTime.now();
    final diff = targetTime.difference(now);

    if (diff.isNegative) return;

    timers[index] = diff.obs;

    Timer.periodic(Duration(seconds: 1), (timer) {
      final newDiff = targetTime.difference(DateTime.now());

      if (newDiff.inSeconds <= 0) {
        timers[index]?.value = Duration.zero;
        timer.cancel();
      } else {
        timers[index]?.value = newDiff;
      }
    });
  }

  String format(Duration duration) {
    if (duration.inSeconds <= 0) return "⛔ Temps écoulé";
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    return "${hours.toString().padLeft(2, '0')}h ${minutes.toString().padLeft(2, '0')}m ${seconds.toString().padLeft(2, '0')}s";
  }
}
