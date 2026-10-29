import 'package:flutter/material.dart';

class ShowcaseViewLudo extends StatelessWidget {
  final String title;

  const ShowcaseViewLudo({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.rotate(
          angle: 6.0,
          child: const Text("👆", style: TextStyle(fontSize: 42.0)),
        ),
        const SizedBox(height: 10.0),
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: FittedBox(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
