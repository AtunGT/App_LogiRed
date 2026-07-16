import 'package:flutter/material.dart';

class ScrollableNavigationRail extends StatelessWidget {
  final NavigationRail rail;
  const ScrollableNavigationRail({super.key, required this.rail});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(child: rail),
          ),
        );
      },
    );
  }
}
