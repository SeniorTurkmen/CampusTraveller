import 'package:get_it/get_it.dart';

import 'user_notifiers.dart';

var getIt = GetIt.I;

registerLocator() {
  getIt.registerLazySingleton<UserNotifier>(() => UserNotifier());
}
