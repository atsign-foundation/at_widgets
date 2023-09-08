import 'package:at_enrollment_app/screen/enrollment_screen.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String appBarTitle = 'Home Page';
  final List<Widget> _widgetList = [
    _HomePageWidget(),
    const EnrollmentWidget(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      body: Container(
        child: _widgetList[_selectedIndex],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFFf4533d),
                ),
                child: Align(
                  alignment: FractionalOffset.bottomLeft,
                  child: Text(
                    'Menu',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: Colors.white),
                  ),
                )),
            ListTile(
              title: const Text('Home', style: TextStyle(fontSize: 17)),
              selected: true,
              onTap: () {
                setState(() {
                  appBarTitle = 'Home Page';
                  _selectedIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            Column(
              children: <Widget>[
                ExpansionTile(
                  title:
                      const Text('Enrollment', style: TextStyle(fontSize: 17)),
                  children: [
                    ListTile(
                      title: const Text('Enrollments',
                          style: TextStyle(fontSize: 15)),
                      selected: true,
                      onTap: () {
                        setState(() {
                          appBarTitle = 'Enrollments';
                          _selectedIndex = 1;
                        });
                        context.goNamed('Enrollments');
                      },
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _HomePageWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String? currentAtSign =
        AtClientManager.getInstance().atClient.getCurrentAtSign();
    return Center(
      child: Text(
        'Welcome $currentAtSign',
        textAlign: TextAlign.center,
        style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Color(0xFFf4533d)),
      ),
    );
  }
}
