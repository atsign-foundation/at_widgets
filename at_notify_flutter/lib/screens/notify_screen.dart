import 'package:at_notify_flutter/models/notify_model.dart';
import 'package:at_notify_flutter/services/notify_service.dart';
import 'package:at_onboarding_flutter/services/size_config.dart';
import 'package:flutter/material.dart';

class NotifyScreen extends StatefulWidget {
  final NotifyService? notifyService;
  final bool isAuthorAtSign;
  final String? atSign;

  const NotifyScreen({
    Key? key,
    this.notifyService,
    this.isAuthorAtSign = false,
    this.atSign = '',
  }) : super(key: key);

  @override
  _NotifyScreenState createState() => _NotifyScreenState();
}

class _NotifyScreenState extends State<NotifyScreen>
    with AutomaticKeepAliveClientMixin {
  ScrollController? _scrollController;

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      await widget.notifyService!.getNotifies(
        atsign: widget.atSign,
      );
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: StreamBuilder<List<Notify>>(
        stream: widget.notifyService!.notifyStream,
        initialData: widget.notifyService!.notifies,
        builder: (context, snapshot) {
          return (snapshot.connectionState == ConnectionState.waiting)
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : (snapshot.data == null || snapshot.data!.isEmpty)
                  ? Center(
                      child: Text('No bug report found'),
                    )
                  : ListView.separated(
                      controller: _scrollController,
                      shrinkWrap: true,
                      itemCount: snapshot.data?.length ?? 0,
                      padding: EdgeInsets.symmetric(vertical: 12.toHeight),
                      itemBuilder: (context, index) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 12.toHeight, horizontal: 12.toWidth),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                snapshot.data?[index]?.message ?? 'Error',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Divider();
                      },
                    );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
