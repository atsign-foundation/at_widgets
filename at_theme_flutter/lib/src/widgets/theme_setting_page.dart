import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_theme_flutter/at_theme_flutter.dart';
import 'package:at_theme_flutter/src/widgets/color_card.dart';
import 'package:at_theme_flutter/src/widgets/theme_mode_card.dart';
import 'package:flutter/material.dart';

class ThemeSettingPage extends StatefulWidget {
  final String title;
  final AppTheme currentAppTheme;
  final List<Color> primaryColors;
  final ValueChanged<AppTheme>? onPreviewPressed;
  final ValueChanged<AppTheme>? onApplyPressed;

  const ThemeSettingPage({
    Key? key,
    this.title = 'Theme settings',
    required this.currentAppTheme,
    required this.primaryColors,
    this.onPreviewPressed,
    this.onApplyPressed,
  })  : assert(primaryColors.length > 0),
        super(key: key);

  @override
  _ThemeSettingPageState createState() => _ThemeSettingPageState();
}

class _ThemeSettingPageState extends State<ThemeSettingPage> {
  late AppTheme _appTheme;

  @override
  void initState() {
    _appTheme = widget.currentAppTheme.copyWith();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Theme(
      data: _appTheme.toThemeData(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          elevation: 0,
        ),
        body: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Theme",
                style: TextStyle()
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 15.toFont),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    flex: 1,
                    child: ThemeModeCard(
                      primaryColor: _appTheme.primaryColor,
                      brightness: Brightness.light,
                      isSelected: _appTheme.brightness == Brightness.light,
                      onPressed: () {
                        setState(() {
                          _appTheme = AppTheme.from(
                            primaryColor: _appTheme.primaryColor,
                            brightness: Brightness.light,
                          );
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: ThemeModeCard(
                      primaryColor: _appTheme.primaryColor,
                      brightness: Brightness.dark,
                      isSelected: _appTheme.brightness == Brightness.dark,
                      onPressed: () {
                        setState(() {
                          _appTheme = AppTheme.from(
                            primaryColor: _appTheme.primaryColor,
                            brightness: Brightness.dark,
                          );
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),
              Text(
                "Colour",
                style: TextStyle()
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 15.toFont),
              ),
              Expanded(
                child: Container(
                  child: GridView.count(
                    crossAxisCount: 4,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: List.generate(
                      widget.primaryColors.length,
                      (index) {
                        return ColorCard(
                          color: widget.primaryColors[index],
                          isSelected: widget.primaryColors[index] ==
                              _appTheme.primaryColor,
                          onPressed: () {
                            setState(() {
                              _appTheme = AppTheme.from(
                                primaryColor: widget.primaryColors[index],
                                brightness: _appTheme.brightness,
                              );
                            });
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (widget.onPreviewPressed != null)
                    ElevatedButton(
                      onPressed: () {
                        widget.onPreviewPressed?.call(_appTheme);
                      },
                      child: Container(
                        width: 80.toWidth,
                        padding: EdgeInsets.all(10),
                        child: Center(
                          child: Text(
                            "Preview",
                            style: TextStyle(
                                color: Colors.white, fontSize: 15.toFont),
                          ),
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            _appTheme.primaryColor),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: () {
                      widget.onApplyPressed?.call(_appTheme);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 80.toWidth,
                      padding: EdgeInsets.all(10),
                      child: Center(
                        child: Text(
                          "Apply",
                          style: TextStyle(
                              color: Colors.white, fontSize: 15.toFont),
                        ),
                      ),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          _appTheme.primaryColor),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }
}
