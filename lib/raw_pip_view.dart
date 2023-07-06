import 'package:flutter/material.dart';

import 'constants.dart';
// we are going to add detailed comments to this file, explaining each line, please help.

// this is the main widget that is used to create the PIP view
class RawPIPView extends StatefulWidget {
  final PIPViewCorner
      initialCorner; // this is the initial corner of the PIP view
  final double?
      floatingWidth; // this is the width of the PIP view when it is floating
  final double?
      floatingHeight; // this is the height of the PIP view when it is floating
  final bool
      avoidKeyboard; // this is a boolean that is used to avoid the keyboard
  final Widget?
      topWidget; // this is the widget that is displayed on top of the PIP view
  final Widget?
      bottomWidget; // this is the widget that is displayed on the bottom of the PIP view
  // this is exposed because trying to watch onTap event
  // by wrapping the top widget with a gesture detector
  // causes the tap to be lost sometimes because it
  // is competing with the drag
  final void Function()? onTapTopWidget;

  final bool startMinimized;

  // this is the constructor of the class
  const RawPIPView({
    Key? key,
    this.initialCorner = PIPViewCorner.topRight,
    this.floatingWidth,
    this.floatingHeight,
    this.avoidKeyboard = true,
    this.topWidget,
    this.bottomWidget,
    this.onTapTopWidget,
    required this.startMinimized,
  }) : super(key: key);

  @override
  RawPIPViewState createState() => RawPIPViewState();
}

// this is the state of the widget
class RawPIPViewState extends State<RawPIPView> with TickerProviderStateMixin {
  late final AnimationController
      _toggleFloatingAnimationController; // this is the animation controller that is used to toggle the floating animation
  late final AnimationController
      _dragAnimationController; // this is the animation controller that is used to drag the PIP view
  late PIPViewCorner _corner; // this is the corner of the PIP view
  Offset _dragOffset = Offset
      .zero; // this is the offset of the PIP view, offset means the distance between the PIP view and the corner
  var _isDragging =
      false; // this is a boolean that is used to check if the PIP view is being dragged or not
  var _isFloating =
      false; // this is a boolean that is used to check if the PIP view is floating or not
  Widget?
      _bottomWidgetGhost; // this is the widget that is displayed on the bottom of the PIP view
  Map<PIPViewCorner, Offset> _offsets =
      {}; // this is the map that contains the offsets of the PIP view

  @override
  void initState() {
    super.initState();
    _corner = widget.initialCorner;
    _isFloating = true; // Set the initial state to floating
    _toggleFloatingAnimationController = AnimationController(
      duration: defaultAnimationDuration,
      vsync: this,
      // the value will be 0 or 1 depending on if startMinimized is true or false
      // it is reposible for the size of the floating window. 
      value: widget.startMinimized ? 1.0 : 0.0,
    );
    _dragAnimationController = AnimationController(
      duration: defaultAnimationDuration,
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(covariant RawPIPView oldWidget) {
    // this function is called when the widget is updated
    super.didUpdateWidget(
        oldWidget); // this is the super function of the didUpdateWidget function
    if (_isFloating) {
      // if the PIP view is floating
      if (widget.topWidget == null || widget.bottomWidget == null) {
        // if the top widget or the bottom widget is null
        _isFloating = false; // the PIP view is not floating
        _bottomWidgetGhost = oldWidget
            .bottomWidget; // the bottom widget ghost is the old bottom widget
        _toggleFloatingAnimationController.reverse().whenCompleteOrCancel(() {
          // this is the animation controller that is used to toggle the floating animation
          if (mounted) {
            setState(() => _bottomWidgetGhost = null);
          }
        });
      }
    } else {
      if (widget.topWidget != null && widget.bottomWidget != null) {
        _isFloating = true;
        _toggleFloatingAnimationController.forward();
      }
    }
  }

  void _updateCornersOffsets({
    required Size spaceSize,
    required Size widgetSize,
    required EdgeInsets windowPadding,
  }) {
    _offsets = _calculateOffsets(
      spaceSize: spaceSize,
      widgetSize: widgetSize,
      windowPadding: windowPadding,
    );
  }

  bool _isAnimating() {
    return _toggleFloatingAnimationController.isAnimating ||
        _dragAnimationController.isAnimating;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    setState(() {
      _dragOffset = _dragOffset.translate(
        details.delta.dx,
        details.delta.dy,
      );
    });
  }

  void _onPanCancel() {
    if (!_isDragging) return;
    setState(() {
      _dragAnimationController.value = 0;
      _dragOffset = Offset.zero;
      _isDragging = false;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isDragging) return;

    final nearestCorner = _calculateNearestCorner(
      offset: _dragOffset,
      offsets: _offsets,
    );
    setState(() {
      _corner = nearestCorner;
      _isDragging = false;
    });
    _dragAnimationController.forward().whenCompleteOrCancel(() {
      _dragAnimationController.value = 0;
      _dragOffset = Offset.zero;
    });
  }

  void _onPanStart(DragStartDetails details) {
    if (_isAnimating()) return;
    setState(() {
      _dragOffset = _offsets[_corner]!;
      _isDragging = true;
    });
  }

  void _onTapTopWidget() {
    // this function is called when the top widget is tapped
    // if the PIP view is animating, return
    if (_isAnimating()) return;

    // if the PIP view is not floating, set the state to floating and vice versa
    setState(() {
      _isFloating = !_isFloating;
    });

    // maximised to minimise 
    if (_isFloating) {
      _toggleFloatingAnimationController.forward();
    }
    // minimissed to maximise condition. 
    else {
      _toggleFloatingAnimationController.reverse().whenCompleteOrCancel(() {
        if (mounted) {
          setState(() {
            _bottomWidgetGhost = null;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // this function is called when the widget is built
    final mediaQuery =
        MediaQuery.of(context); // this is the media query of the context
    var windowPadding =
        mediaQuery.padding; // this is the window padding of the media query
    if (widget.avoidKeyboard) {
      windowPadding += mediaQuery.viewInsets;
    }

    return LayoutBuilder(
      // this is the layout builder of the widget, layout builder is used to build the layout of the widget
      builder: (context, constraints) {
        final bottomWidget = widget.bottomWidget ?? _bottomWidgetGhost;
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        double? floatingWidth = widget.floatingWidth;
        double? floatingHeight = widget.floatingHeight;
        if (floatingWidth == null && floatingHeight != null) {
          floatingWidth = width / height * floatingHeight;
        }
        floatingWidth ??= 100.0;
        if (floatingHeight == null) {
          floatingHeight = height / width * floatingWidth;
        }

        final floatingWidgetSize = Size(floatingWidth, floatingHeight);
        final fullWidgetSize = Size(width, height);

        _updateCornersOffsets(
          spaceSize: fullWidgetSize,
          widgetSize: floatingWidgetSize,
          windowPadding: windowPadding,
        );

        final calculatedOffset = _offsets[_corner];

        // BoxFit.cover
        final widthRatio = floatingWidth / width;
        final heightRatio = floatingHeight / height;
        final scaledDownScale = widthRatio > heightRatio
            ? floatingWidgetSize.width / fullWidgetSize.width
            : floatingWidgetSize.height / fullWidgetSize.height;

        return Stack(
          children: <Widget>[
            if (bottomWidget != null) bottomWidget,
            if (widget.topWidget != null)
              AnimatedBuilder(
                animation: Listenable.merge([
                  _toggleFloatingAnimationController,
                  _dragAnimationController,
                ]),
                builder: (context, child) {
                  final animationCurve = CurveTween(
                    curve: Curves.easeInOutQuad,
                  );
                  final dragAnimationValue = animationCurve.transform(
                    _dragAnimationController.value,
                  );
                  final toggleFloatingAnimationValue = animationCurve.transform(
                    _toggleFloatingAnimationController.value,
                  );

                  final floatingOffset = _isDragging
                      ? _dragOffset
                      : Tween<Offset>(
                          begin: _dragOffset,
                          end: calculatedOffset,
                        ).transform(_dragAnimationController.isAnimating
                          ? dragAnimationValue
                          : toggleFloatingAnimationValue);
                  final borderRadius = Tween<double>(
                    begin: 0,
                    end: 10,
                  ).transform(toggleFloatingAnimationValue);
                  final width = Tween<double>(
                    begin: fullWidgetSize.width,
                    end: floatingWidgetSize.width,
                  ).transform(toggleFloatingAnimationValue);
                  final height = Tween<double>(
                    begin: fullWidgetSize.height,
                    end: floatingWidgetSize.height,
                  ).transform(toggleFloatingAnimationValue);
                  final scale = Tween<double>(
                    begin: 1,
                    end: scaledDownScale,
                  ).transform(toggleFloatingAnimationValue);
                  return Positioned(
                    left: floatingOffset.dx,
                    top: floatingOffset.dy,
                    child: GestureDetector(
                      onPanStart: _isFloating ? _onPanStart : null,
                      onPanUpdate: _isFloating ? _onPanUpdate : null,
                      onPanCancel: _isFloating ? _onPanCancel : null,
                      onPanEnd: _isFloating ? _onPanEnd : null,
                      onTap: widget.onTapTopWidget ?? _onTapTopWidget,
                      child: Material(
                        elevation: 10,
                        borderRadius: BorderRadius.circular(borderRadius),
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(borderRadius),
                          ),
                          width: width,
                          height: height,
                          child: Transform.scale(
                            scale: scale,
                            child: OverflowBox(
                              maxHeight: fullWidgetSize.height,
                              maxWidth: fullWidgetSize.width,
                              child: child,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: widget.topWidget,
              ),
          ],
        );
      },
    );
  }
}

enum PIPViewCorner {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

class _CornerDistance {
  final PIPViewCorner corner;
  final double distance;

  _CornerDistance({
    required this.corner,
    required this.distance,
  });
}

PIPViewCorner _calculateNearestCorner({
  required Offset offset,
  required Map<PIPViewCorner, Offset> offsets,
}) {
  _CornerDistance calculateDistance(PIPViewCorner corner) {
    final distance = offsets[corner]!
        .translate(
          -offset.dx,
          -offset.dy,
        )
        .distanceSquared;
    return _CornerDistance(
      corner: corner,
      distance: distance,
    );
  }

  final distances = PIPViewCorner.values.map(calculateDistance).toList();

  distances.sort((cd0, cd1) => cd0.distance.compareTo(cd1.distance));

  return distances.first.corner;
}

Map<PIPViewCorner, Offset> _calculateOffsets({
  required Size spaceSize,
  required Size widgetSize,
  required EdgeInsets windowPadding,
}) {
  Offset getOffsetForCorner(PIPViewCorner corner) {
    final spacing = 16;
    final left = spacing + windowPadding.left;
    final top = spacing + windowPadding.top;
    final right =
        spaceSize.width - widgetSize.width - windowPadding.right - spacing;
    final bottom =
        spaceSize.height - widgetSize.height - windowPadding.bottom - spacing;

    switch (corner) {
      case PIPViewCorner.topLeft:
        return Offset(left, top);
      case PIPViewCorner.topRight:
        return Offset(right, top);
      case PIPViewCorner.bottomLeft:
        return Offset(left, bottom);
      case PIPViewCorner.bottomRight:
        return Offset(right, bottom);
      default:
        throw UnimplementedError();
    }
  }

  final corners = PIPViewCorner.values;
  final Map<PIPViewCorner, Offset> offsets = {};
  for (final corner in corners) {
    offsets[corner] = getOffsetForCorner(corner);
  }

  return offsets;
}
