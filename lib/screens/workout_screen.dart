import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:builder2_0/models/workout_model.dart';
import 'active_workout_screen.dart';
import 'WorkoutDetailScreen.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  DateTime selectedDate = DateTime.now();
  late PageController _pageController;
  int currentWeekOffset = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 5000);
  }

  void _showWorkoutNameDialog() {
    String workoutName = '';

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Название тренировки',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: (value) => workoutName = value,
                    decoration: const InputDecoration(
                      hintText: 'Введите название...',
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF34C759)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF34C759),
                          width: 2,
                        ),
                      ),
                    ),
                    cursorColor: const Color(0xFF34C759),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF34C759),
                        ),
                        child: const Text('Отмена'),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => ActiveWorkoutScreen(
                                    workoutName:
                                        workoutName.isEmpty
                                            ? 'Без названия'
                                            : workoutName,
                                  ),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF34C759),
                        ),
                        child: const Text('Начать'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  String getWeekdayName(DateTime date) {
    const weekdays = ['ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ', 'ВС'];
    return weekdays[date.weekday - 1];
  }

  DateTime getStartOfWeek() {
    return DateTime.now().add(
      Duration(days: currentWeekOffset * 7 - DateTime.now().weekday + 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: Hive.box<WorkoutModel>('workouts').listenable(),
          builder: (context, Box<WorkoutModel> box, _) {
            final workoutsForDay =
                box.values
                    .where((w) => DateUtils.isSameDay(w.date, selectedDate))
                    .toList();
            final allDatesWithWorkouts = box.values.map((w) => w.date).toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('d MMMM y', 'ru').format(selectedDate),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            workoutsForDay.isEmpty
                                ? 'Не запланировано'
                                : 'Есть тренировки',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: _showWorkoutNameDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF34C759),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Начать тренировку'),
                      ),
                    ],
                  ),
                ),
                // Календарь
                SizedBox(
                  height: 90,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () {
                          setState(() {
                            currentWeekOffset--;
                            selectedDate = getStartOfWeek();
                          });
                        },
                      ),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            key: ValueKey(currentWeekOffset),
                            children: List.generate(7, (index) {
                              final date = getStartOfWeek().add(
                                Duration(days: index),
                              );
                              final isSelected = DateUtils.isSameDay(
                                date,
                                selectedDate,
                              );
                              final hasWorkout = allDatesWithWorkouts.any(
                                (wDate) => DateUtils.isSameDay(wDate, date),
                              );

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedDate = date;
                                  });
                                },
                                child: Column(
                                  children: [
                                    Text(
                                      getWeekdayName(date),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            isSelected
                                                ? Colors.black
                                                : Colors.transparent,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${date.day}',
                                        style: TextStyle(
                                          color:
                                              isSelected
                                                  ? Colors.white
                                                  : Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (hasWorkout)
                                      const Padding(
                                        padding: EdgeInsets.only(top: 2),
                                        child: Icon(
                                          Icons.circle,
                                          size: 6,
                                          color: Color(0xFF34C759),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
                          setState(() {
                            currentWeekOffset++;
                            selectedDate = getStartOfWeek();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                // История
                Expanded(
                  child:
                      workoutsForDay.isEmpty
                          ? const Center(
                            child: Text(
                              'Здесь появятся упражнения\nили история за день',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                          : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: workoutsForDay.length,
                            itemBuilder: (context, index) {
                              final workout = workoutsForDay[index];
                              final exerciseNames =
                                  workout.exercises.map((e) => e.name).toList();

                              // Calculate total weight
                              final totalWeight = workout.exercises
                                  .fold<double>(
                                    0.0,
                                    (sum, exercise) =>
                                        sum +
                                        exercise.sets.fold<double>(
                                          0.0,
                                          (setSum, set) =>
                                              setSum +
                                              (double.tryParse(set.weight) ??
                                                      0) *
                                                  (int.tryParse(set.reps) ?? 0),
                                        ),
                                  );

                              // Calculate XP
                              final xp = totalWeight.toInt();

                              // Duration in minutes
                              final durationInMinutes =
                                  workout.date
                                      .difference(DateTime.now())
                                      .inMinutes;
                              final workoutDuration =
                                  durationInMinutes > 0
                                      ? '$durationInMinutes мин'
                                      : '0 мин';

                              return GestureDetector(
                                // Оборачиваем карточку в GestureDetector
                                onTap: () {
                                  // Переход на экран с подробностями тренировки
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => WorkoutDetailScreen(
                                            workout: workout,
                                          ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            workout.name,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              box.deleteAt(
                                                index,
                                              ); // Удаляем тренировку
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        DateFormat.Hm().format(workout.date),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${workout.exercises.length} упражнений',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Суммарный вес: $totalWeight кг',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        'XP: $xp',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        'Длительность тренировки: $workoutDuration',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        exerciseNames.length > 3
                                            ? '${exerciseNames.take(3).join(', ')}...'
                                            : exerciseNames.join(', '),
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
