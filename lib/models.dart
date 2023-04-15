import 'package:equatable/equatable.dart';

class Excercise extends Equatable {
  const Excercise({
    required this.title,
    required this.prelude,
    required this.duration,
    this.index,
    this.startTime,
  });

  final String? title;
  final int? prelude;
  final int? duration;
  final int? index;
  final int? startTime;

  factory Excercise.fromJson(
          Map<String, dynamic> json, int index, int startTime) =>
      Excercise(
          title: json["title"],
          prelude: json["prelude"],
          duration: json["duration"],
          index: index,
          startTime: startTime);

  Map<String, dynamic> toJson() => {
        "title": title,
        "prelude": prelude,
        "duration": duration,
      };

  Excercise copyWith({
    int? prelude,
    String? title,
    int? duration,
    int? index,
    int? startTime,
  }) =>
      Excercise(
          title: title ?? this.title,
          prelude: prelude ?? this.prelude,
          duration: duration ?? this.duration,
          index: index ?? this.index,
          startTime: startTime ?? this.startTime);

  @override
  List<Object?> get props => [title, prelude, duration, index, startTime];
}

class Workout extends Equatable {
  final String? title;
  final List<Excercise> exercises;

  const Workout({required this.title, required this.exercises});

  factory Workout.fromJson(Map<String, dynamic> json) {
    List<Excercise> exercises = [];
    int index = 0;
    int startTime = 0;
    for (var ex in (json['exercises'] as Iterable)) {
      exercises.add(Excercise.fromJson(ex, index, startTime));
      index++;
      startTime += exercises.last.prelude! + exercises.last.duration!;
    }

    return Workout(title: json['title'] as String?, exercises: exercises);
  }

  Map<String, dynamic> toJson() => {'title': title, 'exercises': exercises};

  Workout copywith({String? title}) =>
      Workout(title: title ?? this.title, exercises: exercises);

  int getTotal() =>
      exercises.fold(0, (prev, ex) => prev + ex.prelude! + ex.duration!);

  Excercise getCurrentExercise(int? elapsed) =>
      exercises.lastWhere((element) => element.startTime! <= elapsed!);

  @override
  List<Object?> get props => [title, exercises];

  @override
  bool get stringify => true;
}

abstract class WorkoutState extends Equatable {
  final Workout? workout;
  final int? elapsed;
  const WorkoutState(this.workout, this.elapsed);
}

class WorkoutInitial extends WorkoutState {
  const WorkoutInitial() : super(null, 0);

  @override
  List<Object?> get props => [];
}

class WorkoutInProgress extends WorkoutState {
  const WorkoutInProgress(Workout? workout, int? elapsed)
      : super(workout, elapsed);

  @override
  List<Object?> get props => [workout, elapsed];
}

class WorkoutEditing extends WorkoutState {
  final int index;
  final int? exIndex;

  const WorkoutEditing(Workout? workout, this.index, this.exIndex)
      : super(workout, 0);

  @override
  List<Object?> get props => [workout, index, exIndex];
}

String formatTime(int seconds, bool pad) {
  return (pad)
      ? "${(seconds / 60).floor()}:${(seconds % 60).toString().padLeft(2, "0")}"
      : (seconds > 59)
          ? "${(seconds / 60).floor()}:${(seconds % 60).toString().padLeft(2, "0")}"
          : seconds.toString();
}
