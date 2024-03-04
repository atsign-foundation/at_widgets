import 'package:at_enrollment_flutter/common_widgets/button.dart';
import 'package:at_enrollment_flutter/models/enrollment.dart';
import 'package:at_enrollment_flutter/services/enrollment_service.dart';
import 'package:at_enrollment_flutter/utils/assets.dart';
import 'package:at_enrollment_flutter/utils/colors.dart';
import 'package:at_enrollment_flutter/utils/enrollment_utils.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:flutter/material.dart';

enum RequestStatus { pending, successful, expired }

class EnrollmentRequestCard extends StatefulWidget {
  final RequestStatus? status;
  final Function()? onDone;
  final Function()? onDeny;
  final Function()? onApprove;
  final EnrollmentData enrollmentData;

  const EnrollmentRequestCard({
    super.key,
    this.status,
    this.onDone,
    this.onDeny,
    this.onApprove,
    required this.enrollmentData,
  });

  @override
  State<EnrollmentRequestCard> createState() => _EnrollmentRequestCardState();
}

class _EnrollmentRequestCardState extends State<EnrollmentRequestCard> {
  bool isActioned = false;

  @override
  void initState() {
    super.initState();
  }

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
                package: 'at_enrollment_flutter',
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.enrollmentData.atSign,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: ColorConstant.black,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      widget.enrollmentData.deviceName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: ColorConstant.black,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                        EnrollmentUtil.enrollmentTypeToWord(
                          widget.enrollmentData.namespace,
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: ColorConstant.lightGrey,
                          overflow: TextOverflow.ellipsis,
                        )),
                  ],
                ),
              ),
            ],
          ),
          if (widget.status == RequestStatus.pending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Button(
                    onPressed: isActioned
                        ? null
                        : () async {
                            await Future.delayed(Duration(seconds: 5));
                            EnrollmentService.getInstance()
                                .manageEnrollmentRequest(
                              widget.enrollmentData,
                              EnrollOperationEnum.deny,
                            );
                          },
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
                    onPressed: isActioned
                        ? null
                        : () {
                            EnrollmentService.getInstance()
                                .manageEnrollmentRequest(
                              widget.enrollmentData,
                              EnrollOperationEnum.approve,
                            );
                          },
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
            package: 'at_enrollment_flutter',
          )
        ],
      ),
    );
  }
}
