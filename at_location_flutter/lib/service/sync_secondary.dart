// ignore: implementation_imports
import 'package:at_client/src/manager/sync_manager.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_location_flutter/utils/constants/constants.dart';
import 'at_location_notification_listener.dart';

/// A class to manage all the server calls.
/// [SyncSecondary] makes sure that server calls are not interfering with each other.
///
/// [callSyncSecondary] syncs to secondary or calls [notifyAll] based on [_syncOperation].
///
///
class SyncSecondary {
  static final SyncSecondary _singleton = SyncSecondary._();
  SyncSecondary._();

  factory SyncSecondary() => _singleton;

  // ignore: prefer_final_fields
  List<SyncOperationDetails> _operations = <SyncOperationDetails>[], _priorityOperations = <SyncOperationDetails>[];

  bool syncing = false;

  /// Called to sync with secondary
  /// [_syncOperation] either sync to secondary or notifyAll
  /// [atKey], [notification], [operation] needed for notifyAll
  Future<void> callSyncSecondary(
    SyncOperation _syncOperation, {
    AtKey? atKey,
    String? notification,
    OperationEnum? operation,
    bool isDedicated = MixedConstants.isDedicated,
  }) async {
    _operations.insert(
      0,
      SyncOperationDetails(
        _syncOperation,
        atKey: atKey,
        notification: notification,
        operation: operation,
        isDedicated: isDedicated,
      ),
    );
    if (syncing) {
      return;
    } else {
      await _startSyncing();
    }
  }

  /// Called to sync in priority
  /// [afterSync] called after sync is complete
  /// [_response], passed as a parameter to [afterSync]
  void completePrioritySync(String _response, {Function? afterSync}) {
    _priorityOperations
        .add(SyncOperationDetails(SyncOperation.syncSecondary, response: _response, afterSync: afterSync));
    if (!syncing) {
      _startSyncing();
    }
  }

  Future<void> _startSyncing() async {
    syncing = true;

    while ((_operations.isNotEmpty) || (_priorityOperations.isNotEmpty)) {
      if (_priorityOperations.isNotEmpty) {
        List<SyncOperationDetails> _tempPriorityOperations = _priorityOperations;
        _priorityOperations = <SyncOperationDetails>[];
        _operations
            .removeWhere((SyncOperationDetails _operation) => _operation.syncOperation == SyncOperation.syncSecondary);
        await _syncSecondary();
        _executeAfterSynced(_tempPriorityOperations);
      }

      if (_operations.isNotEmpty) {
        SyncOperationDetails _syncOperationDetails = _operations.removeLast();
        if (_syncOperationDetails.syncOperation == SyncOperation.notifyAll) {
          await _notifyAllInSync(
            _syncOperationDetails.atKey!,
            _syncOperationDetails.notification!,
            _syncOperationDetails.operation!,
          );
        } else {
          _operations.removeWhere(
              (SyncOperationDetails _operation) => _operation.syncOperation == SyncOperation.syncSecondary);
          await _syncSecondary();
        }
      }
    }

    syncing = false;
  }

  void _executeAfterSynced(List<SyncOperationDetails> _tempPriorityOperations) {
    for (SyncOperationDetails e in _tempPriorityOperations) {
      if ((e.response != null) && (e.afterSync != null)) {
        e.afterSync!(e.response);
      }
    }
  }

  Future<void> _notifyAllInSync(AtKey atKey, String notification, OperationEnum operation,
      {bool isDedicated = MixedConstants.isDedicated}) async {
    String notifyAllResult = await AtLocationNotificationListener()
        .atClientInstance!
        .notifyAll(atKey, notification, OperationEnum.update, isDedicated: isDedicated);

    print('notifyAllResult $notifyAllResult');
  }

  Future<void> _syncSecondary() async {
    try {
      SyncManager? syncManager = AtLocationNotificationListener().atClientInstance!.getSyncManager();
      bool isSynced = await syncManager!.isInSync();
      print('already synced: $isSynced');
      if (isSynced is bool && isSynced) {
      } else {
        await syncManager.sync();
        print('sync done');
      }
    } catch (e) {
      print('error in _syncSecondary $e');
    }
  }
}

class SyncOperationDetails {
  SyncOperation syncOperation;
  AtKey? atKey;
  String? notification;
  OperationEnum? operation;
  bool? isDedicated;
  String? response;
  Function? afterSync;

  SyncOperationDetails(
    this.syncOperation, {
    this.response,
    this.atKey,
    this.notification,
    this.operation,
    this.isDedicated,
    this.afterSync,
  });
}

enum SyncOperation { syncSecondary, notifyAll }
