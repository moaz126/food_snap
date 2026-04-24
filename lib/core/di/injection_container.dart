import 'package:food_snap/data/database/database_helper.dart';
import 'package:food_snap/data/repositories/food_repository_impl.dart';
import 'package:food_snap/domain/repositories/food_repository.dart';
import 'package:food_snap/domain/usecases/analyze_food.dart';
import 'package:food_snap/domain/usecases/get_all_records.dart';
import 'package:food_snap/domain/usecases/get_record_by_id.dart';
import 'package:food_snap/presentation/home/bloc/history_cubit.dart';
import 'package:food_snap/presentation/result_detail/bloc/food_analysis_bloc.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerSingletonAsync<DatabaseHelper>(() async {
    final db = DatabaseHelper();
    await db.init();
    return db;
  });

  sl.registerLazySingleton<FoodRepository>(() => FoodRepositoryImpl(databaseHelper: sl()));

  sl.registerLazySingleton(() => AnalyzeFood(sl()));
  sl.registerLazySingleton(() => GetAllRecords(sl()));
  sl.registerLazySingleton(() => GetRecordById(sl()));

  sl.registerFactory(() => FoodAnalysisBloc(analyzeFood: sl()));
  sl.registerFactory(() => HistoryCubit(getAllRecords: sl()));

  await sl.allReady();
}
