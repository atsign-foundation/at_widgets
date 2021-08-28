import 'package:at_follows_flutter/services/connections_service.dart';

class AtFollowsList {
  List<String?>? list = <String?>[];

  AtFollowsValue? _atKey;

  ///default it is `false`. Set `true` to make [list] as private.
  bool isPrivate = false;

  void create(AtFollowsValue atValue) {
    _atKey = atValue;
    list = atValue.value != null && atValue.value != '' && atValue.value != 'null'
        ? atValue.value.split(',')
        : <String?>[];
    list!.toSet().toList();
  }

  void add(String? value) {
    if (!list!.contains(value)) {
      list!.add(value);
    }
  }

  void remove(String? value) {
    if (list!.contains(value)) {
      list!.remove(value);
    }
  }

  void addAll(List<String> value) {
    for (String val in value) {
      add(val);
    }
  }

  void removeAll(List<String> value) {
    for (String val in value) {
      remove(val);
    }
  }

  bool contains(String? value) {
    return list!.contains(value);
  }

  @override
  String toString() {
    return list!.join(',');
  }

  set setKey(AtFollowsValue key) {
    _atKey = key;
  }

  AtFollowsValue? get getKey => _atKey;
}
