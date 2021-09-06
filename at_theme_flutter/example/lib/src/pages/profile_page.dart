import 'package:at_theme_flutter/at_theme_flutter.dart';
import 'package:example/main.dart';
import 'package:example/src/utils/color_constants.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String title;

  ProfilePage({
    Key? key,
    this.title = 'My Profile',
  }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme.of(context);
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: _onOpenSettingPressed,
            icon: Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                CircleAvatar(),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Atsign"),
                      Text(
                        "@atsign",
                        style: TextStyle(color: appTheme.secondaryColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              height: 56,
              margin: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                // color: appTheme.primary,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(width: 1, color: Colors.grey),
              ),
              child: TabBar(
                controller: tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    28.0,
                  ),
                  color: appTheme.primaryColor,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                enableFeedback: false,
                tabs: <Widget>[
                  Center(
                    child: Text("Tab One"),
                  ),
                  Center(
                    child: Text("Tab Two"),
                  ),
                  Center(
                    child: Text("Tab Three"),
                  ),
                ],
              ),
            ),
            Text(
              "Basic Details",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: appTheme.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Phone number",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF707070),
                    ),
                  ),
                  Text(
                    "+1 408 432 9012",
                    style: TextStyle(
                      fontSize: 18,
                      color: appTheme.primaryColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Divider(height: 1),
                  SizedBox(height: 8),
                  Text(
                    "Email Address",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF707070),
                    ),
                  ),
                  Text(
                    "atsign@atsign.com",
                    style: TextStyle(
                      fontSize: 18,
                      color: appTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _onOpenSettingPressed() {
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text("Default theme setting"),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).pop();
                    _openDefaultThemSetting();
                  },
                ),
                ListTile(
                  title: Text("Custom theme setting"),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).pop();
                    _openCustomThemSetting();
                  },
                ),
              ],
            ),
          );
        });
  }

  void _openDefaultThemSetting() {
    final appTheme = AppTheme.of(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ThemeSettingPage(
          currentAppTheme: appTheme,
          primaryColors: ColorConstants.primaryColors,
          onApplyPressed: (appTheme) {
            appThemeController.sink.add(appTheme);
          },
          onPreviewPressed: (appTheme) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => Theme(
                  data: appTheme.toThemeData(),
                  child: InheritedAppTheme(
                    theme: appTheme,
                    child: ProfilePage(
                      title: "Preview",
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openCustomThemSetting() {
    final appTheme = AppTheme.of(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ThemeSettingPage(
          currentAppTheme: appTheme,
          primaryColors: [
            Colors.red,
            Colors.redAccent,
            Colors.green,
            Colors.greenAccent,
            Colors.lightGreen,
            Colors.lightGreenAccent,
            Colors.blue,
            Colors.blueAccent,
            Colors.lightBlue,
            Colors.lightBlueAccent,
            Colors.purple,
            Colors.purpleAccent,
            Colors.orange,
            Colors.orangeAccent,
            Colors.deepOrange,
            Colors.deepOrangeAccent,
            Colors.yellow,
            Colors.yellowAccent,
            Colors.teal,
            Colors.tealAccent,
          ],
          onApplyPressed: (appTheme) {
            appThemeController.sink.add(appTheme);
          },
        ),
      ),
    );
  }
}
