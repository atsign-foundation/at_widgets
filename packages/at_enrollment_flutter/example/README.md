# at_enrollment_flutter_example

## Overview

This app showcases the range of operations offered by our enrollment service and provides guidance on how to use them.
It is compatible with Flutter version 3.22.2 (Stable).

## Key Features

- Submit Enrollment Request: Users can initiate and submit an enrollment request.
- Manage Enrollment Requests: Users with the appropriate permissions can approve, deny, or revoke submitted enrollment
  requests.

## Notifications

- When an enrollment request is submitted, all users with access to the "__manage" namespace will receive a notification
  to review and manage the request.

## Usage

### Submitting an Enrollment Request

To submit an enrollment request through the Mobile Enrollment App, follow these steps:

- Launch the Mobile App: Open the app on your mobile device.
- Navigate to Enrollment: On the home screen, tap the "Enroll" button to start the enrollment process.
- Fill Out the Form:
  - App Name: Enter the name of the application.
  - Device Name: Provide the name of your device.
  - Namespace: Specify the namespace and the level of access required.
  - OTP: Enter the One-Time Password (if applicable).
- Submit Your Request: Once all the fields are completed, submit the enrollment request.
- Receive Confirmation: After successful submission, a unique key will be generated and displayed. This key is your
  confirmation and can be used for future reference.

### Review and Manage Requests:

Users who have access to the __manage namespace will receive notifications about new enrollment requests. These users
have the ability to approve, deny, or revoke these requests.

- Launch the Mobile App: Open the app on your mobile device.
- Onboard the atSign: On the home screen, tap the "Onboard" button.
  - Authenticate your @Sign by providing the atKeys file.
- Navigate to "requests" tab to view the pending enrollment requests
- Tap on the request to view the operations.
- Tap on "Approve" or "Deny" buttons to approve or deny the enrollment requests.