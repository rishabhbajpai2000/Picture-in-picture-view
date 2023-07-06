import 'package:flutter/material.dart';

import 'dismiss_keyboard.dart';
import 'raw_pip_view.dart';

class PIPView extends StatefulWidget {
  final PIPViewCorner initialCorner;
  final double? floatingWidth;
  final double? floatingHeight;
  final bool avoidKeyboard;

  final Widget Function(
    BuildContext context,
    bool isFloating,
  ) builder;

  const PIPView({
    Key? key,
    required this.builder, // this is the builder for the top widget (the one that is always visible)
    this.initialCorner = PIPViewCorner.topRight,
    this.floatingWidth,
    this.floatingHeight,
    this.avoidKeyboard = true,
  }) : super(key: key);

  @override
  PIPViewState createState() => PIPViewState();

  static PIPViewState? of(BuildContext context) {
    return context.findAncestorStateOfType<PIPViewState>();
  }
}

class PIPViewState extends State<PIPView> with TickerProviderStateMixin {
  Widget? _bottomWidget;

  void presentBelow(Widget widget) { 
    dismissKeyboard(context);
    setState(() => _bottomWidget = widget);
  }

  void stopFloating() {
    dismissKeyboard(context);
    setState(() => _bottomWidget = null);
  }

  @override
  Widget build(BuildContext context) {
    final isFloating = _bottomWidget != null;
    return RawPIPView(
      startMinimized: true,
      avoidKeyboard: widget.avoidKeyboard,
      bottomWidget: isFloating
          ? Navigator(
              onGenerateInitialRoutes: (navigator, initialRoute) => [
                MaterialPageRoute(builder: (context) => _bottomWidget!),
              ],
            )
          : null, // this means bottom widget will be equal to the _bottomWidget if isFloating is true, else it will be null
      onTapTopWidget: isFloating ? stopFloating : null, // if isFloating is true, onTapTopWidget will be stopFloating, else it will be null
      topWidget: IgnorePointer(
        ignoring: isFloating,
        child: Builder(
          builder: (context) => widget.builder(context, isFloating),
        ), // ignore pointer is a class which is used for ignoring the pointer events, in simple words it is used for disabling the widget
        // here in the above case ingorePointer is used for disabling the top widget when the bottom widget is floating
      ),
      floatingHeight: widget.floatingHeight,
      floatingWidth: widget.floatingWidth,
      initialCorner: widget.initialCorner,
    );
  }
}
