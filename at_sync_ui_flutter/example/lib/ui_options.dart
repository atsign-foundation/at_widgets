import 'dart:developer';

import 'package:at_sync_ui_flutter/at_sync_material.dart' as material;
import 'package:at_sync_ui_flutter/at_sync_cupertino.dart' as cupertino;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:at_sync_ui_flutter/at_sync_ui.dart';

const double _kNormalPadding = 16;
const double _kSmallPadding = 8;
const double _kLargePadding = 32;
const Color _kPrimaryColor = Color(0xFFf4533d);

class UIOptions extends StatelessWidget {
  const UIOptions({Key? key}) : super(key: key);
  static final navKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    AtSyncUI.instance.setAppNavigatorKey(navKey);
    AtSyncUI.instance.configTheme(
      primaryColor: Colors.red,
      backgroundColor: Colors.yellow,
      labelColor: Colors.green,
      style: AtSyncUIStyle.material,
    );
    AtSyncUI.instance.setupController(controller: AtSyncUIController());
    return MaterialApp(
      title: 'AtSync Widget',
      navigatorKey: navKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  double progress = 0.0;

  Color _indicatorColor = _kPrimaryColor;

  late Animation<double> animation;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(duration: const Duration(seconds: 5), vsync: this);
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(controller)
      ..addListener(() {
        setState(() {
          progress = animation.value;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AtSync Widget'),
        actions: [
          material.AtSyncButton(
            isLoading: isLoading,
            syncIndicatorColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.android),
              onPressed: _startLoading,
            ),
          ),
          cupertino.AtSyncButton(
            isLoading: isLoading,
            syncIndicatorColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.phone_iphone),
              onPressed: _startLoading,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: _showColorPicker,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: _kNormalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: _kNormalPadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Text('Material',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Cupertino',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: _kNormalPadding),
              const Text('AtSyncIcon'),
              const SizedBox(height: _kSmallPadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  material.AtSyncIndicator(
                    color: _indicatorColor,
                  ),
                  cupertino.AtSyncIndicator(
                    color: _indicatorColor,
                  ),
                ],
              ),
              const SizedBox(height: _kLargePadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  material.AtSyncIndicator(
                    radius: 24,
                    color: _indicatorColor,
                  ),
                  cupertino.AtSyncIndicator(
                    radius: 24,
                    color: _indicatorColor,
                  ),
                ],
              ),
              const SizedBox(height: _kLargePadding),
              const Text('AtSyncIconButton'),
              const SizedBox(height: _kSmallPadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  material.AtSyncButton(
                    isLoading: isLoading,
                    syncIndicatorColor: _indicatorColor,
                    child: ElevatedButton(
                      child: const Text('Material'),
                      onPressed: _startLoading,
                    ),
                  ),
                  cupertino.AtSyncButton(
                    isLoading: isLoading,
                    syncIndicatorColor: _indicatorColor,
                    child: CupertinoButton(
                      child: const Text('Cupertino'),
                      color: Colors.grey,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      onPressed: _startLoading,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: _kLargePadding),
              const Text('AtSyncCircularProgressIndicator'),
              const SizedBox(height: _kSmallPadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  material.AtSyncIndicator(
                    value: progress,
                    color: _indicatorColor,
                  ),
                  cupertino.AtSyncIndicator(
                    value: progress,
                    color: _indicatorColor,
                  ),
                ],
              ),
              const SizedBox(height: _kLargePadding),
              const Text('AtSyncLinearProgressIndicator'),
              const SizedBox(height: _kSmallPadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: material.AtSyncLinearProgressIndicator(
                      color: _indicatorColor,
                    ),
                  ),
                  const SizedBox(width: _kSmallPadding),
                  Expanded(
                    child: cupertino.AtSyncLinearProgressIndicator(
                      color: _indicatorColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: _kSmallPadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    flex: 1,
                    child: material.AtSyncLinearProgressIndicator(
                      value: progress,
                      color: _indicatorColor,
                    ),
                  ),
                  const SizedBox(width: _kSmallPadding),
                  Expanded(
                    flex: 1,
                    child: cupertino.AtSyncLinearProgressIndicator(
                      progress: progress,
                      minHeight: 20,
                      color: _indicatorColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: _kLargePadding),
              const Text('AtSyncText'),
              const SizedBox(height: _kSmallPadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    flex: 1,
                    child: material.AtSyncText(
                      value: progress,
                      child: const Text('completed'),
                      indicatorColor: _indicatorColor,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: cupertino.AtSyncText(
                      value: progress,
                      child: const Text('completed'),
                      indicatorColor: _indicatorColor,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    child: const Text('Material Dialog'),
                    onPressed: _startMaterialDialog,
                  ),
                  TextButton(
                    child: const Text('Cupertino Dialog'),
                    onPressed: _startCupertinoDialog,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    child: const Text('Material SnackBar'),
                    onPressed: _startMaterialSnackBar,
                  ),
                  TextButton(
                    child: const Text('Cupertino SnackBar'),
                    onPressed: _startCupertinoSnackBar,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    child: const Text('Loading Dialog'),
                    onPressed: _showLoadingDialog,
                  ),
                  TextButton(
                    child: const Text('Loading SnackBar '),
                    onPressed: _showLoadingSnackBar,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    child: const Text('Show queue loading Dialog'),
                    onPressed: _showQueueLoadingDialog,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.reset();
          controller.forward();
        },
        child: const Text('Run'),
      ),
    );
  }

  void _startLoading() async {
    setState(() {
      isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 5));
    setState(() {
      isLoading = false;
    });
  }

  void _startMaterialDialog() async {
    final dialog = material.AtSyncDialog(
      context: context,
      indicatorColor: _indicatorColor,
    );
    dialog.show(message: 'Downloading ...');
    for (int i = 1; i < 100; i += 5) {
      dialog.update(value: 0.01 * i, message: 'Downloading ...');
      await Future.delayed(const Duration(milliseconds: 100));
    }
    dialog.close();
  }

  void _startCupertinoDialog() async {
    final dialog = cupertino.AtSyncDialog(
      context: context,
      indicatorColor: _indicatorColor,
    );
    dialog.show(message: 'Downloading ...');
    for (int i = 1; i < 100; i += 5) {
      dialog.update(value: 0.01 * i, message: 'Downloading ...');
      await Future.delayed(const Duration(milliseconds: 100));
    }
    dialog.close();
  }

  void _startMaterialSnackBar() async {
    final snackBar = material.AtSyncSnackBar(
      context: context,
      indicatorColor: _indicatorColor,
    );
    snackBar.show(message: 'Downloading ...');
    for (int i = 1; i < 100; i += 5) {
      snackBar.update(value: 0.01 * i, message: 'Downloading ...');
      await Future.delayed(const Duration(milliseconds: 100));
    }
    snackBar.dismiss();
  }

  void _startCupertinoSnackBar() async {
    final snackBar = cupertino.AtSyncSnackBar(
      context: context,
      indicatorColor: _indicatorColor,
    );
    snackBar.show();
    for (int i = 1; i < 100; i += 5) {
      snackBar.update(value: 0.01 * i, message: 'Downloading ...');
      await Future.delayed(const Duration(milliseconds: 100));
    }
    snackBar.dismiss();
  }

  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return BlockPicker(
          pickerColor: _indicatorColor,
          onColorChanged: (color) {
            setState(() {
              _indicatorColor = color;
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showLoadingDialog() async {
    AtSyncUI.instance.showDialog(message: "Downloading");
    await Future.delayed(const Duration(seconds: 3));
    AtSyncUI.instance.hideDialog();
  }

  void _showLoadingSnackBar() async {
    AtSyncUI.instance.showSnackBar(message: "Downloading");
    await Future.delayed(const Duration(seconds: 3));
    AtSyncUI.instance.hideSnackBar();
  }

  void _showQueueLoadingDialog() async {
    await Future.delayed(const Duration(seconds: 1));

    final controller = AtSyncUI.instance.syncUIController;

    log('add loading 1');
    controller?.addLoadingQueue();
    await Future.delayed(const Duration(seconds: 1));
    log('add loading 2');
    controller?.addLoadingQueue();
    await Future.delayed(const Duration(seconds: 1));
    log('remove loading 1');
    controller?.removeLoadingQueue();
    await Future.delayed(const Duration(seconds: 1));
    log('remove loading 1');
    controller?.removeLoadingQueue();
  }
}
