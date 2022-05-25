import 'package:flutter/material.dart';

class ProfileStat extends StatelessWidget {
  final String stat;
  const ProfileStat({required this.stat, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Text(
        stat,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}
