import 'package:shared_preferences/shared_preferences.dart';
import 'package:thefocusapp/data/persistence/KeyValueStorage.dart';

class LocalKeyValueStorage implements KeyValueStorage {

  @override
  void save(String key, List<String> values) async {
    final sharedPref = await SharedPreferences.getInstance();
    sharedPref.setStringList(key, values);
  }


  @override
  void addToList(String key, String value) async {
    final sharedPref = await SharedPreferences.getInstance();
    final existingValues = sharedPref.getStringList(key);
    if (existingValues != null) {
      existingValues.add(value);
      sharedPref.setStringList(key, existingValues);
    } else {
      final newList = List<String>();
      newList.add(value);
      sharedPref.setStringList(key, newList);
    }
  }

  @override
  Future<List<String>> load(String key) async {
    final sharedPref = await SharedPreferences.getInstance();
    return sharedPref.getStringList(key);
  }
}