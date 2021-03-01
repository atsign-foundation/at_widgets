import 'package:at_follows_flutter/utils/custom_textstyles.dart';
import 'package:at_follows_flutter/utils/strings.dart';
import 'package:flutter/material.dart';

class CustomErrorDialog extends StatelessWidget {
  final error;
  CustomErrorDialog({@required this.error});

  //  String errorMessage = _getErrorMessage(this.error);
  // var title = AtText.TITLE_ERROR_DIALOG;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Text(
            Strings.Error,
            style: CustomTextStyles.fontR14primary,
          ),
          Icon(Icons.sentiment_dissatisfied)
        ],
      ),
      content: Text('${this.error}'),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(Strings.Close),
        )
      ],
    );
  }

  //  ///Returns corresponding errorMessage for [error].
  // static String _getErrorMessage(var error) {
  //   switch (error.runtimeType) {
  //     case AtClientException:
  //       return 'Unable to perform this action. Please try again.';
  //       break;
  //     case UnAuthenticatedException:
  //       return 'Unable to authenticate. Please try again.';
  //       break;
  //     case NoSuchMethodError:
  //       return 'Failed in processing. Please try again.';
  //       break;
  //     case AtConnectException:
  //       return 'Unable to connect server. Please try again later.';
  //       break;
  //     case AtIOException:
  //       return 'Unable to perform read/write operation. Please try again.';
  //       break;
  //     case AtServerException:
  //       return 'Unable to activate server. Please contact admin.';
  //       break;
  //     case SecondaryNotFoundException:
  //       return 'Server is unavailable. Please try again later.';
  //       break;
  //     case SecondaryConnectException:
  //       return 'Unable to connect. Please check with network connection and try again.';
  //       break;
  //     case InvalidAtSignException:
  //       return 'Invalid atsign is provided. Please contact admin.';
  //       break;
  //     case String:
  //       return error;
  //       break;
  //     default:
  //       return 'Unknown error.';
  //       break;
  //   }
  // }
}

class ErrorDialog {
  static final ErrorDialog _singleton = ErrorDialog._internal();

  ErrorDialog._internal();
  // final AtSignLogger _logger = AtSignLogger('ErrorDialog');

  factory ErrorDialog.getInstance() {
    return _singleton;
  }

  void show(var error, {@required BuildContext context}) {
    showDialog(
        context: context,
        builder: (_) {
          return CustomErrorDialog(
            error: error.toString(),
          );
        });
  }
}
