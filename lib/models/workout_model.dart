import 'package:hive/hive.dart';

part 'workout_model.g.dart';

@HiveType(typeId: 0)
class WorkoutModel extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late DateTime date;

  @HiveField(2)
  late List<WorkoutExercise> exercises;

  WorkoutModel({
    required this.name,
    required this.date,
    required this.exercises,
  });
}

@HiveType(typeId: 1)
class WorkoutExercise extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late List<WorkoutSet> sets;

  WorkoutExercise({required this.name, required this.sets});

  // Метод для вычисления суммарного веса упражнения
  double get totalWeight {
    double total = 0.0;
    for (var set in sets) {
      total += (int.tryParse(set.weight) ?? 0) * (int.tryParse(set.reps) ?? 0);
    }
    return total;
  }
}

@HiveType(typeId: 2)
class WorkoutSet extends HiveObject {
  @HiveField(0)
  late String reps;

  @HiveField(1)
  late String weight;

  WorkoutSet({required this.reps, required this.weight});
}
