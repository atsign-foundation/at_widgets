import 'package:at_theme_flutter/at_theme_flutter.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';

class ThemeModeCard extends StatelessWidget {
  final Color primaryColor;
  final Brightness brightness;
  final bool isSelected;
  final VoidCallback? onPressed;

  const ThemeModeCard({
    Key? key,
    required this.primaryColor,
    required this.brightness,
    required this.isSelected,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.from(
      primaryColor: primaryColor,
      brightness: brightness,
    );
    return ElevatedButton(
      onPressed: onPressed,
      child: Container(
        width: double.infinity,
        height: 166.toHeight,
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 10.toHeight),
                Container(
                  height: 40.toHeight,
                  color: primaryColor.withOpacity(0.2),
                  margin: EdgeInsets.symmetric(horizontal: 10),
                ),
                SizedBox(height: 10),
                Container(
                  height: 40.toHeight,
                  color: primaryColor.withOpacity(0.2),
                  margin: EdgeInsets.symmetric(horizontal: 10),
                ),
                SizedBox(height: 10.toHeight),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    onPressed: null,
                    child: Container(),
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(primaryColor),
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                    ),
                  ),
                ),
              ],
            ),
            Visibility(
              visible: isSelected,
              child: Center(
                child: Container(
                  height: 30.toHeight,
                  width: 30.toHeight,
                  child: Icon(Icons.check_rounded, color: primaryColor),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.all(Radius.circular(15.toHeight)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        backgroundColor:
            MaterialStateProperty.all<Color>(theme.backgroundColor),
        padding: MaterialStateProperty.all(EdgeInsets.zero),
      ),
    );
  }
}
