import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:at_note_flutter/models/note_model.dart';
import 'package:at_note_flutter/models/item_model.dart';
import 'package:at_note_flutter/services/note_service.dart';
import 'package:at_note_flutter/utils/note_utils.dart';
import 'package:at_note_flutter/utils/init_note_service.dart';
import 'package:at_note_flutter/utils/strings.dart';
import 'package:at_onboarding_flutter/services/size_config.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

class EditNoteScreen extends StatefulWidget {
  Note? note;
  String? activeAtSign;
  int index;
  bool isEditNote;

  EditNoteScreen({
    this.note,
    this.index = -1,
    this.activeAtSign,
    this.isEditNote = false,
  });

  @override
  _EditNoteScreenScreenState createState() => _EditNoteScreenScreenState();
}

class _EditNoteScreenScreenState extends State<EditNoteScreen> {
  late NoteService noteService;

  TextEditingController titleController = TextEditingController(text: '');
  List<TextEditingController> itemControllers = [];

  List<Item> items = [];
  List<Item> textItems = [];
  List<Item> imageItems = [];

  bool isLoading = false;

  @override
  void initState() {
    noteService = NoteService();
    titleController = TextEditingController(text: widget.note?.title ?? '');

    int time = DateTime
        .now()
        .millisecondsSinceEpoch;

    items = widget.note?.items ??
        [
          Item(
            time: time,
            type: 'text',
            value: '',
          ),
        ];
    textItems = widget.note?.items
        ?.where((element) => element.type == 'text')
        ?.toList() ??
        [
          Item(
            time: time,
            type: 'text',
            value: '',
          ),
        ];
    imageItems = widget.note?.items
        ?.where((element) => element.type == 'image')
        ?.toList() ??
        [];

    for (var item in textItems) {
      itemControllers.add(
        TextEditingController(text: item.value),
      );
    }

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
          widget.isEditNote ? Strings.editNote : Strings.addNote,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Visibility(
            visible: widget.isEditNote,
            child: IconButton(
              icon: Icon(
                Icons.delete,
                color: Colors.black,
              ),
              onPressed: () async {
                showConfirmDialog(
                  context,
                  Strings.confirmDeleteNote,
                  onConfirmed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    bool isSuccess = await noteService.removeNote(widget.index);
                    setState(() {
                      isLoading = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: Duration(seconds: 3),
                        backgroundColor: isSuccess ? Colors.green : Colors.red,
                        content: Text(isSuccess
                            ? Strings.deleteNoteSuccess
                            : Strings.deleteNoteFailed),
                      ),
                    );
                    Future.delayed(Duration(milliseconds: 1000), () {});
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.check_outlined,
              color: Colors.black,
            ),
            onPressed: () async {
              setState(() {
                isLoading = true;
              });
              for (int i = 0; i < items.length; i++) {
                if (items[i].type == 'image' && items[i].showType == 'path') {
                  var name = p.basename(items[i].value!);
                  String keyImage =
                  await noteService.addImage(name, items[i].image!);
                  items[i].value = keyImage;
                  items[i].showType = 'base64';
                }
              }
              if (widget.isEditNote) {
                Note note = widget.note!;
                note.items = items;
                note.title = titleController.text;

                var isSuccess = await noteService.editNote(
                  note,
                  widget.index,
                );
                setState(() {
                  isLoading = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: Duration(seconds: 3),
                    backgroundColor: isSuccess ? Colors.green : Colors.red,
                    content: Text(isSuccess
                        ? Strings.editNoteSuccess
                        : Strings.editNoteFailed),
                  ),
                );
              } else {
                var isSuccess = await noteService.addNote(
                  Note(
                    atSign: widget.activeAtSign,
                    time: DateTime
                        .now()
                        .millisecondsSinceEpoch,
                    title: titleController.text,
                    items: items,
                  ),
                );
                setState(() {
                  isLoading = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: Duration(seconds: 3),
                    backgroundColor: isSuccess ? Colors.green : Colors.red,
                    content: Text(isSuccess
                        ? Strings.addNoteSuccess
                        : Strings.addNoteFailed),
                  ),
                );
              }
              Future.delayed(Duration(milliseconds: 1000), () {});
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: 16.toHeight,
              bottom: 16.toHeight,
              left: 16.toWidth,
              right: 8.toWidth,
            ),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    hintText: Strings.title,
                  ),
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                  onChanged: (text) {},
                ),
                SizedBox(
                  height: 8.toHeight,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      if (items[i].type == 'text') {
                        int indexInItems = textItems.indexWhere(
                                (element) => element.time == items[i].time);
                        return Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: itemControllers[indexInItems],
                                decoration: new InputDecoration(
                                    border: InputBorder.none,
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.blue,
                                      ),
                                    ),
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    hintText: Strings.enterNote),
                                onChanged: (text) {
                                  textItems[textItems.indexOf(items[i])].value =
                                      text;
                                  items[i].value = text;
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.cancel,
                                color: Colors.black54,
                                size: 20,
                              ),
                              onPressed: () async {
                                itemControllers
                                    .removeAt(textItems.indexOf(items[i]));
                                textItems.removeAt(textItems.indexOf(items[i]));
                                items.removeAt(i);
                                setState(() {});
                              },
                            ),
                          ],
                        );
                      } else {
                        return Stack(
                          children: [
                            Container(
                              height: 300,
                              padding:
                              EdgeInsets.symmetric(vertical: 8.toHeight),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                image: (items[i].value != null &&
                                    items[i].value!.isNotEmpty)
                                    ? DecorationImage(
                                  image: Image
                                      .memory(
                                    items[i].image!,
                                    fit: BoxFit.fill,
                                  )
                                      .image,
                                  fit: BoxFit.fill,
                                )
                                    : null,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: IconButton(
                                  icon: Icon(
                                    Icons.cancel,
                                    color: Colors.black54,
                                    size: 24,
                                  ),
                                  onPressed: () async {
                                    imageItems.removeWhere((element) {
                                      for (var item in items) {
                                        if (element.time == item.time) {
                                          return true;
                                        }
                                      }
                                      return false;
                                    });
                                    items.removeAt(i);
                                    setState(() {});
                                  }),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FloatingActionButton(
                      heroTag: 'addText',
                      elevation: 0.0,
                      child: Text(
                        'A',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white),
                      ),
                      backgroundColor: Colors.black,
                      onPressed: () {
                        addText();
                      },
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    FloatingActionButton(
                      heroTag: 'addImage',
                      elevation: 0.0,
                      child: Icon(
                        Icons.photo,
                        color: Colors.white,
                      ),
                      backgroundColor: Colors.black,
                      onPressed: () async {
                        showBottomSheetDialog(
                          context,
                          photoCallback: () async {
                            var image = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);
                            Navigator.of(context).pop();
                            if (image?.path != null) {
                              var compressedImageData = await noteService
                                  .cropImage(context, image!.path);
                              if (compressedImageData != null) {
                                addImage(image!.path, compressedImageData);
                              }
                            }
                          },
                          cameraCallback: () async {
                            var image = await ImagePicker()
                                .pickImage(source: ImageSource.camera);
                            Navigator.of(context).pop();
                            if (image?.path != null) {
                              var compressedImageData = await noteService
                                  .cropImage(context, image!.path);
                              if (compressedImageData != null) {
                                addImage(image!.path, compressedImageData);
                              }
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 16.toHeight,
                ),
              ],
            ),
          ),
          Visibility(
            visible: isLoading,
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void addText() {
    var time = DateTime
        .now()
        .millisecondsSinceEpoch;
    itemControllers.add(TextEditingController(text: ''));
    textItems.add(Item(
      type: 'text',
      time: time,
      value: '',
    ));
    items.add(Item(
      type: 'text',
      time: time,
      value: '',
    ));
    setState(() {});
  }

  void addImage(String path, Uint8List uInt8list) async {
    var time = DateTime
        .now()
        .millisecondsSinceEpoch;
    items.add(Item(
      type: 'image',
      time: time,
      value: path,
      showType: 'path',
      image: uInt8list,
    ));
    imageItems.add(Item(
      type: 'image',
      time: time,
      value: path,
      showType: 'path',
      image: uInt8list,
    ));
    setState(() {});
  }
}
