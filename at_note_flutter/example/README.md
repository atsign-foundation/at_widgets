<img src="https://atsign.dev/assets/img/@developersmall.png?sanitize=true">

### Now for some internet optimism.

# at_note_flutter
A flutter example to create note with text and image.

## Getting Started

Demonstrates how to use the at_note_flutter plugin.

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