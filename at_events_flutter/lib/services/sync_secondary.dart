// // ignore: implementation_imports
// import 'package:at_commons/at_commons.dart';
// import 'package:at_events_flutter/utils/constants.dart';

// import 'at_event_notification_listener.dart';

// class SyncSecondary {
//   static final SyncSecondary _singleton = SyncSecondary._();
//   SyncSecondary._();

//   factory SyncSecondary() => _singleton;

//   // ignore: prefer_final_fields
//   List<SyncOperationDetails> _operations = [], _priorityOperations = [];

//   bool syncing = false;

//   /// Called to sync with secondary
//   Future<void> callSyncSecondary(
//     SyncOperation _syncOperation, {
//     AtKey atKey,
//     String notification,
//     OperationEnum operation,
//     bool isDedicated = MixedConstants.isDedicated,
//   }) async {
//     _operations.insert(
//       0,
//       SyncOperationDetails(
//         _syncOperation,
//         atKey: atKey,
//         notification: notification,
//         operation: operation,
//         isDedicated: isDedicated,
//       ),
//     );
//     if (syncing) {
//       return;
//     } else {
//       await _startSyncing();
//     }
//   }

//   void completePrioritySync(String _response, {Function afterSync}) {
//     _priorityOperations.add(SyncOperationDetails(SyncOperation.syncSecondary,
//         response: _response, afterSync: afterSync));
//     if (!syncing) {
//       _startSyncing();
//     }
//   }

//   Future<void> _startSyncing() async {
//     syncing = true;

//     while ((_operations.isNotEmpty) || (_priorityOperations.isNotEmpty)) {
//       if (_priorityOperations.isNotEmpty) {
//         var _tempPriorityOperations = _priorityOperations;
//         _priorityOperations = [];
//         _operations.removeWhere((_operation) =>
//             _operation.syncOperation == SyncOperation.syncSecondary);
//         await _syncSecondary();
//         _executeAfterSynced(_tempPriorityOperations);
//       }

//       if (_operations.isNotEmpty) {
//         var _syncOperationDetails = _operations.removeLast();
//         if (_syncOperationDetails.syncOperation == SyncOperation.notifyAll) {
//           await _notifyAllInSync(
//             _syncOperationDetails.atKey,
//             _syncOperationDetails.notification,
//             _syncOperationDetails.operation,
//           );
//         } else {
//           _operations.removeWhere((_operation) =>
//               _operation.syncOperation == SyncOperation.syncSecondary);
//           await _syncSecondary();
//         }
//       }
//     }

//     syncing = false;
//   }

//   void _executeAfterSynced(List<SyncOperationDetails> _tempPriorityOperations) {
//     _tempPriorityOperations.forEach((e) {
//       if (e.response != null) {
//         e.afterSync(e.response);
//       }
//     });
//   }

//   Future<void> _notifyAllInSync(
//       AtKey atKey, String notification, OperationEnum operation,
//       {bool isDedicated = MixedConstants.isDedicated}) async {
//     var notifyAllResult = await AtEventNotificationListener()
//         .atClientInstance
//         .notifyAll(atKey, notification, OperationEnum.update,
//             isDedicated: isDedicated);

//     print('notifyAllResult $notifyAllResult');
//   }

//   Future<void> _syncSecondary() async {
//     try {
//       var syncManager =
//           AtEventNotificationListener().atClientInstance.getSyncManager();
//       var isSynced = await syncManager.isInSync();
//       print('already synced: $isSynced');
//       if (isSynced is bool && isSynced) {
//       } else {
//         await syncManager.sync();
//         print('sync done');
//       }
//     } catch (e) {
//       print('error in _syncSecondary $e');
//     }
//   }
// }

// class SyncOperationDetails {
//   SyncOperation syncOperation;
//   AtKey atKey;
//   String notification;
//   OperationEnum operation;
//   bool isDedicated;
//   String response;
//   Function afterSync;

//   SyncOperationDetails(
//     this.syncOperation, {
//     this.response,
//     this.atKey,
//     this.notification,
//     this.operation,
//     this.isDedicated,
//     this.afterSync,
//   });
// }

// enum SyncOperation { syncSecondary, notifyAll }
