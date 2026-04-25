// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:food_snap/core/theme/theme_cubit.dart' as _i284;
import 'package:food_snap/data/database/database_helper.dart' as _i110;
import 'package:food_snap/data/repositories/food_repository_impl.dart' as _i79;
import 'package:food_snap/domain/repositories/food_repository.dart' as _i535;
import 'package:food_snap/domain/usecases/analyze_food.dart' as _i1015;
import 'package:food_snap/domain/usecases/delete_record.dart' as _i763;
import 'package:food_snap/domain/usecases/get_all_records.dart' as _i257;
import 'package:food_snap/domain/usecases/get_record_by_id.dart' as _i956;
import 'package:food_snap/presentation/home/bloc/history_cubit.dart' as _i532;
import 'package:food_snap/presentation/result_detail/bloc/food_analysis_bloc.dart'
    as _i172;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  gh.factory<_i284.ThemeCubit>(() => _i284.ThemeCubit());
  gh.singleton<_i110.DatabaseHelper>(() => _i110.DatabaseHelper());
  gh.lazySingleton<_i535.FoodRepository>(() =>
      _i79.FoodRepositoryImpl(databaseHelper: gh<_i110.DatabaseHelper>()));
  gh.lazySingleton<_i763.DeleteRecord>(
      () => _i763.DeleteRecord(gh<_i535.FoodRepository>()));
  gh.lazySingleton<_i1015.AnalyzeFood>(
      () => _i1015.AnalyzeFood(gh<_i535.FoodRepository>()));
  gh.lazySingleton<_i257.GetAllRecords>(
      () => _i257.GetAllRecords(gh<_i535.FoodRepository>()));
  gh.lazySingleton<_i956.GetRecordById>(
      () => _i956.GetRecordById(gh<_i535.FoodRepository>()));
  gh.factory<_i172.FoodAnalysisBloc>(
      () => _i172.FoodAnalysisBloc(analyzeFood: gh<_i1015.AnalyzeFood>()));
  gh.factory<_i532.HistoryCubit>(
      () => _i532.HistoryCubit(getAllRecords: gh<_i257.GetAllRecords>()));
  return getIt;
}
