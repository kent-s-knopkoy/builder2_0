import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:builder2_0/models/workout_model.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final WorkoutModel workout;

  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    // Вычисление суммарного веса тренировки
    final totalWeight = workout.exercises.fold<double>(0.0, (sum, exercise) {
      return sum +
          exercise.sets.fold<double>(0.0, (setSum, set) {
            return setSum + (double.tryParse(set.weight) ?? 0.0);
          });
    });

    // Форматируем длительность тренировки
    String formatDuration(Duration duration) {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      final minutes = twoDigits(duration.inMinutes.remainder(60));
      final seconds = twoDigits(duration.inSeconds.remainder(60));
      return "$minutes:$seconds";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(workout.name),
        backgroundColor: const Color.fromARGB(212, 87, 226, 122),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Заголовок и информация о тренировке
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Дата тренировки: ${DateFormat('d MMMM y').format(workout.date)}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Длительность: 0',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Суммарный вес: ${totalWeight.toStringAsFixed(2)} кг',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.fitness_center,
                    size: 48,
                    color: Colors.green.shade800,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Упражнения
            Text(
              'Упражнения:',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            for (var exercise in workout.exercises) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (var set in exercise.sets)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Повторений: ${set.reps}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Вес: ${set.weight} кг',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
