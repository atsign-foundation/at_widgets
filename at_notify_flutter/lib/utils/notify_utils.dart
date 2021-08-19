import 'package:at_notify_flutter/models/notify_model.dart';
import 'package:at_notify_flutter/services/notify_service.dart';
import 'package:flutter/material.dart';

enum NotifyEnum {
  notify,
  notifyAll,
  notifyList,
}

NotifyService _notifyService = NotifyService();

notify(
  BuildContext context,
  String? atSign,
  String? sendToAtSign,
  String? message,
) {
  _notifyService.setSendToAtSign(sendToAtSign);
  _notifyService.addNotify(
    Notify(
      time: DateTime.now().millisecondsSinceEpoch,
      atSign: atSign,
      message: message,
    ),
    notifyType: NotifyEnum.notify,
  );
}

notifyAll(
    BuildContext context,
    String? atSign,
    String? sendToAtSign,
    String? message,
    ) {
  _notifyService.setSendToAtSign(sendToAtSign);
  _notifyService.addNotify(
    Notify(
      time: DateTime.now().millisecondsSinceEpoch,
      atSign: atSign,
      message: message,
    ),
    notifyType: NotifyEnum.notifyAll,
  );
}

notifyList(
    BuildContext context,
    String? atSign,
    String? sendToAtSign,
    String? message,
    ) {
  _notifyService.setSendToAtSign(sendToAtSign);
  _notifyService.addNotify(
    Notify(
      time: DateTime.now().millisecondsSinceEpoch,
      atSign: atSign,
      message: message,
    ),
    notifyType: NotifyEnum.notifyList,
  );
}