import 'package:flutter/material.dart';

class AdditionalInformationItem extends StatelessWidget {
  const AdditionalInformationItem({
    super.key, required this.icon, required this.label, required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32),
        const SizedBox(height: 10),
        Text(label),
        const SizedBox(height: 10),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
