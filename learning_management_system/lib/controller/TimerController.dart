import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import '../core/classes/Timer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PomodoroController extends GetxController {
  final RxInt workDuration = 25.obs;
  final RxInt shortBreak = 5.obs;

  final RxInt minutes = 0.obs;
  final RxInt seconds = 0.obs;
  final RxString currentPhase = 'Work'.obs;
  final RxBool isRunning = false.obs;
  final RxDouble progress = 0.0.obs;
  final RxBool showTimerPopup = true.obs;
  final RxBool isMuted = false.obs;

  Timer? _timer;
  static AudioPlayer? audioPlayer;

  // final audioCache = AudioCache(prefix: 'assets/music/');
  bool _isSoundLoaded = false;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
    resetTimer();
    _preloadSound();
    audioPlayer = AudioPlayer();

  }

  Future<void> _preloadSound() async {
    try {
      // await audioPlayer.setSource(AssetSource('music/Song1.mp3'));
      _isSoundLoaded = true;
      print("Sound loaded successfully");
    } catch (e) {
      print('Error loading sound: $e');
      _isSoundLoaded = false;
    }
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    workDuration.value = prefs.getInt('workDuration') ?? 25;
    shortBreak.value = prefs.getInt('shortBreak') ?? 5;
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('workDuration', workDuration.value);
    await prefs.setInt('shortBreak', shortBreak.value);
    print("Settings saved");
  }

  void resetTimer() {
    _timer?.cancel();
    isRunning.value = false;
    currentPhase.value = 'Work';
    minutes.value = workDuration.value;
    seconds.value = 0;
    progress.value = 0;
    print("Timer reset");
  }

  void startTimer() {
    if (isRunning.value) return;

    isRunning.value = true;
    print("Timer started: ${currentPhase.value}");

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds.value > 0) {
        seconds.value--;
      } else {
        if (minutes.value > 0) {
          minutes.value--;
          seconds.value = 59;
        } else {
          _timer?.cancel();
          _handleTimerCompletion();
        }
      }
      _updateProgress();
    });
  }

  void _updateProgress() {
    int totalSeconds;
    if (currentPhase.value == 'Work') {
      totalSeconds = workDuration.value * 60;
    } else {
      totalSeconds = shortBreak.value * 60;
    }

    final remaining = minutes.value * 60 + seconds.value;
    progress.value = 1 - (remaining / totalSeconds);
  }

  void _handleTimerCompletion() {
    _timer?.cancel();
    isRunning.value = false;

    print("Timer completed: ${currentPhase.value}");

    // تشغيل الصوت إذا لم يكن مكتوماً
    if (!isMuted.value) {
      _playAlarmSound();
    }

    // تحديد المرحلة التالية
    if (currentPhase.value == 'Work') {
      currentPhase.value = 'Short Break';
      minutes.value = shortBreak.value;
    } else {
      currentPhase.value = 'Work';
      minutes.value = workDuration.value;
    }

    seconds.value = 0;
    progress.value = 0;
    print("New phase: ${currentPhase.value}");

    // إظهار البوب أب عند انتهاء المؤقت
    // showTimerPopup.value = true;
    Get.dialog(const TimerView());
  }

  Future<void> _playAlarmSound() async {
    try {
      print("Playing sound...");

      if (!_isSoundLoaded) {
        await _preloadSound();
      }

      await audioPlayer!.stop();
      await audioPlayer!.play(AssetSource('assets/music/Alarm'));
      print("Sound played successfully");
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  void pauseTimer() {
    _timer?.cancel();
    isRunning.value = false;
    print("Timer paused");
  }

  void toggleMute() {
    isMuted.value = !isMuted.value;
    if (isMuted.value) {
      // إيقاف الصوت فوراً عند التكتم
      audioPlayer!.stop();
    }
    print("Mute toggled: ${isMuted.value}");
  }

  @override
  void onClose() {
    _timer?.cancel();
    audioPlayer?.dispose();
    audioPlayer = null;
    print("Resources cleaned");
    super.onClose();
  }
}
