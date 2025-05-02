import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive/hive.dart';
import 'package:builder2_0/models/workout_model.dart';
import 'package:builder2_0/screens/select_exercise_screen.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final String workoutName;

  const ActiveWorkoutScreen({super.key, required this.workoutName});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  Duration elapsed = Duration.zero;
  Duration totalElapsed = Duration.zero;
  late final Ticker _ticker;
  bool isRunning = true;

  List<Map<String, dynamic>> exercises = [];
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _ticker = Ticker((elapsedTime) {
      if (isRunning) {
        setState(() {
          elapsed = totalElapsed + elapsedTime;
        });
      }
    });
    _ticker.start();
    _pageController = PageController(viewportFraction: 0.83);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _pageController.dispose();
    super.dispose();
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  void _addExercise() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SelectExerciseScreen()),
    );

    if (result != null && result is String) {
      setState(() {
        exercises.add({
          'name': result,
          'sets': [
            {'reps': '', 'weight': ''},
          ],
        });
      });
    }
  }

  void _addSet(int index) {
    setState(() {
      exercises[index]['sets'].add({'reps': '', 'weight': ''});
    });
  }

  void _removeSet(int exerciseIndex, int setIndex) {
    setState(() {
      exercises[exerciseIndex]['sets'].removeAt(setIndex);
    });
  }

  void _deleteExercise(int index) {
    setState(() {
      exercises.removeAt(index);
    });
  }

  void _toggleTimer() {
    setState(() {
      if (isRunning) {
        totalElapsed = elapsed;
        _ticker.stop();
      } else {
        _ticker.start();
      }
      isRunning = !isRunning;
    });
  }

  Future<void> _saveAndFinishWorkout() async {
    final workout = WorkoutModel(
      name: widget.workoutName,
      date: DateTime.now(),
      exercises:
          exercises.map((e) {
            return WorkoutExercise(
              name: e['name'],
              sets:
                  (e['sets'] as List<Map<String, String>>)
                      .map(
                        (s) => WorkoutSet(
                          reps: s['reps'] ?? '',
                          weight: s['weight'] ?? '',
                        ),
                      )
                      .toList(),
            );
          }).toList(),
    );

    final box = await Hive.openBox<WorkoutModel>('workouts');
    await box.add(workout);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = formatTime(elapsed);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Верх
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Название и время
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.workoutName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(timeStr, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  // Кнопки
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _saveAndFinishWorkout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Закончить'),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: exercises.length + 1,
                itemBuilder: (context, index) {
                  if (index < exercises.length) {
                    final exercise = exercises[index];
                    final sets = exercise['sets'];

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 24,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  exercise['name'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _deleteExercise(index),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: ListView.builder(
                                itemCount: sets.length,
                                itemBuilder: (_, setIndex) {
                                  final set = sets[setIndex];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text('Set ${setIndex + 1}'),
                                        SizedBox(
                                          width: 70,
                                          child: TextField(
                                            textAlign: TextAlign.center,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              labelText: 'Reps',
                                            ),
                                            onChanged:
                                                (value) => set['reps'] = value,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 70,
                                          child: TextField(
                                            textAlign: TextAlign.center,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              labelText: 'Weight',
                                            ),
                                            onChanged:
                                                (value) =>
                                                    set['weight'] = value,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed:
                                      sets.length > 1
                                          ? () =>
                                              _removeSet(index, sets.length - 1)
                                          : null,
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () => _addSet(index),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 24,
                      ),
                      child: GestureDetector(
                        onTap: _addExercise,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.add,
                              size: 40,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),

            // Кнопка "Пауза/Старт"
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _toggleTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF34C759),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isRunning ? 'Пауза' : 'Старт',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
