import 'dart:async';
import 'package:flutter/material.dart';
import 'package:habit_tracker/data.dart';
import 'package:habit_tracker/models/time_object.dart';
import 'package:habit_tracker/notifiers/tasks_notifier.dart';

class StopWatchPage extends StatefulWidget {
  const StopWatchPage({super.key});

  @override
  State<StopWatchPage> createState() => _StopWatchPageState();
}

class _StopWatchPageState extends State<StopWatchPage> {
  ValueNotifier<IconData> buttonIcon = ValueNotifier(Icons.play_arrow);
  Timer? stopwatchTimer;
  String? selectedValue;
  bool stopwatchRunning = false;

  TimeObject stopwatch = TimeObject(
    hours: 0,
    minutes: 0,
    seconds: 0,
    milliseconds: 0,
  );

  void saveTime() {
    if (selectedValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("No task is selected!"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ),
      );
    }
    if (stopwatch.hours + stopwatch.minutes + stopwatch.seconds == 0 &&
        selectedValue != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Stopwatch time is not enough to save!"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ),
      );
    }
    if (selectedValue != null &&
        stopwatch.hours + stopwatch.minutes + stopwatch.seconds != 0) {
      int totalSeconds =
          stopwatch.seconds +
          (stopwatch.minutes * 60) +
          (stopwatch.hours * 3600);
      resetStopwatch();
      int newHours = totalSeconds ~/ 3600;
      int newMinutes = (totalSeconds % 3600) ~/ 60;
      int newSeconds = totalSeconds % 60;

      String? currentTimeString = tasks.value[selectedValue!];

      List<String> parts = currentTimeString!.split(":");
      int existingHours = int.parse(parts[0]);
      int existingMinutes = int.parse(parts[1]);
      int existingSeconds = int.parse(parts[2]);

      int updatedHours = newHours + existingHours;
      int updatedMinutes = newMinutes + existingMinutes;
      int updatedSeconds = newSeconds + existingSeconds;

      tasks.value[selectedValue!] =
          "${updatedHours.toString().padLeft(2, '0')}:${updatedMinutes.toString().padLeft(2, '0')}:${updatedSeconds.toString().padLeft(2, '0')}";
      tasks.notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
          content: Text("Stopwatch time has been saved to '$selectedValue"),
        ),
      );
    }
  }

  void startStopwatch() {
    stopwatchTimer = Timer.periodic(Duration(milliseconds: 10), (timer) {
      setState(() {
        stopwatch.milliseconds++;
        if (stopwatch.milliseconds == 100) {
          stopwatch.milliseconds = 0;
          stopwatch.seconds++;
          if (stopwatch.seconds == 60) {
            stopwatch.seconds = 0;
            stopwatch.minutes++;
            if (stopwatch.minutes == 60) {
              stopwatch.minutes = 0;
              stopwatch.hours++;
            }
          }
        }
      });
    });
  }

  void stopStopwatch() {
    stopwatchTimer?.cancel();
    stopwatchTimer = null;
  }

  void resetStopwatch() {
    stopwatchTimer?.cancel();
    stopwatchTimer = null;
    buttonIcon.value = Icons.play_arrow;
    setState(() {
      stopwatch.hours = 0;
      stopwatch.minutes = 0;
      stopwatch.seconds = 0;
      stopwatch.milliseconds = 0;
      stopwatchRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              if (stopwatchRunning) {
                stopStopwatch();
                stopwatchRunning = false;
              } else {
                startStopwatch();
                stopwatchRunning = true;
              }
              buttonIcon.value = stopwatchRunning == true
                  ? Icons.pause
                  : Icons.play_arrow;
            },
            child: ValueListenableBuilder(
              valueListenable: buttonIcon,
              builder: (context, value, child) {
                return Icon(value);
              },
            ),
          ),
          SizedBox(width: 10.0),
          Baseline(
            baseline: 50,
            baselineType: TextBaseline.alphabetic,
            child: FloatingActionButton.small(
              onPressed: () {
                resetStopwatch();
              },
              child: Icon(Icons.restart_alt_rounded),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          ValueListenableBuilder(
            valueListenable: tasks,
            builder: (context, tasks, child) {
              final TextStyle style = Theme.of(context).textTheme.bodyMedium!;
              String selectedText = selectedValue ?? "";
              final TextPainter textPainter = TextPainter(
                text: TextSpan(text: selectedText, style: style),
                maxLines: 1,
                textDirection: TextDirection.ltr,
              )..layout(minWidth: 0, maxWidth: double.infinity);

              double totalWidth = textPainter.size.width + 40;

              return AnimatedContainer(
                decoration: BoxDecoration(),
                duration: Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                width: totalWidth + (totalWidth ~/ 5),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      menuWidth: totalWidth < 100 ? 100 : totalWidth * 1.5,
                      isExpanded: true,
                      value: tasks.isNotEmpty ? selectedValue : null,
                      items: tasks.isNotEmpty
                          ? tasks.entries.map((entry) {
                              return DropdownMenuItem<String>(
                                value: entry.key,
                                child: Text(entry.key),
                              );
                            }).toList()
                          : null,
                      onChanged: tasks.isNotEmpty
                          ? (value) {
                              setState(() {
                                selectedValue = value;
                              });
                            }
                          : null,
                    ),
                  ),
                ),
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  saveTime();
                  saveTasks(tasks.value);
                },
                child: Icon(Icons.save_alt),
              ),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    selectedValue == null
                        ? SnackBar(
                            content: Text("No task is selected!"),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 1),
                          )
                        : SnackBar(
                            content: Text(
                              " '$selectedValue' has been deleted from list!",
                            ),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 1),
                          ),
                  );
                  FocusScope.of(context).unfocus();

                  setState(() {
                    tasks.value.remove(selectedValue);
                    tasks.notifyListeners();
                    if (!tasks.value.containsKey(selectedValue)) {
                      selectedValue =
                          null; // or pick another key from tasks.value.keys.first
                    }
                  });
                  saveTasks(tasks.value);
                },

                child: Icon(Icons.delete),
              ),
            ],
          ),
          SizedBox(height: 200),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Baseline(
                  baseline: 47,
                  baselineType: TextBaseline.alphabetic,
                  child: Text(
                    style: TextStyle(fontSize: 46),
                    "${stopwatch.hours.toString().padLeft(2, '0')}:${stopwatch.minutes.toString().padLeft(2, '0')}:${stopwatch.seconds.toString().padLeft(2, '0')}",
                  ),
                ),
                Baseline(
                  baseline: 47,
                  baselineType: TextBaseline.alphabetic,
                  child: Text(
                    style: TextStyle(fontSize: 28),
                    ".${stopwatch.milliseconds.toString().padLeft(2, '0')}",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
