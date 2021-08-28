import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:at_location_flutter/map_content/flutter_map/flutter_map.dart';
import 'package:at_location_flutter/map_content/flutter_map/src/core/bounds.dart';
import 'package:at_location_flutter/map_content/flutter_map/src/core/center_zoom.dart';
import 'package:at_location_flutter/map_content/flutter_map/src/core/point.dart';
import 'package:at_location_flutter/map_content/flutter_map/src/map/map_state_widget.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:latlong2/latlong.dart';

class MapControllerImpl implements MapController {
  final Completer<void> _readyCompleter = Completer<void>();
  MapState? _state;

  @override
  Future<void>  get onReady => _readyCompleter.future;

  set state(MapState? state) {
    _state = state;
    if (!_readyCompleter.isCompleted) {
      _readyCompleter.complete();
    }
  }

  @override
  void move(LatLng? center, double zoom, {bool hasGesture = false}) {
    _state!.move(center, zoom, hasGesture: hasGesture);
  }

  @override
  void fitBounds(
    LatLngBounds bounds, {
    FitBoundsOptions? options =
        const FitBoundsOptions(padding: EdgeInsets.all(12.0)),
  }) {
    _state!.fitBounds(bounds, options!);
  }

  @override
  bool get ready => _state != null;

  @override
  LatLng? get center => _state!.center;

  @override
  LatLngBounds? get bounds => _state!.bounds;

  @override
  double get zoom => _state!.zoom;

  @override
  void rotate(double degree) {
    _state!.rotation = degree;
    if (onRotationChanged != null) onRotationChanged!(degree);
  }

  @override
  ValueChanged<double>? onRotationChanged;

  @override
  Stream<MapPosition> get position => _state!._positionSink.stream;
}

class MapState {
  MapOptions options;
  final StreamController<void> _onMoveSink;
  final StreamController<MapPosition> _positionSink;

  double _zoom;
  double rotation;

  double get zoom => _zoom;

  LatLng? _lastCenter;
  LatLngBounds? _lastBounds;
  Bounds<num>? _lastPixelBounds;
  CustomPoint<num>? _pixelOrigin;
  bool _initialized = false;

  MapState(this.options)
      : rotation = options.rotation,
        _zoom = options.zoom,
        _onMoveSink = StreamController<void>.broadcast(),
        _positionSink = StreamController<MapPosition>.broadcast();

  CustomPoint<num>? _size;

  Stream<void> get onMoved => _onMoveSink.stream;

  CustomPoint<num>? get size => _size;

  set size(CustomPoint<num>? s) {
    _size = s;
    if (!_initialized) {
      _init();
      _initialized = true;
    }
    _pixelOrigin = getNewPixelOrigin(_lastCenter);
  }

  LatLng? get center => getCenter() ?? options.center;

  LatLngBounds? get bounds => getBounds();

  Bounds<num>? get pixelBounds => getLastPixelBounds();

  void _init() {
    if (options.bounds != null) {
      fitBounds(options.bounds!, options.boundsOptions);
    } else {
      move(options.center, zoom);
    }
  }

  void dispose() {
    _onMoveSink.close();
  }

  void forceRebuild() {
    _onMoveSink.add(null);
  }

  void move(LatLng? center, double? zoom, {bool hasGesture = false}) {
    zoom = fitZoomToBounds(zoom);
    bool mapMoved = center != _lastCenter || zoom != _zoom;

    if (_lastCenter != null && (!mapMoved || !bounds!.isValid)) {
      return;
    }

    if (options.isOutOfBounds(center)) {
      if (!options.slideOnBoundaries) {
        return;
      }
      center = options.containPoint(center, _lastCenter ?? center);
    }

    MapPosition mapPosition = MapPosition(
        center: center, bounds: bounds, zoom: zoom, hasGesture: hasGesture);

    _zoom = zoom;
    _lastCenter = center;
    _lastPixelBounds = getPixelBounds(_zoom);
    _lastBounds = _calculateBounds();
    _pixelOrigin = getNewPixelOrigin(center);
    _onMoveSink.add(null);
    _positionSink.add(mapPosition);

    if (options.onPositionChanged != null) {
      options.onPositionChanged!(mapPosition, hasGesture);
    }
  }

  double fitZoomToBounds(double? zoom) {
    zoom ??= _zoom;
    // Abide to min/max zoom
    if (options.maxZoom != null) {
      zoom = (zoom > options.maxZoom!) ? options.maxZoom! : zoom;
    }
    if (options.minZoom != null) {
      zoom = (zoom < options.minZoom!) ? options.minZoom! : zoom;
    }
    return zoom;
  }

  void fitBounds(LatLngBounds bounds, FitBoundsOptions options) {
    if (!bounds.isValid) {
      throw Exception('Bounds are not valid.');
    }
    CenterZoom target = getBoundsCenterZoom(bounds, options);
    move(target.center, target.zoom);
  }

  LatLng? getCenter() {
    if (_lastCenter != null) {
      return _lastCenter;
    }
    return layerPointToLatLng(_centerLayerPoint);
  }

  LatLngBounds? getBounds() {
    if (_lastBounds != null) {
      return _lastBounds;
    }

    return _calculateBounds();
  }

  Bounds<num>? getLastPixelBounds() {
    if (_lastPixelBounds != null) {
      return _lastPixelBounds;
    }

    return getPixelBounds(zoom);
  }

  LatLngBounds _calculateBounds() {
    Bounds<num> bounds = getLastPixelBounds()!;
    return LatLngBounds(
      unproject(bounds.bottomLeft),
      unproject(bounds.topRight),
    );
  }

  CenterZoom getBoundsCenterZoom(
      LatLngBounds bounds, FitBoundsOptions options) {
    CustomPoint<double> paddingTL =
        CustomPoint<double>(options.padding.left, options.padding.top);
    CustomPoint<double> paddingBR =
        CustomPoint<double>(options.padding.right, options.padding.bottom);

    CustomPoint<double> paddingTotalXY = paddingTL + paddingBR;

    double zoom = getBoundsZoom(bounds, paddingTotalXY, inside: false);
    zoom = math.min(options.maxZoom, zoom);

    CustomPoint<double> paddingOffset = (paddingBR - paddingTL) / 2;
    CustomPoint<num> swPoint = project(bounds.southWest, zoom);
    CustomPoint<num> nePoint = project(bounds.northEast, zoom);
    LatLng? center = unproject((swPoint + nePoint) / 2 + paddingOffset, zoom);
    return CenterZoom(
      center: center,
      zoom: zoom,
    );
  }

  double getBoundsZoom(LatLngBounds bounds, CustomPoint<double> padding,
      {bool inside = false}) {
    //// Removed because of nulls safety
    // var zoom = this.zoom ?? 0.0;
    double zoom = this.zoom;
    double min = options.minZoom ?? 0.0;
    double max = options.maxZoom ?? double.infinity;
    LatLng nw = bounds.northWest;
    LatLng se = bounds.southEast;
    CustomPoint<num> size = this.size! - padding;
    // Prevent negative size which results in NaN zoom value later on in the calculation
    size = CustomPoint<num>(math.max(0, size.x), math.max(0, size.y));
    CustomPoint<num> boundsSize = Bounds<num>(project(se, zoom), project(nw, zoom)).size;
    double scaleX = size.x / boundsSize.x;
    double scaleY = size.y / boundsSize.y;
    double scale = inside ? math.max(scaleX, scaleY) : math.min(scaleX, scaleY);

    zoom = getScaleZoom(scale, zoom);

    return math.max(min, math.min(max, zoom));
  }

  CustomPoint<num> project(LatLng? latlng, [double? zoom]) {
    zoom ??= _zoom;
    return options.crs.latLngToPoint(latlng, zoom);
  }

  LatLng? unproject(CustomPoint<num> point, [double? zoom]) {
    zoom ??= _zoom;
    return options.crs.pointToLatLng(point, zoom);
  }

  LatLng? layerPointToLatLng(CustomPoint<num> point) {
    return unproject(point);
  }

  CustomPoint<num> get _centerLayerPoint {
    return size! / 2;
  }

  double getZoomScale(double toZoom, double? fromZoom) {
    Crs crs = options.crs;
    fromZoom = fromZoom ?? _zoom;
    return crs.scale(toZoom)! / crs.scale(fromZoom)!;
  }

  double getScaleZoom(double scale, double fromZoom) {
    Crs crs = options.crs;
    //// Removed because of nulls safety
    // fromZoom = fromZoom ?? _zoom;
    fromZoom = fromZoom;
    return crs.zoom(scale * crs.scale(fromZoom)!).toDouble();
  }

  Bounds<num>? getPixelWorldBounds(double? zoom) {
    return options.crs.getProjectedBounds(zoom ?? _zoom);
  }

  CustomPoint<num>? getPixelOrigin() {
    return _pixelOrigin;
  }

  CustomPoint<num> getNewPixelOrigin(LatLng? center, [double? zoom]) {
    CustomPoint<num> viewHalf = size! / 2.0;
    return (project(center, zoom) - viewHalf).round();
  }

  Bounds<num> getPixelBounds(double zoom) {
    double mapZoom = zoom;
    double scale = getZoomScale(mapZoom, zoom);
    CustomPoint<num> pixelCenter = project(center, zoom).floor();
    CustomPoint<num> halfSize = size! / (scale * 2);
    return Bounds<num>(pixelCenter - halfSize, pixelCenter + halfSize);
  }

  static MapState? of(BuildContext context, {bool nullOk = false}) {
    // ignore: unnecessary_null_comparison
    assert(context != null);
    // ignore: unnecessary_null_comparison
    assert(nullOk != null);
    MapStateInheritedWidget? widget =
        context.dependOnInheritedWidgetOfExactType<MapStateInheritedWidget>();
    if (nullOk || widget != null) {
      return widget?.mapState;
    }
    throw FlutterError(
        'MapState.of() called with a context that does not contain a FlutterMap.');
  }
}
