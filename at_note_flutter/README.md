<img src="https://atsign.dev/assets/img/@developersmall.png?sanitize=true">

### Now for some internet optimism.

# at_note_flutter

A flutter plugin to create note with text and image.

## Getting Started

This plugin provides a note widget.

### Initialising
The note service needs to be initialised. It is expected that the app will first create an AtClientService instance using the preferences and then use it to initialise the note service.

```
initializeNoteService(
        clientSdkService.atClientServiceInstance.atClient, activeAtSign,
        rootDomain: MixedConstants.ROOT_DOMAIN);
```

### Sample Usage

Navigate to notes screen
```
TextButton(
   onPressed: () async {
      await Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => NoteListScreen(
               activeAtSign!,
            ),
         ),
       );
   },
   child: Text(
       'Show Notes Screen',
   ),
),
```