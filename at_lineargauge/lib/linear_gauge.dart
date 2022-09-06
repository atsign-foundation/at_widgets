import 'package:flutter/material.dart';
import 'package:linear_gauge/utils.dart';

// ignore: must_be_immutable
class LinearGauge extends StatefulWidget {
  ///fraction value
  late final double currentValue;

  // Width of the linear_gauge
  final double? width;

  //Controls the orientation of the gauge
  late final GaugeOrientation orientation;

  // Max number to reach
  final double maxValue;

  // Minimum number to start
  final double minValue;

  // The number of division that gauge will be divided into
  final int divisions;

  //The number if subdivision that gauge will be divided into
  final int subDivisions;

  ///Height of the line
  final double gaugeHeight;

  ///Color of the background of the Line , default = transparent
  final Color barColor;

  ///First color applied to the complete the gauge
  Color get backgroundColor => _backgroundColor;
  late Color _backgroundColor;

  Color get progressColor => _progressColor;

  late Color _progressColor;

  ///true if you want the Line to have animation
  final bool animation;

  ///duration of the animation in milliseconds, It only applies if animation attribute is true
  final int animationDuration;

  ///widget inside the gauge status
  final Widget? gaugeStatus;

  /// The border radius of the gauge
  final Radius? barRadius;

  ///alignment of the Row
  final MainAxisAlignment alignment;

  ///padding to the LinearGauge
  final EdgeInsets padding;

  /// set false if you don't want to preserve the state of the widget
  final bool addAutomaticKeepAlive;

  /// set a linear curve animation type
  final Curve curve;

  /// set true when you want to restart the animation
  /// defaults to false
  final bool restartAnimation;

  /// Callback called when the animation ends (only if `animation` is true)
  final VoidCallback? onAnimationEnd;

  /// Display a widget indicator at the end of the progress. It only works when `animation` is true
  final Widget? widgetIndicator;

  LinearGauge({
    Key? key,
    this.barColor = Colors.transparent,
    this.currentValue = 0.0,
    this.gaugeHeight = 5.0,
    this.width,
    Color? backgroundColor,
    Color? progressColor,
    this.animation = false,
    this.animationDuration = 500,
    this.gaugeStatus,
    this.addAutomaticKeepAlive = true,
    this.barRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 10.0),
    this.alignment = MainAxisAlignment.start,
    this.curve = Curves.linear,
    this.restartAnimation = false,
    this.onAnimationEnd,
    this.widgetIndicator,
    required this.orientation,
    this.maxValue = 100.0,
    this.minValue = 0.0,
    required this.divisions,
    required this.subDivisions,
  }) : super(key: key) {
    _progressColor = progressColor ?? Colors.deepOrangeAccent;
    _backgroundColor = backgroundColor ?? const Color(0xFFB8C7CB);
    if (currentValue < minValue || currentValue > maxValue) {
      throw Exception("Current Value limit Exceeded");
    }
  }

  @override
  // ignore: library_private_types_in_public_api
  _LinearGaugeState createState() => _LinearGaugeState();
}

class _LinearGaugeState extends State<LinearGauge>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  AnimationController? _animationController;
  Animation? _animation;
  double _fraction = 0.0;
  final _wholeContainerKey = GlobalKey();
  final _indicatorKey = GlobalKey();
  double _wholeContainerWidth = 0.0;
  double _wholeContainerHeight = 0.0;
  double _indicatorWidth = 0.0;
  double _indicatorHeight = 0.0;

  final double subDivisionThickness = 1;
  final Color primaryColor = const Color(0xFFE9E9E9);
  final Color secondaryColor = const Color(0xFFBCC5C8);

  final double value = 4672;

  Widget parentWidgetBasedOnOrientation() {
    return SizedBox(
      width: _wholeContainerWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _parentWidgetsChildren(),
      ),
    );
  }

  List<Widget> _parentWidgetsChildren() {
    /// used to display the actual value of at an index
    final double multiplier =
        (widget.maxValue) / (widget.divisions * widget.subDivisions);
    final double valueWidth =
        (_wholeContainerWidth / (widget.maxValue) * value);

    /// number of lines that fall behind the value * thickness of one subDivision
    final double valueWidthAdditionalThickness = ((value /
                (widget.maxValue / (widget.divisions * widget.subDivisions))) -
            1) *
        subDivisionThickness;

    return [
      const SizedBox(
        height: 2,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _childWidgetsChildren(multiplier),
      )
    ];
  }

  List<Widget> _childWidgetsChildren(double multiplier) {
    return List.generate(widget.divisions * widget.subDivisions, (index) {
      /// only for last index
      if (index == ((widget.divisions * widget.subDivisions) - 1)) {
        return majorSubDivision(((index + 1) * multiplier).ceil());
      }

      if (index % widget.subDivisions == 0) {
        /// if 0 (1st index) then send 0
        return majorSubDivision(
            index == 0 ? widget.minValue.toInt() : (index * multiplier).ceil());
      }

      return minorSubDivision();
    });
  }

  Widget majorSubDivision(int index) {
    /// used Stack as we don't want the numbers to take size in the Row division

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 10,
          width: subDivisionThickness,
          decoration: BoxDecoration(
            color: secondaryColor,
          ),
        ),
        Positioned(
            bottom: 22, // 10(height) + 5(space)
            left: -7, // random value that looks correct
            child: Text('${index}')),
      ],
    );
  }

  Widget minorSubDivision() {
    return Container(
      height: 6,
      width: subDivisionThickness,
      decoration: BoxDecoration(
        color: primaryColor,
      ),
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _wholeContainerWidth =
              _wholeContainerKey.currentContext?.size?.width ?? 0.0;
          _wholeContainerHeight =
              _wholeContainerKey.currentContext?.size?.height ?? 0.0;
          if (_indicatorKey.currentContext != null) {
            _indicatorWidth = _indicatorKey.currentContext?.size?.width ?? 0.0;
            _indicatorHeight =
                _indicatorKey.currentContext?.size?.height ?? 0.0;
          }
        });
      }
    });
    if (widget.animation) {
      _animationController = AnimationController(
          vsync: this,
          duration: Duration(milliseconds: widget.animationDuration));
      _animation = Tween(begin: widget.minValue, end: widget.currentValue)
          .animate(
        CurvedAnimation(parent: _animationController!, curve: widget.curve),
      )..addListener(() {
          setState(() {
            _fraction =
                ((_animation!.value + widget.minValue.abs()) / widget.maxValue);
          });
          if (widget.restartAnimation && _fraction == 1.0) {
            _animationController!
                .repeat(min: widget.minValue, max: widget.maxValue);
          }
        });
      _animationController!.addStatusListener((status) {
        if (widget.onAnimationEnd != null &&
            status == AnimationStatus.completed) {
          widget.onAnimationEnd!();
        }
      });
      _animationController!.forward();
    } else {
      _updateProgress();
    }
    super.initState();
  }

  void _checkIfNeedCancelAnimation(LinearGauge oldWidget) {
    if (oldWidget.animation &&
        !widget.animation &&
        _animationController != null) {
      _animationController!.stop();
    }
  }

  @override
  void didUpdateWidget(LinearGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentValue != widget.currentValue) {
      if (_animationController != null) {
        _animationController!.duration =
            Duration(milliseconds: widget.animationDuration);
        _animation =
            Tween(begin: oldWidget.currentValue, end: widget.currentValue)
                .animate(
          CurvedAnimation(parent: _animationController!, curve: widget.curve),
        );
        _animationController!.forward(from: widget.minValue);
      } else {
        _updateProgress();
      }
    }
    _checkIfNeedCancelAnimation(oldWidget);
  }

  _updateProgress() {
    setState(() {
      _fraction =
          (widget.currentValue - widget.minValue.abs()) / widget.maxValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var items = List<Widget>.empty(growable: true);
    final hasSetWidth = widget.width != null;
    final percentPositionedHorizontal =
        _wholeContainerWidth * _fraction - _indicatorWidth / 1.9;

    var containerWidget = Container(
      width: hasSetWidth ? widget.width : double.infinity,
      height: widget.gaugeHeight,
      padding: widget.padding,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            key: _wholeContainerKey,
            painter: _LinearPainter(
              progress: _fraction,
              progressColor: widget.progressColor,
              backgroundColor: widget.backgroundColor,
              barRadius: widget.barRadius ?? Radius.zero,
            ),
            child: (widget.gaugeStatus != null)
                ? Center(child: widget.gaugeStatus)
                : Container(),
          ),
          if (widget.widgetIndicator != null && _indicatorWidth == 0)
            Opacity(
              opacity: 0.0,
              key: _indicatorKey,
              child: widget.widgetIndicator,
            ),
          if (widget.widgetIndicator != null &&
              _wholeContainerWidth > 0 &&
              _indicatorWidth > 0)
            Positioned(
              right: null,
              left: percentPositionedHorizontal,
              bottom: _wholeContainerHeight + .1,
              child: widget.widgetIndicator!,
            ),
          if (_wholeContainerWidth > 0)
            Positioned(
              bottom: _wholeContainerHeight,
              child: SizedBox(
                child: parentWidgetBasedOnOrientation(),
              ),
            ),
        ],
      ),
    );

    if (hasSetWidth) {
      items.add(containerWidget);
    } else {
      items.add(
        Expanded(child: containerWidget),
      );
    }

    return Material(
        color: Colors.transparent,
        child: widget.orientation == GaugeOrientation.vertical
            ? RotatedBox(
                quarterTurns: 1,
                child: Container(
                  color: widget.barColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: items,
                  ),
                ),
              )
            : Container(
                color: widget.barColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: items,
                ),
              ));
  }

  @override
  bool get wantKeepAlive => widget.addAutomaticKeepAlive;
}

class _LinearPainter extends CustomPainter {
  final Paint _paintBackground = Paint();
  final Paint _paintLine = Paint();
  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final Radius barRadius;

  _LinearPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    required this.barRadius,
  }) {
    _paintBackground.color = backgroundColor;

    _paintLine.color = progress.toString() == "0.0"
        ? progressColor.withOpacity(0.0)
        : progressColor;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Path backgroundPath = Path();
    backgroundPath.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height), barRadius));
    canvas.drawPath(backgroundPath, _paintBackground);
    canvas.clipPath(backgroundPath);

    final progressLine = size.width * progress;
    Path linePath = Path();

    linePath.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, progressLine, size.height), barRadius));

    canvas.drawPath(linePath, _paintLine);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
