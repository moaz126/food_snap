import 'package:food_snap/data/database/database_helper.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection_container.config.dart';

final sl = GetIt.instance;
@InjectableInit(
  initializerName: 'initGetIt',
  asExtension: false,
)
Future<void> configureDependencies() async {
  await initGetIt(sl);
  await sl<DatabaseHelper>().init();
}
