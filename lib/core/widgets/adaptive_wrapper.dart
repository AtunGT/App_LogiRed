import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class AdaptiveWrapper extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const AdaptiveWrapper({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final maxW = Responsive.maxContentWidth(context);
    final hPad = padding?.resolve(TextDirection.ltr).left ??
        Responsive.horizontalPadding(context);

    Widget content = Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: child,
    );

    if (maxW != double.infinity) {
      content = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: child,
        ),
      );
    }

    return content;
  }
}

class AdaptiveScrollView extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? innerPadding;

  const AdaptiveScrollView({
    super.key,
    required this.children,
    this.innerPadding,
  });

  @override
  Widget build(BuildContext context) {
    final maxW = Responsive.maxContentWidth(context);
    final hPad = Responsive.horizontalPadding(context);

    Widget content = SingleChildScrollView(
      padding: innerPadding ?? EdgeInsets.fromLTRB(hPad, 0, hPad, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );

    if (maxW != double.infinity) {
      return Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: content,
        ),
      );
    }

    return content;
  }
}
