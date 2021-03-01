import 'package:at_commons/at_commons.dart';
import 'package:at_follows_flutter/services/connections_service.dart';

class AtFollowsList {
  List<String> list;

  AtKey _atKey;

  ///default it is `false`. Set `true` to make [list] as private.
  bool isPrivate = false;

  create(AtFollowsValue atValue) {
    _atKey = atValue.atKey;
    list = atValue.value != null && atValue.value != ''
        ? atValue.value.split(',')
        : [];
    list.toSet().toList();
    // return atsignList;
  }

  add(String value) {
    if (!list.contains(value)) {
      list.add(value);
    }
  }

  remove(String value) {
    if (list.contains(value)) {
      list.remove(value);
    }
  }

  addAll(List<String> value) {
    for (String val in value) {
      this.add(val);
    }
  }

  removeAll(List<String> value) {
    for (String val in value) {
      this.remove(val);
    }
  }

  contains(String value) {
    return list.contains(value);
  }

  toString() {
    return list.join(',');
  }

  set setKey(AtKey key) {
    this._atKey = key;
  }

  get getKey => _atKey;
}
