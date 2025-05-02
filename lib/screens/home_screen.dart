import 'package:flutter/material.dart';
import '../models/workout.dart';
import 'add_workout_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Workout> workouts = [];

  void _addWorkout(String name) {
    setState(() {
      workouts.add(Workout(name: name, date: DateTime.now()));
    });
  }

  Future<void> _openAddWorkoutScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddWorkoutScreen()),
    );

    if (result != null && result is String) {
      _addWorkout(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои тренировки')),
      body:
          workouts.isEmpty
              ? const Center(child: Text('Нет тренировок'))
              : ListView.builder(
                itemCount: workouts.length,
                itemBuilder: (context, index) {
                  final workout = workouts[index];
                  return ListTile(
                    title: Text(workout.name),
                    subtitle: Text(workout.formattedDate),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddWorkoutScreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}
