import "package:flutter/material.dart";
import "package:habit_tracker/data.dart";
import "package:habit_tracker/notifiers/tasks_notifier.dart";
import "package:habit_tracker/pages/stopwatch_page.dart";
import "package:habit_tracker/pages/tasks_page.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Widget> pages = [StopWatchPage(), TasksPage()];

  int selectedIndex = 0;

  void navigateBottomBar(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    loadTasks().then((loaded) {
      tasks.value = loaded;
      tasks.notifyListeners();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: navigateBottomBar,
        items: [
          BottomNavigationBarItem(
            label: "Stopwatch",
            icon: Icon(Icons.timer_sharp),
          ),
          BottomNavigationBarItem(label: "Tasks", icon: Icon(Icons.task)),
        ],
      ),
      appBar: AppBar(title: Text("Habit Tracker")),
    );
  }
}
