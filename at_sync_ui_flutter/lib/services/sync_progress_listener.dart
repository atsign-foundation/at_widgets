import 'package:at_client/at_client.dart';
import 'package:at_sync_ui_flutter/services/at_sync_ui_services.dart';

class AtSyncProgressListener extends SyncProgressListener {
  @override
  void onSyncProgressEvent(SyncProgress syncProgress) {
    if (AtSyncUIService().syncProgressCallback != null) {
      AtSyncUIService().syncProgressCallback!(syncProgress);
    }
  }
}
