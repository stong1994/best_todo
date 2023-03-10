import '../model/scene.dart';
import 'from_sqlite.dart';

abstract class SceneData {
  Future<List<Scene>> fetchScenes();
  Future<Scene> addScene(Scene navigator);
  Future<Scene> getScene(String id);
  Future<Scene> updateScene(Scene navigator);
  Future deleteScene(Scene navigator);
}

SceneData getSceneData() {
  return SqliteData();
}
