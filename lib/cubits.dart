import 'dart:async';
import 'dart:convert';

import 'package:blocworkouts/models.dart';
import 'package:flutter/services.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:wakelock/wakelock.dart';

class WorkoutCubit extends Cubit<WorkoutState> {
  WorkoutCubit() : super(const WorkoutInitial());
  Timer? _timer;

  editWorkout(Workout workout, int index) =>
      emit(WorkoutEditing(workout, index, null));

  editExercise(int exIndex) {
    emit(WorkoutEditing(
        state.workout, (state as WorkoutEditing).index, exIndex));
  }

  goHome() => emit(const WorkoutInitial());

  onTick(Timer timer) {
    if (state is WorkoutInProgress) {
      WorkoutInProgress wip = state as WorkoutInProgress;
      if (wip.elapsed! < wip.workout!.getTotal()) {
        emit(WorkoutInProgress(wip.workout, wip.elapsed! + 1));
        print("...my elapsed time is ${wip.elapsed}");
      } else {
        _timer!.cancel();
        Wakelock.disable();
        emit(const WorkoutInitial());
      }
    }
  }

  startWorkout(Workout workout, [int? index]) {
    Wakelock.enabled;
    if (index != null) {
    } else {
      emit(WorkoutInProgress(workout, 0));
    }

    _timer = Timer.periodic(const Duration(seconds: 1), onTick);
  }
}

class WorkoutsCubit extends HydratedCubit<List<Workout>> {
  WorkoutsCubit() : super([]);

  getWorkouts() async {
    final List<Workout> workouts = [];

    final workoutsjson =
        jsonDecode(await rootBundle.loadString("assets/workouts.json"));

    for (var el in (workoutsjson as Iterable)) {
      workouts.add(Workout.fromJson(el));
    }
    emit(workouts);
  }

  saveWorkout(Workout workout, int index) {
    Workout newWorkout = Workout(title: workout.title, exercises: []);
    int exIndex = 0;
    int startTime = 0;

    for (var ex in workout.exercises) {
      newWorkout.exercises.add(
        Excercise(
            title: ex.title,
            prelude: ex.prelude,
            duration: ex.duration,
            index: ex.index,
            startTime: ex.startTime),
      );
      exIndex++;
      startTime += ex.prelude! + ex.duration!;
    }
    state[index] = newWorkout;
    print('...I have ${state.length} states');
    emit([...state]);
  }

  @override
  List<Workout>? fromJson(Map<String, dynamic> json) {
    List<Workout> workouts = [];
    json['workouts'].forEach((el) => workouts.add(Workout.fromJson(el)));
    return workouts;
  }

  @override
  Map<String, dynamic>? toJson(List<Workout> state) {
    if (state is List<Workout>) {
      var json = {'workouts': []};
      for (var workout in state) {
        json['workouts']!.add(workout.toJson());
      }
      return json;
    } else {
      return null;
    }
  }
}
