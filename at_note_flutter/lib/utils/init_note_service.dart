import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_note_flutter/services/note_service.dart';
// ignore: import_of_legacy_library_into_null_safe

/// The note service needs to be initialised.
/// It is expected that the app will first create an AtClientService instance using the preferences
/// and then use it to initialise the note service.
void initializeNoteService(AtClientImpl atClientInstance, String currentAtSign,
    {rootDomain = 'root.atsign.wtf', rootPort = 64}) {
  NoteService()
      .initNoteService(atClientInstance, currentAtSign, rootDomain, rootPort);
}

void disposeNoteControllers() {
  NoteService().disposeControllers();
}
