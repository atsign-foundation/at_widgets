/// This widget is a list tile to display contacts selected for sharing
/// it takes [onlyRemovemethod] as a boolean with default value as [false]
/// if [true] trailing icon remains [close] icon [onAdd] method is disabled
/// all [isSelected] functionalities are disabled
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';

class ContactListTile extends StatefulWidget {
  final String? name;
  final String? atSign;
  final Widget? image;
  final Function? onAdd;
  final Function onRemove;
  final bool isSelected;
  final bool onlyRemoveMethod;
  final Function? onTileTap;
  final bool plainView;
  const ContactListTile(
      {Key? key,
      this.name,
      this.atSign,
      this.image,
      this.onAdd,
      required this.onRemove,
      this.isSelected = false,
      this.onlyRemoveMethod = false,
      this.plainView = false,
      this.onTileTap})
      : super(key: key);
  @override
  _ContactListTileState createState() => _ContactListTileState();
}

class _ContactListTileState extends State<ContactListTile> {
  bool selected = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        onTap: (widget.onlyRemoveMethod)
            ? () {
                widget.onTileTap!();
              }
            : () {
                setState(() {
                  selected = !selected;
                  !selected ? widget.onRemove() : widget.onAdd!();
                });
              },
        title: Text(
          widget.name!,
          style: TextStyle(
            color: Colors.black,
            fontSize: 14.toFont,
          ),
        ),
        subtitle: Text(
          widget.atSign!,
          style: TextStyle(
            // color: ColorConstants.fadedText,
            fontSize: 14.toFont,
          ),
        ),
        trailing: (widget.plainView)
            ? Container(
                height: 0,
                width: 0,
              )
            : (widget.isSelected)
                ? GestureDetector(
                    onTap: () {
                      widget.onRemove();
                    },
                    child: const Icon(
                      Icons.close,
                      color: Color(0xffA8A8A8),
                    ),
                  )
                : const Icon(
                    Icons.add,
                    color: Colors.black,
                  ),
        leading: Stack(
          children: <Widget>[
            Container(
              height: 40.toWidth,
              width: 40.toWidth,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: widget.image,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: (widget.onlyRemoveMethod)
                  ? Container()
                  : Container(
                      height: 15.toHeight,
                      width: 15.toHeight,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (widget.isSelected)
                              ? Colors.black
                              : Colors.transparent),
                      child: (widget.isSelected)
                          ? Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 10.toHeight,
                            )
                          : Container(),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
