import 'package:flutter/material.dart';

/// ✅ Delegate untuk SliverPersistentHeader dengan tinggi otomatis
class SwitchMenuDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  SwitchMenuDelegate(this.child);

  double? _calculatedHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _calculatedHeight ??= constraints.biggest.height;
        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: child,
        );
      },
    );
  }

  @override
  double get maxExtent => _calculatedHeight ?? 60;

  @override
  double get minExtent => _calculatedHeight ?? 60;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
