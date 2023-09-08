import 'package:at_enrollment_app/screen/enrollment_screen.dart';
import 'package:at_enrollment_app/screen/home_screen.dart';
import 'package:at_enrollment_app/screen/landing_screen.dart';
import 'package:at_enrollment_app/screen/send_enrollment_request.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: GoRouter(routes: [
        GoRoute(
            name: 'LandingPage',
            path: "/",
            builder: (context, state) => const LandingPage()),
        GoRoute(
            name: 'HomePage',
            path: "/homePage",
            builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: "/submitEnrollment",
          builder: (context, state) => SendEnrollmentRequestWidget(
              otp: state.uri.queryParameters['otp']),
        ),
        GoRoute(
            name: 'Enrollments',
            path: '/enrollments',
            builder: (context, state) => const EnrollmentWidget()),
      ]),
    );
  }
}
