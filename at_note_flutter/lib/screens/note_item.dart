import 'package:at_onboarding_flutter/services/size_config.dart';
import 'package:flutter/material.dart';
import 'package:at_note_flutter/models/note_model.dart';

class NoteItem extends StatelessWidget {
  Note? note;
  int index;

  NoteItem(
    this.note,
    this.index,
  );

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      width: 150.toWidth,
      child: Card(
        elevation: 4.0,
        child: Container(
          margin: EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${note?.title}',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              SizedBox(
                height: 8,
              ),
              Container(
                height: 120.toHeight,
                child: note?.image != null
                    ? Image.memory(
                        note!.image!,
                        fit: BoxFit.fill,
                      )
                    : Container(
                        color: Colors.grey.shade400,
                      ),
              ),
              SizedBox(
                height: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
