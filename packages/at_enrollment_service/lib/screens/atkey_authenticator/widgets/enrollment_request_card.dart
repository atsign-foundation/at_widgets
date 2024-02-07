import 'package:at_enrollment_app/common_widgets/button.dart';
import 'package:at_enrollment_app/screens/atkey_authenticator/widgets/countdown_timer_widget.dart';
import 'package:at_enrollment_app/utils/assets.dart';
import 'package:at_enrollment_app/utils/colors.dart';
import 'package:flutter/material.dart';

enum RequestStatus { pending, successful, expired }

class EnrollmentRequestCard extends StatefulWidget {
  final RequestStatus status;
  final Function()? onDone;
  final Function()? onDeny;
  final Function()? onApprove;

  const EnrollmentRequestCard({
    super.key,
    required this.status,
    this.onDone,
    this.onDeny,
    this.onApprove,
  });

  @override
  State<EnrollmentRequestCard> createState() => _EnrollmentRequestCardState();
}

class _EnrollmentRequestCardState extends State<EnrollmentRequestCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.status != RequestStatus.pending) ...[
            buildStatusBadge,
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Image.asset(
                Images.greyAppIcon,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                package: 'at_enrollment_app',
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Max’s Iphone 15 Pro Max',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: ColorConstant.black,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      'SSH No Ports',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: ColorConstant.black,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text('Read Only',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: ColorConstant.lightGrey,
                          overflow: TextOverflow.ellipsis,
                        )),
                  ],
                ),
              ),
              if (widget.status == RequestStatus.pending) ...[
                const SizedBox(width: 24),
                CountdownTimerWidget(onDone: widget.onDone),
              ]
            ],
          ),
          if (widget.status == RequestStatus.pending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Button(
                    onPressed: widget.onDeny,
                    height: 36,
                    width: double.infinity,
                    buttonText: 'Deny',
                    buttonColor: Colors.transparent,
                    titleStyle: const TextStyle(
                      color: ColorConstant.denyColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                    borderRadius: 25,
                    border: Border.all(color: ColorConstant.denyColor),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Button(
                    onPressed: widget.onApprove,
                    height: 36,
                    width: double.infinity,
                    buttonText: 'Approve',
                    buttonColor: ColorConstant.orange,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                    borderRadius: 25,
                  ),
                ),
              ],
            ),
          ] else
            const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget get buildStatusBadge {
    final isSuccessful = widget.status == RequestStatus.successful;
    return Container(
      height: 32,
      padding: EdgeInsets.only(left: isSuccessful ? 16 : 12, right: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(72),
        color: isSuccessful
            ? ColorConstant.successfulBackgroundColor
            : ColorConstant.expiredBackgroundColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isSuccessful ? 'Successful Authentication' : 'Expired',
            style: TextStyle(
              color: isSuccessful
                  ? ColorConstant.successfulColor
                  : ColorConstant.orange,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          Image.asset(
            isSuccessful ? Images.successful : Images.expired,
            package: 'at_enrollment_app',
          )
        ],
      ),
    );
  }
}
