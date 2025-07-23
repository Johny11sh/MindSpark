import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:learning_management_system/controller/TaskController.dart';
import 'package:learning_management_system/locale/LocaleController.dart';
import 'package:learning_management_system/themes/ThemeController.dart';

class TasksScreen extends StatelessWidget {
  TasksScreen({super.key});
  final ThemeController themeController = Get.find<ThemeController>();
  final LocaleController localeController = Get.find<LocaleController>();

  @override
  Widget build(BuildContext context) {
    final TaskController taskController = Get.put(TaskController());
    LocaleController localeController = Get.put(LocaleController());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          locale: localeController.initialLang,
          "Task System".tr,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: taskController.fetchTasks,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTaskDialog(),
          ),
        ],
      ),
      body: Obx(() {
        if (taskController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (taskController.errorMessage.isNotEmpty) {
          return Center(
            child: Text('حدث خطأ: ${taskController.errorMessage.value}'),
          );
        }

        switch (taskController.currentIndex.value) {
          case 0:
            return const TaskListScreen();
          case 1:
            return const CompletedTasksScreen();
          case 2:
            return const TrashScreen();
          default:
            return const TaskListScreen();
        }
      }),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: taskController.currentIndex.value,
          onTap: (index) => taskController.currentIndex.value = index,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.list_alt,color: Colors.white,), label: "Tasks" ),
            BottomNavigationBarItem( icon: Icon(Icons.check_circle,color: Colors.white), label: "Completed", ),
            BottomNavigationBarItem(icon: Icon(Icons.delete,color: Colors.white), label: "Deleted"),
          ],
          backgroundColor: Color(0xFF28293D),
          selectedItemColor: Colors.white ,
          unselectedItemColor: Colors.black,
        ),
      ),
    );
  }

  void _showAddTaskDialog() {
    final TaskController taskController = Get.find();
    final titleController = TextEditingController();
    final descController = TextEditingController();
    Rx<DateTime?> dueDate = Rx<DateTime?>(DateTime.now());
    RxDouble estimatedHours = 1.0.obs;
    
    Get.dialog(
      AlertDialog(
        title: Text("Add New Task".tr,locale:
    localeController.initialLang,),
        content: SingleChildScrollView(
          child: Column(
            children: [
              
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Task Title",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text("Due Date"),
                  subtitle: Text(
                    dueDate.value == null
                        ? "Not Date Specified"
                        : DateFormat.yMd().add_jm().format(dueDate.value!),
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
                  leading: const Icon(Icons.timer),
                  title: const Text("Expected Duration(hours):"),
                  subtitle: Slider(
                    value: estimatedHours.value,
                    min: 0.5,
                    max: 10,
                    divisions: 19,

                    label: estimatedHours.value.toStringAsFixed(1),
                    onChanged: (value) => estimatedHours.value = value,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isEmpty) {
                Get.snackbar("Error", "Please Enter Task Title.");
                return;
              }

              taskController.addTask(
                titleController.text,
                descController.text,
                estimatedHours.value,
                DateFormat.yMd().add_jm().format(dueDate.value!),
              );
              taskController.fetchTasks;
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskController taskController = Get.find();

    return Obx(() {
      if (taskController.activeTasks.isEmpty) {
        return const Center(child: Text("There is no Current task"));
      }

      return ListView.builder(
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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
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
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
                Checkbox(
                  value: task.isChecked,
                  onChanged: (value) => taskController.toggleComplete(task.id),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(task.description),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.date_range, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Creation Date: ${DateFormat.yMd().format(task.createdAt)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (task.dueDate != null)
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Delivery Date: ${DateFormat.yMd().add_jm().format(task.dueDate!)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.timer, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Expectec Duration: ${task.estimatedHours} hour',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Color.fromARGB(255, 252, 75, 75),
                  ),
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

    return Obx(() {
      if (taskController.completedTasks.isEmpty) {
        return const Center(child: Text('There is no Task Complete'));
      }

      return ListView.builder(
        itemCount: taskController.completedTasks.length,
        itemBuilder: (context, index) {
          final task = taskController.completedTasks[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.green[50],
            child: ListTile(
              title: Text(task.title),
              subtitle: Text(task.description),
              trailing: IconButton(
                icon: const Icon(Icons.undo),
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

    return Obx(() {
      if (taskController.deletedTasks.isEmpty) {
        return const Center(child: Text('Recycle Bin is Empty'));
      }

      return ListView.builder(
        itemCount: taskController.deletedTasks.length,
        itemBuilder: (context, index) {
          final task = taskController.deletedTasks[index];
          final daysLeft =
              task.trashed_at != null
                  ? 30 - DateTime.now().difference(task.trashed_at!).inDays
                  : 30;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[200],
            child: ListTile(
              title: Text(task.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text('سيتم حذفها نهائياً بعد $daysLeft يوم'),
                  Text(
                    'Creation Date: ${DateFormat.yMd().format(task.createdAt)}',
                  ),
                  Text(task.description),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.restore),
                    onPressed: () => taskController.restoreTask(task.id),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_forever),
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
