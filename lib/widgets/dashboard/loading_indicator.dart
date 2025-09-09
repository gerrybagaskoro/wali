import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ZoomIn(
        duration: const Duration(milliseconds: 500),
        child: const CircularProgressIndicator(),
      ),
    );
  }
}
