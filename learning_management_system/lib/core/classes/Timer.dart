// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/TimerController.dart';
import '../../controller/FontController.dart';

class TimerView extends StatelessWidget {
  const TimerView({super.key});

  @override
  Widget build(BuildContext context) {
    PomodoroController controller = Get.put(
      PomodoroController(),
      permanent: true,
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(
              () => Text(
                _getPhaseName(controller.currentPhase.value),
                style: TextStyle(
                  fontFamily: FontController().currentFontFamily,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Obx(
              () => Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: CircularProgressIndicator(
                      value: controller.progress.value,
                      strokeWidth: 10,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getPhaseColor(controller.currentPhase.value),
                      ),
                    ),
                  ),
                  Text(
                    '${controller.minutes.value.toString().padLeft(2, '0')}:${controller.seconds.value.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontFamily: FontController().currentFontFamily,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!controller.isRunning.value)
                    _buildActionButton(
                      onPressed: controller.startTimer,
                      icon: Icons.play_arrow,
                      color: Colors.green,
                    ),
                  if (controller.isRunning.value) ...[
                    _buildActionButton(
                      onPressed: controller.pauseTimer,
                      icon: Icons.pause,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 16),
                    _buildActionButton(
                      onPressed: controller.resetTimer,
                      icon: Icons.replay,
                      color: Colors.blue,
                    ),
                  ],
                  const SizedBox(width: 16),
                  _buildActionButton(
                    onPressed: controller.toggleMute,
                    icon:
                        controller.isMuted.value
                            ? Icons.volume_off
                            : Icons.volume_up,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(width: 16),
                  _buildActionButton(
                    onPressed: () => _showSettingsPopup(controller),
                    icon: Icons.settings,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Get.back(); // Close the popup
              },
              child: Text(
                'Close',
                style: TextStyle(
                  fontFamily: FontController().currentFontFamily,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: IconButton(icon: Icon(icon, color: color), onPressed: onPressed),
    );
  }

  void _showSettingsPopup(PomodoroController controller) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.all(40),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Timer Settings',
                style: TextStyle(
                  fontFamily: FontController().currentFontFamily,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 16),
              _buildSettingItem(
                'Work Time (minutes):',
                controller.workDuration,
                Colors.red,
              ),
              _buildSettingItem(
                'Short Break (minutes):',
                controller.shortBreak,
                Colors.green,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: FontController().currentFontFamily,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      controller.saveSettings();
                      controller.resetTimer();
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 141, 88, 233),
                    ),
                    child: Text(
                      'Save',
                      style: TextStyle(
                        fontFamily: FontController().currentFontFamily,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierColor: Colors.transparent,
    );
  }

  Widget _buildSettingItem(String label, RxInt value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontFamily: FontController().currentFontFamily,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove, color: color),
                  onPressed: () => value.value > 1 ? value.value-- : null,
                ),
                Obx(
                  () => Text(
                    value.value.toString(),
                    style: TextStyle(
                      fontFamily: FontController().currentFontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add, color: color),
                  onPressed: () => value.value++,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPhaseName(String phase) {
    switch (phase) {
      case 'Work':
        return 'Work Time 🧑‍💻';
      case 'Short Break':
        return 'Short Break ☕️';
      default:
        return phase;
    }
  }

  Color _getPhaseColor(String phase) {
    switch (phase) {
      case 'Work':
        return Colors.red;
      case 'Short Break':
        return Colors.green;
      default:
        return Colors.deepPurple;
    }
  }
}
