import 'package:flutter/material.dart';

class VirtualCharacter extends StatelessWidget {
  const VirtualCharacter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.blue, width: 2),
      ),
      child: const Center(
        child: Icon(
          Icons.face_retouching_natural_rounded,
          size: 100,
          color: Colors.blue,
        ),
      ),
    );
  }
}
