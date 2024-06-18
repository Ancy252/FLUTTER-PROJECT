// lib/falling_grapes.dart

import 'dart:math';
import 'package:flutter/material.dart';

class FallingGrapes extends StatefulWidget {
  @override
  _FallingGrapesState createState() => _FallingGrapesState();
}

class _FallingGrapesState extends State<FallingGrapes> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<Offset>> _animations;
  final int _numGrapes = 10;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _animations = List.generate(_numGrapes, (index) {
      final startOffset = Offset(_random.nextDouble() * 2 - 1, _random.nextDouble() * -1);
      final endOffset = Offset(_random.nextDouble() * 2 - 1, 1);
      return Tween<Offset>(begin: startOffset, end: endOffset).animate(_controller);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _animations.map((animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return FractionalTranslation(
              translation: animation.value,
              child: child,
            );
          },
          child: Icon(Icons.grain, color: Colors.deepPurple, size: 30),
        );
      }).toList(),
    );
  }
}
