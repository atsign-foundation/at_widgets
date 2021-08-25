import 'package:at_note_flutter/models/note_model.dart';
import 'package:at_note_flutter/reorder/reorderables.dart';
import 'package:at_note_flutter/services/note_service.dart';
import 'package:at_note_flutter/utils/note_utils.dart';
import 'package:at_note_flutter/utils/strings.dart';
import 'package:at_onboarding_flutter/services/size_config.dart';
import 'package:flutter/material.dart';

import 'edit_note_screen.dart';
import 'note_item.dart';

class NoteListScreen extends StatefulWidget {
  String? activeAtSign;

  NoteListScreen(this.activeAtSign);

  @override
  _NoteListScreenScreenState createState() => _NoteListScreenScreenState();
}

class _NoteListScreenScreenState extends State<NoteListScreen> {
  late NoteService noteService;

  @override
  void initState() {
    noteService = NoteService();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      await noteService.getNotes(
        atsign: widget.activeAtSign,
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () async {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          Strings.noteList,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.check_sharp,
              color: Colors.black,
            ),
            onPressed: () async {
              bool isSuccess = await noteService.updateNotes();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: isSuccess ? Colors.green : Colors.red,
                  content: Text(isSuccess ? Strings.updateNoteSuccess : Strings.updateNoteFailed),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: new FloatingActionButton(
        elevation: 0.0,
        child: new Icon(Icons.add),
        backgroundColor: Colors.black,
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EditNoteScreen(
                activeAtSign: widget.activeAtSign,
              ),
            ),
          );
        },
      ),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(16.toWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.toFont),
              child: TextField(
                textInputAction: TextInputAction.search,
                onChanged: (text) async {
                  await noteService.searchNote(text);
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: Strings.searchNote,
                  hintStyle: TextStyle(
                    fontSize: 16.toFont,
                    color: Color(0xFF868A92),
                  ),
                  filled: true,
                  fillColor: Color(0xFFF7F7FF),
                  contentPadding: EdgeInsets.symmetric(vertical: 15.toHeight),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Color(0xFF868A92),
                    size: 20.toFont,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 16.toHeight,
            ),
            Expanded(
              child: StreamBuilder<List<Note>>(
                stream: noteService.noteStream,
                initialData: noteService.notes,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if ((snapshot.data == null ||
                      snapshot.data!.isEmpty)) {
                    return Center(
                      child: Text(Strings.noNotesFound),
                    );
                  } else {
                    return ReorderableWrap(
                      needsLongPressDraggable: true,
                      spacing: 8.0,
                      runSpacing: 8.0,
                      padding: EdgeInsets.all(8),
                      onReorder: (int oldIndex, int newIndex) async {
                        print(
                            'onReorder = ${DateTime.now().toString().substring(5, 22)}');
                        await noteService.reOrderNote(oldIndex, newIndex);
                      },
                      onNoReorder: (int index) {
                        print(
                            '${DateTime.now().toString().substring(5, 22)} reorder cancelled. index:$index');
                      },
                      onReorderStarted: (int index) {
                        print(
                            '${DateTime.now().toString().substring(5, 22)} reorder started: index:$index');
                      },
                      children: snapshot.data!.map((note) {

                        return GestureDetector(
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => EditNoteScreen(
                                  note: note,
                                  index: snapshot.data!.indexOf(note),
                                  activeAtSign: widget.activeAtSign,
                                  isEditNote: true,
                                ),
                              ),
                            );
                          },
                          child: NoteItem(
                            note,
                            snapshot.data!.indexOf(note),
                          ),
                        );
                      }).toList(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
