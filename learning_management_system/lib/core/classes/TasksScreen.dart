// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controller/TaskController.dart';
import '../../locale/LocaleController.dart';
import '../../themes/ThemeController.dart';
import '../../themes/Themes.dart';
import '../constants/FontGlobals.dart';

class TasksScreen extends StatelessWidget {
  TasksScreen({super.key});
  final ThemeController themeController = Get.find<ThemeController>();
  final LocaleController localeController = Get.find<LocaleController>();

  @override
  Widget build(BuildContext context) {
    final TaskController taskController = Get.put(TaskController());
    final bool isLightTheme =
        themeController.initialTheme == Themes.customLightTheme;
    final Color primaryColor =
        isLightTheme
            ? const Color.fromARGB(255, 40, 41, 61)
            : const Color.fromARGB(255, 210, 209, 224);
    final Color secondaryColor =
        isLightTheme
            ? const Color.fromARGB(255, 210, 209, 224)
            : const Color.fromARGB(255, 40, 41, 61);

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        body: Container(
          color: primaryColor,
          child: Column(
            children: [
              Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_rounded, color: secondaryColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(
                    // padding: const EdgeInsets.only(top: 25),
                    height: 100,
                    child: Center(
                      child: Text(
                            "Tasks Manager".tr,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall!.copyWith(
                              fontFamily: globalFontFamily,
                              color: secondaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  globalFontSizeChange <= 17
                                      ? (globalFontSizeChange / 5) + 23
                                      : 23 - (globalFontSizeChange / 5),
                            ),
                          )
                          .animate(onPlay: (controller) => controller.loop())
                          .shimmer(
                            delay: Duration(seconds: 4),
                            duration: 800.ms,
                            color:
                                themeController.initialTheme ==
                                        Themes.customLightTheme
                                    ? Colors.grey.shade700
                                    : Colors.white54,
                          ),
                    ),
                  ),
                  const SizedBox(width: 25),
                ],
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: secondaryColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60),
                    ),
                  ),
                  child: Column(
                    children: [
                      Obx(() {
                        if (taskController.isLoading.value) {
                          return Expanded(
                            child: Center(
                              child: CircularProgressIndicator(
                                color: primaryColor,
                              ),
                            ),
                          );
                        }

                        if (taskController.errorMessage.isNotEmpty) {
                          return Expanded(
                            child: Center(
                              child: Text(
                                'حدث خطأ: ${taskController.errorMessage.value}',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontFamily: globalFontFamily,
                                ),
                              ),
                            ),
                          );
                        }

                        switch (taskController.currentIndex.value) {
                          case 0:
                            return const Expanded(child: TaskListScreen());
                          case 1:
                            return const Expanded(
                              child: CompletedTasksScreen(),
                            );
                          case 2:
                            return const Expanded(child: TrashScreen());
                          default:
                            return const Expanded(child: TaskListScreen());
                        }
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Obx(() {
          final bool isLightTheme =
              themeController.initialTheme == Themes.customLightTheme;
          final Color primaryColor =
              isLightTheme
                  ? const Color.fromARGB(255, 40, 41, 61)
                  : const Color.fromARGB(255, 210, 209, 224);
          final Color secondaryColor =
              isLightTheme
                  ? const Color.fromARGB(255, 210, 209, 224)
                  : const Color.fromARGB(255, 40, 41, 61);

          return BottomNavigationBar(
            currentIndex: taskController.currentIndex.value,
            onTap: (index) => taskController.currentIndex.value = index,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt, color: secondaryColor),
                label: "Tasks".tr,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.check_circle, color: secondaryColor),
                label: "Completed".tr,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.delete, color: secondaryColor),
                label: "Deleted".tr,
              ),
            ],
            backgroundColor: primaryColor,
            selectedItemColor: secondaryColor,
            unselectedItemColor: secondaryColor.withOpacity(0.7),
          );
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddTaskDialog(),
          backgroundColor: primaryColor,
          child: Icon(Icons.add, color: secondaryColor),
        ),
      ),
    );
  }

  void _showAddTaskDialog() {
    final TaskController taskController = Get.find();
    final ThemeController themeController = Get.find<ThemeController>();
    final bool isLightTheme =
        themeController.initialTheme == Themes.customLightTheme;
    final Color primaryColor =
        isLightTheme
            ? const Color.fromARGB(255, 40, 41, 61)
            : const Color.fromARGB(255, 210, 209, 224);
    final Color secondaryColor =
        isLightTheme
            ? const Color.fromARGB(255, 210, 209, 224)
            : const Color.fromARGB(255, 40, 41, 61);

    final titleController = TextEditingController();
    final descController = TextEditingController();
    Rx<DateTime?> dueDate = Rx<DateTime?>(DateTime.now());
    RxDouble estimatedHours = 1.0.obs;

    Get.dialog(
      Dialog(
        backgroundColor: secondaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Add New Task".tr,
                style: TextStyle(
                  fontFamily: globalFontFamily,
                  fontSize:
                      globalFontSizeChange <= 17
                          ? (globalFontSizeChange / 5) + 20
                          : 20 - (globalFontSizeChange / 5),
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: "Task Title".tr,
                  labelStyle: TextStyle(color: primaryColor),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: TextStyle(color: primaryColor),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Description".tr,
                  labelStyle: TextStyle(color: primaryColor),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: TextStyle(color: primaryColor),
              ),
              const SizedBox(height: 16),
              Obx(
                () => ListTile(
                  leading: Icon(Icons.calendar_today, color: primaryColor),
                  title: Text(
                    "Due Date".tr,
                    style: TextStyle(
                      color: primaryColor,
                      fontFamily: globalFontFamily,
                    ),
                  ),
                  subtitle: Text(
                    dueDate.value == null
                        ? "Not Date Specified".tr
                        : DateFormat.yMd().add_jm().format(dueDate.value!),
                    style: TextStyle(
                      color: primaryColor.withOpacity(0.7),
                      fontFamily: globalFontFamily,
                    ),
                  ),
                  onTap: () async {
                    final selectedDate = await showDatePicker(
                      context: Get.context!,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );

                    if (selectedDate != null) {
                      final selectedTime = await showTimePicker(
                        context: Get.context!,
                        initialTime: TimeOfDay.fromDateTime(selectedDate),
                      );

                      if (selectedTime != null) {
                        dueDate.value = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );
                      } else {
                        dueDate.value = DateTime.now();
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => ListTile(
                  leading: Icon(Icons.timer, color: primaryColor),
                  title: Text(
                    "Expected Duration(hours):".tr,
                    style: TextStyle(
                      color: primaryColor,
                      fontFamily: globalFontFamily,
                    ),
                  ),
                  subtitle: Slider(
                    value: estimatedHours.value,
                    min: 0.5,
                    max: 10,
                    divisions: 19,
                    activeColor: primaryColor,
                    inactiveColor: primaryColor.withOpacity(0.3),
                    label: estimatedHours.value.toStringAsFixed(1),
                    onChanged: (value) => estimatedHours.value = value,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      "Cancel".tr,
                      style: TextStyle(
                        color: primaryColor,
                        fontFamily: globalFontFamily,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: secondaryColor,
                    ),
                    onPressed: () {
                      if (titleController.text.isEmpty) {
                        Get.snackbar("Error".tr, "Please Enter Task Title.".tr);
                        return;
                      }

                      taskController.addTask(
                        titleController.text,
                        descController.text,
                        estimatedHours.value,
                        DateFormat.yMd().add_jm().format(dueDate.value!),
                      );
                      Get.back();
                    },
                    child: Text(
                      "Add".tr,
                      style: TextStyle(fontFamily: globalFontFamily),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskController taskController = Get.find();
    final ThemeController themeController = Get.find<ThemeController>();
    final bool isLightTheme =
        themeController.initialTheme == Themes.customLightTheme;
    final Color primaryColor =
        isLightTheme
            ? const Color.fromARGB(255, 40, 41, 61)
            : const Color.fromARGB(255, 210, 209, 224);

    return Obx(() {
      if (taskController.activeTasks.isEmpty) {
        return Center(
          child: Text(
            "There is no Current task".tr,
            style: TextStyle(color: primaryColor, fontFamily: globalFontFamily),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: taskController.activeTasks.length,
        itemBuilder: (context, index) {
          final task = taskController.activeTasks[index];
          return TaskCard(task: task);
        },
      );
    });
  }
}

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final TaskController taskController = Get.find();
    final ThemeController themeController = Get.find<ThemeController>();
    final bool isLightTheme =
        themeController.initialTheme == Themes.customLightTheme;
    final Color primaryColor =
        isLightTheme
            ? const Color.fromARGB(255, 40, 41, 61)
            : const Color.fromARGB(255, 210, 209, 224);
    // final Color secondaryColor =
    //     isLightTheme
    //         ? const Color.fromARGB(255, 210, 209, 224)
    //         : const Color.fromARGB(255, 40, 41, 61);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontFamily: globalFontFamily,
                      fontSize:
                          globalFontSizeChange <= 17
                              ? (globalFontSizeChange / 5) + 18
                              : 18 - (globalFontSizeChange / 5),
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
                // Checkbox(
                //   value: task.isChecked,
                //   activeColor: primaryColor,
                //   onChanged: (value) => taskController.toggleComplete(task.id),
                // ),
                IconButton(
                  icon: Icon(Icons.check_box_outlined, color: primaryColor),
                  onPressed: () => taskController.toggleComplete(task.id),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              task.description,
              style: TextStyle(
                color: primaryColor.withOpacity(0.7),
                fontFamily: globalFontFamily,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.date_range, size: 16, color: primaryColor),
                const SizedBox(width: 4),
                Text(
                  '${"Creation Date".tr}: ${DateFormat.yMd().format(task.createdAt)}',
                  style: TextStyle(
                    fontSize:
                        globalFontSizeChange <= 17
                            ? (globalFontSizeChange / 5) + 12
                            : 12 - (globalFontSizeChange / 5),
                    color: primaryColor,
                    fontFamily: globalFontFamily,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (task.dueDate != null)
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: primaryColor),
                  const SizedBox(width: 4),
                  Text(
                    '${"Delivery Date".tr}: ${DateFormat.yMd().add_jm().format(task.dueDate!)}',
                    style: TextStyle(
                      fontSize:
                          globalFontSizeChange <= 17
                              ? (globalFontSizeChange / 5) + 12
                              : 12 - (globalFontSizeChange / 5),
                      color: primaryColor,
                      fontFamily: globalFontFamily,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.timer, size: 16, color: primaryColor),
                const SizedBox(width: 4),
                Text(
                  '${"Expected Duration".tr}: ${task.estimatedHours} ${"hour".tr}',
                  style: TextStyle(
                    fontSize:
                        globalFontSizeChange <= 17
                            ? (globalFontSizeChange / 5) + 12
                            : 12 - (globalFontSizeChange / 5),
                    color: primaryColor,
                    fontFamily: globalFontFamily,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.delete, color: primaryColor),
                  onPressed: () => taskController.moveToTrash(task.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CompletedTasksScreen extends StatelessWidget {
  const CompletedTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskController taskController = Get.find();
    final ThemeController themeController = Get.find<ThemeController>();
    final bool isLightTheme =
        themeController.initialTheme == Themes.customLightTheme;
    final Color primaryColor =
        isLightTheme
            ? const Color.fromARGB(255, 40, 41, 61)
            : const Color.fromARGB(255, 210, 209, 224);

    return Obx(() {
      if (taskController.completedTasks.isEmpty) {
        return Center(
          child: Text(
            'There is no Task Complete'.tr,
            style: TextStyle(color: primaryColor, fontFamily: globalFontFamily),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: taskController.completedTasks.length,
        itemBuilder: (context, index) {
          final task = taskController.completedTasks[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              title: Text(
                task.title,
                style: TextStyle(
                  color: primaryColor,
                  fontFamily: globalFontFamily,
                ),
              ),
              subtitle: Text(
                task.description,
                style: TextStyle(
                  color: primaryColor.withOpacity(0.7),
                  fontFamily: globalFontFamily,
                ),
              ),
              trailing: IconButton(
                icon: Icon(Icons.undo, color: primaryColor),
                onPressed: () => taskController.toggleComplete(task.id),
              ),
            ),
          );
        },
      );
    });
  }
}

class TrashScreen extends StatelessWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskController taskController = Get.find();
    final ThemeController themeController = Get.find<ThemeController>();
    final bool isLightTheme =
        themeController.initialTheme == Themes.customLightTheme;
    final Color primaryColor =
        isLightTheme
            ? const Color.fromARGB(255, 40, 41, 61)
            : const Color.fromARGB(255, 210, 209, 224);

    return Obx(() {
      if (taskController.deletedTasks.isEmpty) {
        return Center(
          child: Text(
            'Recycle Bin is Empty'.tr,
            style: TextStyle(color: primaryColor, fontFamily: globalFontFamily),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: taskController.deletedTasks.length,
        itemBuilder: (context, index) {
          final task = taskController.deletedTasks[index];
          final daysLeft =
              task.trashed_at != null
                  ? 30 - DateTime.now().difference(task.trashed_at!).inDays
                  : 30;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              title: Text(
                task.title,
                style: TextStyle(
                  color: primaryColor,
                  fontFamily: globalFontFamily,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${"Will be permanently deleted after".tr} $daysLeft ${"days".tr}',
                    style: TextStyle(
                      color: primaryColor.withOpacity(0.7),
                      fontFamily: globalFontFamily,
                    ),
                  ),
                  Text(
                    '${"Creation Date".tr}: ${DateFormat.yMd().format(task.createdAt)}',
                    style: TextStyle(
                      color: primaryColor.withOpacity(0.7),
                      fontFamily: globalFontFamily,
                    ),
                  ),
                  Text(
                    task.description,
                    style: TextStyle(
                      color: primaryColor.withOpacity(0.7),
                      fontFamily: globalFontFamily,
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.restore, color: primaryColor),
                    onPressed: () => taskController.restoreTask(task.id),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_forever, color: primaryColor),
                    onPressed: () => taskController.permanentDelete(task.id),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
