import 'package:hive/hive.dart';
import '../models/workout_model.dart';

class WorkoutStorage {
  static const String boxName = 'workouts';

  static Future<void> saveWorkout(WorkoutModel workout) async {
    final box = await Hive.openBox<WorkoutModel>(boxName);
    await box.add(workout);
  }

  static Future<List<WorkoutModel>> loadWorkouts() async {
    final box = await Hive.openBox<WorkoutModel>(boxName);
    return box.values.toList();
  }
}
