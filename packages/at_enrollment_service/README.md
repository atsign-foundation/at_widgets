# at_enrollment_app

A new Flutter project.

## Getting Started

This is a demonstration application showcasing an enrollment authentication flow.

The enrollment process involves two parties: the approving app and the app that sends the enrollment request.

To access the approving app's features, follow these steps:
1. Launch the app and select the "Onboard" button.
2. If you have an existing atSign, provide the .atKeys file. If not, create a new atSign.
3. After a successful login, go to the "Enrollments" section in the side menu.

Here's what happens next:
- The app will establish a connection to a secondary server and start monitoring for enrollment requests.
- When an enrollment request is received, it will be displayed on the screen.
- You can click on the "enrollment request" to view options for approving or denying the enrollment.
- At the bottom of the screen, an OTP (One-Time Password) will be displayed for the app requesting enrollment.

To send an enrollment request from your app, follow these steps:
1. Click on the "Enroll" button when launching the app.
2. This action will take you to the "Send Enrollment Request" page.
3. Fill in the required fields and enter the OTP.
4. Click the submit button to send the enrollment request.
5. If the enrollment is approved, a ".atKeys" file will be generated and stored on your device.

Use this new ".atKeys" file for authentication into the app.