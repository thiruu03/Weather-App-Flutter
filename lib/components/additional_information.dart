import 'package:flutter/material.dart';

class AdditionalInformation extends StatelessWidget {
  final IconData icon;
  final String currentStage;
  final String level;

  const AdditionalInformation(
      {super.key,
      required this.icon,
      required this.currentStage,
      required this.level});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Icon(
            icon,
            size: 42,
          ),
          const SizedBox(
            height: 9,
          ),
          Text(
            currentStage,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 9,
          ),
          Text(
            level,
            style: const TextStyle(fontSize: 17),
          ),
        ],
      ),
    );
  }
}
