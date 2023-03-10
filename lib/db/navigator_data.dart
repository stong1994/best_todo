import '../model/navigator.dart';
import 'from_sqlite.dart';

abstract class NavigatorData {
  Future<List<Navigator>> fetchNavigators();
  Future<Navigator> addNavigator(Navigator navigator);
  Future<Navigator> getNavigator(String id);
  Future<Navigator> updateNavigator(Navigator navigator);
  Future deleteNavigator(Navigator navigator);
}

NavigatorData getNavigatorData() {
  return SqliteData();
}
