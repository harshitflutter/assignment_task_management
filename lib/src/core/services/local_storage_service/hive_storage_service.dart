import 'package:hive_flutter/hive_flutter.dart';

class HiveStorageService {
  HiveStorageService? _instance;

  HiveStorageService? get instance {
    _instance ??= HiveStorageService();
    return _instance;
  }

  ///initialize the hive box
  Future<void> init({bool isTest = false}) async {
    if (isTest) {
      Hive.init('HIVE_TEST');
      await Hive.openBox<dynamic>('task_management');
    } else {
      await Hive.initFlutter();
      await Hive.openBox<dynamic>('task_management');
    }
  }

  /// Returns the box in which the data is stored.
  Box _getBox() => Hive.box<dynamic>('task_management');

  ///To get String Value
  String getStringValue(String key) {
    var box = _getBox();
    var value = box.get(key) as String? ?? '';
    return value;
  }

  ///To get Int Value
  int getIntValue(String key) {
    var box = _getBox();
    var defaultValue = 0;
    var value = box.get(key, defaultValue: defaultValue) as int;
    return value;
  }

  ///to save a value
  void saveValue(dynamic key, dynamic value) {
    _getBox().put(key, value);
  }

  // to get bool value
  bool getBoolValue(String key) {
    var box = _getBox();
    var defaultValue = false;
    var value = box.get(key, defaultValue: defaultValue) as bool;
    return value;
  }

  // to get List value
  List<dynamic> getListValue(String key) {
    var box = _getBox();
    var defaultValue = false;
    var value = box.get(key, defaultValue: defaultValue) as List;
    return value;
  }

  ///to clear data
  void clearData(dynamic key) {
    _getBox().delete(key);
  }

  /// clear all data
  Future<void> clearBox() async {
    await _getBox().clear();
  }
}
