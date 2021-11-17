import 'package:at_sync_ui_flutter/at_sync_material.dart' as material;
import 'package:at_sync_ui_flutter/at_sync_cupertino.dart' as cupertino;
import 'package:flutter/material.dart';

const double _kNormalPadding = 16;
const double _kSmallPadding = 8;
const double _kLargePadding = 32;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AtSync Widget',
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
        _atSyncDialog?.update(
          value: animation.value,
          message: 'Downloading ...',
        );
        _atSyncSnackBar?.update(
          value: animation.value,
          message: 'Uploading ...',
        );
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
              icon: const Icon(Icons.search),
              onPressed: _startDownload,
            ),
          ),
          cupertino.AtSyncButton(
            isLoading: isLoading,
            syncIndicatorColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _startSnackBar,
            ),
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
                children: const [
                  material.AtSyncIndicator(),
                  cupertino.AtSyncIndicator(),
                ],
              ),
              const SizedBox(height: _kLargePadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  material.AtSyncIndicator(radius: 24),
                  cupertino.AtSyncIndicator(radius: 24),
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
                    child: ElevatedButton(
                      child: const Text('Press me!'),
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        await Future.delayed(const Duration(seconds: 2));
                        setState(() {
                          isLoading = false;
                        });
                      },
                    ),
                  ),
                  cupertino.AtSyncButton(
                    isLoading: isLoading,
                    child: ElevatedButton(
                      child: const Text('Press me!'),
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        await Future.delayed(const Duration(seconds: 2));
                        setState(() {
                          isLoading = false;
                        });
                      },
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
                  material.AtSyncIndicator(value: progress),
                  cupertino.AtSyncIndicator(progress: progress),
                ],
              ),
              const SizedBox(height: _kLargePadding),
              const Text('AtSyncLinearProgressIndicator'),
              const SizedBox(height: _kSmallPadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Expanded(child: material.AtSyncLinearProgressIndicator()),
                  SizedBox(width: _kSmallPadding),
                  Expanded(
                    child: cupertino.AtSyncLinearProgressIndicator(),
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
                      )),
                  const SizedBox(width: _kSmallPadding),
                  Expanded(
                    flex: 1,
                    child: cupertino.AtSyncLinearProgressIndicator(
                      progress: progress,
                      minHeight: 20,
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
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: cupertino.AtSyncText(
                      value: progress,
                      child: const Text('completed'),
                    ),
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

  material.AtSyncDialog? _atSyncDialog;
  material.AtSyncSnackBar? _atSyncSnackBar;

  void _startDownload() async {
    controller.reset();
    controller.forward();

    _atSyncDialog ??= material.AtSyncDialog(context: context);
    _atSyncDialog?.show(max: 100, msg: "abc");
    setState(() {
      isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 5));
    setState(() {
      isLoading = false;
    });
    _atSyncDialog?.close();
  }

  void _startSnackBar() async {
    controller.reset();
    controller.forward();
    _atSyncSnackBar ??= material.AtSyncSnackBar(context: context);
    _atSyncSnackBar?.show();
    setState(() {
      isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 5));
    setState(() {
      isLoading = false;
    });
    _atSyncSnackBar?.dismiss();
  }
}
