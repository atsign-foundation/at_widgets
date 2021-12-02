<img src="https://atsign.dev/assets/img/@developersmall.png?sanitize=true">

### Now for some internet optimism.

# at_common_flutter

## Overview:

A Flutter package to provide custom widgets for other atsign packages.

## Getting Started

### Installation:

 To use this library in your app, add it to your pubspec.yaml

``` 
  dependencies:
    at_common_flutter: ^2.0.3
```
#### Add to your project

 ```dart
 flutter pub get 
 ```
 #### Import in your application code

 ```dart
 import 'package:at_common_flutter/at_common_flutter.dart';
 ```
### Clone it from github

 Feel free to fork a copy of the source from the [GitHub Repo](https://github.com/atsign-foundation/at_widgets)

### Usage
This package provides the following custom widgets:

#### CustomAppBar
```
    return Scaffold(
      appBar: CustomAppBar(
        showBackButton: false,
        showTitle: true,
        titleText: widget.title,
        onTrailingIconPressed: () {
          print('Trailing icon of appbar pressed');
        },
        showTrailingIcon: true,
        trailingIcon: Center(
          child: Icon(
            Icons.add,
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white,
          ),
        ),
      ),
    );
```

#### CustomButton
```
CustomButton(
    height: 50.0,
    width: 200.0,
    buttonText: 'Add',
    onPressed: () {
    print('Custom button pressed');
    },
    buttonColor: Theme.of(context).brightness == Brightness.light
        ? Colors.black
        : Colors.white,
    fontColor: Theme.of(context).brightness == Brightness.light
        ? Colors.white
        : Colors.black,
),
```

#### CustomInputField
```
CustomInputField(
    icon: Icons.emoji_emotions_outlined,
    width: 200.0,
    initialValue: "initial value",
    value: (String val) {
    print('Current value of input field: $val');
    },
),
```

#### SizeConfig service
This service is used to adjust height of widget based upon the screen size.
This service needs to be initialised before usage.
```
import 'package:at_common_flutter/at_common_flutter.dart' as CommonWidgets;

CommonWidgets.SizeConfig().init(context);
```

## Open source usage and contributions

 This is freely licensed open source code, so feel free to use it as is, suggest changes or enhancements or create your
 own version. See [CONTRIBUTING.md](https://github.com/atsign-foundation/at_widgets/blob/trunk/CONTRIBUTING.md) for detailed guidance on how to setup tools, tests and make a pull request.
