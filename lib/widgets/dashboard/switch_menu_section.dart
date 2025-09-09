import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

class SwitchMenuSection extends StatelessWidget {
  final bool showMyReports;
  final ValueChanged<bool> onToggle;

  const SwitchMenuSection({
    super.key,
    required this.showMyReports,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SlideInDown(
      duration: const Duration(milliseconds: 600),
      delay: const Duration(milliseconds: 100),
      child: FadeIn(
        duration: const Duration(milliseconds: 700),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeInLeft(
                duration: const Duration(milliseconds: 500),
                child: const Text('Laporan:'),
              ),
              const SizedBox(width: 12),
              BounceInDown(
                duration: const Duration(milliseconds: 700),
                delay: const Duration(milliseconds: 200),
                child: ChoiceChip(
                  label: const Text('Saya'),
                  selected: showMyReports,
                  onSelected: (selected) {
                    onToggle(true);
                  },
                ),
              ),
              const SizedBox(width: 8),
              BounceInDown(
                duration: const Duration(milliseconds: 700),
                delay: const Duration(milliseconds: 300),
                child: ChoiceChip(
                  label: const Text('Warga'),
                  selected: !showMyReports,
                  onSelected: (selected) {
                    onToggle(false);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
