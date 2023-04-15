import 'package:blocworkouts/cubits.dart';
import 'package:blocworkouts/editworkout.dart';
import 'package:blocworkouts/home.dart';
import 'package:blocworkouts/models.dart';
import 'package:blocworkouts/progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  runApp(const WorkoutTime());
}

class WorkoutTime extends StatelessWidget {
  const WorkoutTime({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bloc Workouts',
      theme: ThemeData(
        primaryColor: Colors.blue,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color.fromARGB(255, 66, 74, 96)),
        ),
      ),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<WorkoutsCubit>(create: (BuildContext context) {
            WorkoutsCubit workoutsCubit = WorkoutsCubit();
            if (workoutsCubit.state.isEmpty) {
              print("... loading json data since the state is empty.");
              workoutsCubit.getWorkouts();
            } else {
              print("... get the  data due to changes on state");
            }
            return workoutsCubit;
          }),
          BlocProvider<WorkoutCubit>(
              create: (BuildContext context) => WorkoutCubit())
        ],
        child: BlocBuilder<WorkoutCubit, WorkoutState>(
          builder: ((context, state) {
            if (state is WorkoutInitial) {
              return const HomePage();
            } else if (state is WorkoutEditing) {
              return const EditWorkoutScreen();
            }
            return const WorkoutInProgressScreen();
          }),
        ),
      ),
    );
  }
}
