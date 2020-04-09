abstract class KeyValueStorage {
  void save(String key, List<String> values) async {
    throw Exception("Stub!");
  }

  void addToList(String key, String value) {
    throw Exception("Stub!");
  }

  Future<List<String>> load (String key) async {
    throw Exception("Stub!");
  }
}