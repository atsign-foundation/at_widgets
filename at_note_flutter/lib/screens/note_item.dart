import 'package:at_note_flutter/utils/note_utils.dart';
import 'package:at_onboarding_flutter/services/size_config.dart';
import 'package:flutter/material.dart';
import 'package:at_note_flutter/models/note_model.dart';

class NoteItem extends StatelessWidget {
  Note? note;
  int index;
  String? imageBase64;

  NoteItem(
    this.note,
    this.index,
    this.imageBase64,
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
                child: (imageBase64 != null && imageBase64!.isNotEmpty)
                    ? imageFromBase64String(imageBase64!)
                    : Container(
                        color: Colors.grey.shade400,
                      ),
                //  Image.asset('assets/images/ic_place_holder.png'),
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
