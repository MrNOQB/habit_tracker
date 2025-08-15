import 'package:flutter/material.dart';
import 'package:habit_tracker/notifiers/tasks_notifier.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  TextEditingController taskController = TextEditingController();

  @override
  void dispose() {
    taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: taskController,
                      decoration: InputDecoration(
                        hintText: "Enter Task",
                        enabledBorder: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 2.0,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                      maxLength: 25,
                    ),
                  ),
                ),
                Baseline(
                  baseline: 24,
                  baselineType: TextBaseline.alphabetic,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (!tasks.value.containsKey(
                              taskController.text.trim(),
                            ) &&
                            taskController.text.isNotEmpty) {
                          tasks.value[taskController.text] = "00:00:00";
                          tasks.notifyListeners();
                        }
                        taskController.clear();
                        FocusScope.of(context).unfocus();
                      },
                      child: Icon(Icons.add),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ValueListenableBuilder(
              valueListenable: tasks,
              builder: (context, value, child) {
                final entries = value.entries.toList();
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return ListTile(
                      title: Text(entry.key),
                      subtitle: Text(entry.value),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
