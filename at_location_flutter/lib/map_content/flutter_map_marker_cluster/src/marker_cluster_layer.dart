import 'dart:math';
import 'package:at_location_flutter/map_content/flutter_map/src/core/center_zoom.dart';
import 'package:flutter/material.dart';
import 'package:at_location_flutter/map_content/flutter_map/flutter_map.dart';
import 'package:at_location_flutter/map_content/flutter_map/src/core/bounds.dart';
import 'package:at_location_flutter/map_content/flutter_map/src/map/map.dart';
import 'package:at_location_flutter/map_content/flutter_map_marker_cluster/src/marker_cluster_layer_options.dart';
import 'package:at_location_flutter/map_content/flutter_map_marker_popup/src/marker_popup.dart';
import 'package:at_location_flutter/map_content/flutter_map_marker_cluster/src/anim_type.dart';
import 'package:at_location_flutter/map_content/flutter_map_marker_cluster/src/core/distance_grid.dart';
import 'package:at_location_flutter/map_content/flutter_map_marker_cluster/src/core/quick_hull.dart';
import 'package:at_location_flutter/map_content/flutter_map_marker_cluster/src/core/spiderfy.dart';
import 'package:at_location_flutter/map_content/flutter_map_marker_cluster/src/node/marker_cluster_node.dart';
import 'package:at_location_flutter/map_content/flutter_map_marker_cluster/src/node/marker_node.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:latlong2/latlong.dart';

class MarkerClusterLayer extends StatefulWidget {
  final MarkerClusterLayerOptions options;
  final MapState? map;
  final Stream<void> stream;

  MarkerClusterLayer(this.options, this.map, this.stream, Key key);

  @override
  _MarkerClusterLayerState createState() => _MarkerClusterLayerState();
}

class _MarkerClusterLayerState extends State<MarkerClusterLayer> with TickerProviderStateMixin {
  final Map<int, DistanceGrid<MarkerClusterNode>> _gridClusters = <int, DistanceGrid<MarkerClusterNode>>{};
  final Map<int, DistanceGrid<MarkerNode>> _gridUnclustered = <int, DistanceGrid<MarkerNode>>{};
  late MarkerClusterNode _topClusterLevel;
  int? _maxZoom;
  late int _minZoom;
  int? _currentZoom;
  int? _previousZoom;
  double? _previousZoomDouble;
  AnimationController? _zoomController;
  AnimationController? _fitBoundController;
  AnimationController? _centerMarkerController;
  AnimationController? _spiderfyController;
  MarkerClusterNode? _spiderfyCluster;
  PolygonLayer? _polygon;

  _MarkerClusterLayerState();

  CustomPoint<num> _getPixelFromPoint(LatLng? point) {
    CustomPoint<num> pos = widget.map!.project(point);
    return pos.multiplyBy(widget.map!.getZoomScale(widget.map!.zoom, widget.map!.zoom)) - widget.map!.getPixelOrigin()!;
  }

  Point<num> _getPixelFromMarker(MarkerNode marker, [LatLng? customPoint]) {
    CustomPoint<num> pos = _getPixelFromPoint(customPoint ?? marker.point);
    return _removeAnchor(pos, marker.width, marker.height, marker.anchor);
  }

  Point<num> _getPixelFromCluster(MarkerClusterNode cluster, [LatLng? customPoint]) {
    CustomPoint<num> pos = _getPixelFromPoint(customPoint ?? cluster.point);

    Size size = getClusterSize(cluster);
    Anchor anchor = Anchor.forPos(widget.options.anchor, size.width, size.height);

    return _removeAnchor(pos, size.width, size.height, anchor);
  }

  Point<num> _removeAnchor(Point<num> pos, double width, double height, Anchor anchor) {
    double x = (pos.x - (width - anchor.left)).toDouble();
    double y = (pos.y - (height - anchor.top)).toDouble();
    return Point<num>(x, y);
  }

  void _initializeAnimationController() {
    _zoomController = AnimationController(
      vsync: this,
      duration: widget.options.animationsOptions.zoom,
    );

    _fitBoundController = AnimationController(
      vsync: this,
      duration: widget.options.animationsOptions.fitBound,
    );

    _centerMarkerController = AnimationController(
      vsync: this,
      duration: widget.options.animationsOptions.centerMarker,
    );

    _spiderfyController = AnimationController(
      vsync: this,
      duration: widget.options.animationsOptions.spiderfy,
    );
  }

  void _initializeClusters() {
    // set up DistanceGrids for each zoom
    for (int zoom = _maxZoom!; zoom >= _minZoom; zoom--) {
      _gridClusters[zoom] = DistanceGrid<MarkerClusterNode>(widget.options.maxClusterRadius);
      _gridUnclustered[zoom] = DistanceGrid< MarkerNode>(widget.options.maxClusterRadius);
    }

    _topClusterLevel = MarkerClusterNode(
      zoom: _minZoom - 1,
      map: widget.map,
    );
  }

  void _addLayer(MarkerNode marker, int disableClusteringAtZoom) {
    for (int zoom = _maxZoom!; zoom >= _minZoom; zoom--) {
      CustomPoint<num> markerPoint = widget.map!.project(marker.point, zoom.toDouble());
      if (zoom <= disableClusteringAtZoom) {
        // try find a cluster close by
        MarkerClusterNode? cluster = _gridClusters[zoom]!.getNearObject(markerPoint);
        if (cluster != null) {
          cluster.addChild(marker);
          return;
        }

        MarkerNode? closest = _gridUnclustered[zoom]!.getNearObject(markerPoint);
        if (closest != null) {
          MarkerClusterNode parent = closest.parent!;
          parent.removeChild(closest);

          MarkerClusterNode newCluster = MarkerClusterNode(zoom: zoom, map: widget.map)..addChild(closest)..addChild(marker);

          _gridClusters[zoom]!.addObject(newCluster, widget.map!.project(newCluster.point, zoom.toDouble()));

          //First create any new intermediate parent clusters that don't exist
          MarkerClusterNode lastParent = newCluster;
          for (int z = zoom - 1; z > parent.zoom; z--) {
            MarkerClusterNode newParent = MarkerClusterNode(
              zoom: z,
              map: widget.map,
            );
            newParent.addChild(lastParent);
            lastParent = newParent;
            _gridClusters[z]!.addObject(lastParent, widget.map!.project(closest.point, z.toDouble()));
          }
          parent.addChild(lastParent);

          _removeFromNewPosToMyPosGridUnclustered(closest, zoom);
          return;
        }
      }

      _gridUnclustered[zoom]!.addObject(marker, markerPoint);
    }

    //Didn't get in anything, add us to the top
    _topClusterLevel.addChild(marker);
  }

  void _addLayers() {
    for (Marker? marker in widget.options.markers) {
      if (marker != null) {
        _addLayer(MarkerNode(marker), widget.options.disableClusteringAtZoom);
      }
    }

    _topClusterLevel.recalculateBounds();
  }

  void _removeFromNewPosToMyPosGridUnclustered(MarkerNode marker, int zoom) {
    for (; zoom >= _minZoom; zoom--) {
      if (!_gridUnclustered[zoom]!.removeObject(marker)) {
        break;
      }
    }
  }

  Animation<double>? _fadeAnimation(AnimationController? controller, FadeType fade) {
    if (fade == FadeType.FadeIn) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(controller!);
    }
    if (fade == FadeType.FadeOut) {
      return Tween<double>(begin: 1.0, end: 0.0).animate(controller!);
    }

    return null;
  }

  Animation<Point<num>>? _translateAnimation(
      AnimationController? controller, TranslateType translate, Point<num> pos, Point<num>? newPos) {
    if (translate == TranslateType.FromNewPosToMyPos) {
      return Tween<Point<num>>(
        begin: Point<num>(newPos!.x, newPos.y),
        end: Point<num>(pos.x, pos.y),
      ).animate(controller!);
    }
    if (translate == TranslateType.FromMyPosToNewPos) {
      return Tween<Point<num>>(
        begin: Point<num>(pos.x, pos.y),
        end: Point<num>(newPos!.x, newPos.y),
      ).animate(controller!);
    }

    return null;
  }

  Widget _buildMarker(MarkerNode marker, AnimationController controller,
      [FadeType fade = FadeType.None, TranslateType translate = TranslateType.None, Point<num>? newPos, Point<num>? myPos]) {
    assert((translate == TranslateType.None && newPos == null) || (translate != TranslateType.None && newPos != null));

    Point<num> pos = myPos ?? _getPixelFromMarker(marker);

    Animation<double>? fadeAnimation = _fadeAnimation(controller, fade);
    Animation<Point<num>>? translateAnimation = _translateAnimation(controller, translate, pos, newPos);

    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        return Positioned(
          width: marker.width,
          height: marker.height,
          left: translate == TranslateType.None ? pos.x.toDouble() : translateAnimation!.value.x.toDouble(),
          top: translate == TranslateType.None ? pos.y.toDouble() : translateAnimation!.value.y.toDouble(),
          child: Opacity(
            opacity: fade == FadeType.None ? 1 : fadeAnimation!.value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onMarkerTap(marker),
        child: marker.builder(context),
      ),
    );
  }

  List<Widget> _buildSpiderfyCluster(MarkerClusterNode cluster, int? zoom) {
    Point<num> pos = _getPixelFromCluster(cluster);

    List<Point<num>> points = _generatePointSpiderfy(cluster.markers.length, _getPixelFromPoint(cluster.point));

    Animation<double> fadeAnimation = Tween<double>(begin: 1.0, end: 0.3).animate(_spiderfyController!);

    List<Widget> results = <Widget>[];

    Size size = getClusterSize(cluster);

    results.add(
      AnimatedBuilder(
        animation: _spiderfyController!,
        builder: (BuildContext context, Widget? child) {
          return Positioned(
            width: size.width,
            height: size.height,
            left: pos.x.toDouble(),
            top: pos.y.toDouble(),
            child: Opacity(
              opacity: fadeAnimation.value,
              child: child,
            ),
          );
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _onClusterTap(cluster),
          child: widget.options.builder!(
            context,
            cluster.markers.map((MarkerNode node) => node.marker).toList(),
          ),
        ),
      ),
    );

    for (int i = 0; i < cluster.markers.length; i++) {
      MarkerNode marker = cluster.markers[i];

      results.add(_buildMarker(
          marker,
          _spiderfyController!,
          FadeType.FadeIn,
          TranslateType.FromMyPosToNewPos,
          _removeAnchor(points[i], marker.width, marker.height, marker.anchor),
          _getPixelFromMarker(marker, cluster.point)));
    }

    return results;
  }

  List<Marker?> getClusterMarkers(MarkerClusterNode cluster) => cluster.markers.map((MarkerNode node) => node.marker).toList();

  Size getClusterSize(MarkerClusterNode cluster) =>
      //// Removed because of nulls safety
      // widget.options?.computeSize == null
      //     ? widget.options.size
      //     : widget.options.computeSize!(getClusterMarkers(cluster));
      widget.options.computeSize == null
          ? widget.options.size
          : widget.options.computeSize!(getClusterMarkers(cluster));

  Widget _buildCluster(MarkerClusterNode cluster,
      [FadeType fade = FadeType.None, TranslateType translate = TranslateType.None, Point<num>? newPos]) {
    assert((translate == TranslateType.None && newPos == null) || (translate != TranslateType.None && newPos != null));

    Point<num> pos = _getPixelFromCluster(cluster);

    Animation<double>? fadeAnimation = _fadeAnimation(_zoomController, fade);
    Animation<Point<num>>? translateAnimation = _translateAnimation(_zoomController, translate, pos, newPos);

    Size size = getClusterSize(cluster);

    return AnimatedBuilder(
      animation: _zoomController!,
      builder: (BuildContext context, Widget? child) {
        return Positioned(
          width: size.width,
          height: size.height,
          left: translate == TranslateType.None ? pos.x.toDouble() : translateAnimation!.value.x.toDouble(),
          top: translate == TranslateType.None ? pos.y.toDouble() : translateAnimation!.value.y.toDouble(),
          child: Opacity(
            opacity: fade == FadeType.None ? 1 : fadeAnimation!.value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onClusterTap(cluster),
        child: widget.options.builder!(
          context,
          getClusterMarkers(cluster),
        ),
      ),
    );
  }

  void _spiderfy(MarkerClusterNode cluster) {
    if (_spiderfyCluster != null) {
      _unspiderfy();
      return;
    }

    setState(() {
      _spiderfyCluster = cluster;
    });
    _spiderfyController!.forward();
  }

  void _unspiderfy() {
    switch (_spiderfyController!.status) {
      case AnimationStatus.completed:
        List<Marker> markersGettingClustered = _spiderfyCluster!.markers.map((MarkerNode markerNode) => markerNode.marker).toList();

        _spiderfyController!.reverse().then((_) => setState(() {
              _spiderfyCluster = null;
            }));

        if (widget.options.popupOptions != null) {
          widget.options.popupOptions!.popupController!.hidePopupIfShowingFor(markersGettingClustered);
        }
        if (widget.options.onMarkersClustered != null) {
          widget.options.onMarkersClustered!(markersGettingClustered);
        }
        break;
      case AnimationStatus.forward:
        List<Marker> markersGettingClustered = _spiderfyCluster!.markers.map((MarkerNode markerNode) => markerNode.marker).toList();

        _spiderfyController!
          ..stop()
          ..reverse().then((_) => setState(() {
                _spiderfyCluster = null;
              }));

        if (widget.options.popupOptions != null) {
          widget.options.popupOptions!.popupController!.hidePopupIfShowingFor(markersGettingClustered);
        }
        if (widget.options.onMarkersClustered != null) {
          widget.options.onMarkersClustered!(markersGettingClustered);
        }
        break;
      default:
        break;
    }
  }

  bool _boundsContainsMarker(MarkerNode marker) {
    CustomPoint<num> pixelPoint = widget.map!.project(marker.point);

    double width = marker.width - marker.anchor.left;
    double height = marker.height - marker.anchor.top;

    CustomPoint<num> sw = CustomPoint<num>(pixelPoint.x + width, pixelPoint.y - height);
    CustomPoint<num> ne = CustomPoint<num>(pixelPoint.x - width, pixelPoint.y + height);
    return widget.map!.pixelBounds!.containsPartialBounds(Bounds<num>(sw, ne));
  }

  bool _boundsContainsCluster(MarkerClusterNode cluster) {
    CustomPoint<num> pixelPoint = widget.map!.project(cluster.point);

    Size size = getClusterSize(cluster);
    Anchor anchor = Anchor.forPos(widget.options.anchor, size.width, size.height);

    double width = size.width - anchor.left;
    double height = size.height - anchor.top;

    CustomPoint<num> sw = CustomPoint<num>(pixelPoint.x + width, pixelPoint.y - height);
    CustomPoint<num> ne = CustomPoint<num>(pixelPoint.x - width, pixelPoint.y + height);
    return widget.map!.pixelBounds!.containsPartialBounds(Bounds<num>(sw, ne));
  }

  List<Widget> _buildLayer(dynamic layer) {
    List<Widget> layers = <Widget>[];

    if (layer is MarkerNode) {
      if (!_boundsContainsMarker(layer)) {
        return <Widget>[];
      }

      // fade in if
      // animating and
      // zoom in and parent has the previous zoom
      if (_zoomController!.isAnimating && (_currentZoom! > _previousZoom! && layer.parent!.zoom == _previousZoom)) {
        // marker
        layers.add(_buildMarker(layer, _zoomController!, FadeType.FadeIn, TranslateType.FromNewPosToMyPos,
            _getPixelFromMarker(layer, layer.parent!.point)));
        //parent
        layers.add(_buildCluster(layer.parent!, FadeType.FadeOut));
      } else {
        layers.add(_buildMarker(layer, _zoomController!));
      }
    }
    if (layer is MarkerClusterNode) {
      if (!_boundsContainsCluster(layer)) {
        return <Widget>[];
      }

      // fade in if
      // animating and
      // zoom out and children is more than one or zoom in and father has same point
      if (_zoomController!.isAnimating && (_currentZoom! < _previousZoom! && layer.children.length > 1)) {
        // cluster
        layers.add(_buildCluster(layer, FadeType.FadeIn));
        // children
        List<Marker?> markersGettingClustered = <Marker?>[];
        for(dynamic child in layer.children) {
          if (child is MarkerNode) {
            markersGettingClustered.add(child.marker);

            layers.add(_buildMarker(child, _zoomController!, FadeType.FadeOut, TranslateType.FromMyPosToNewPos,
                _getPixelFromMarker(child, layer.point)));
          } else {
            layers.add(_buildCluster(
                child, FadeType.FadeOut, TranslateType.FromMyPosToNewPos, _getPixelFromCluster(child, layer.point)));
          }
        }

        if (widget.options.popupOptions != null) {
          widget.options.popupOptions!.popupController!.hidePopupIfShowingFor(markersGettingClustered);
        }
        if (widget.options.onMarkersClustered != null) {
          widget.options.onMarkersClustered!(markersGettingClustered);
        }
      } else if (_zoomController!.isAnimating &&
          (_currentZoom! > _previousZoom! && layer.parent!.point != layer.point)) {
        // cluster
        layers.add(_buildCluster(
            layer, FadeType.FadeIn, TranslateType.FromNewPosToMyPos, _getPixelFromCluster(layer, layer.parent!.point)));
        //parent
        layers.add(_buildCluster(layer.parent!, FadeType.FadeOut));
      } else {
        if (_isSpiderfyCluster(layer)) {
          layers.addAll(_buildSpiderfyCluster(layer, _currentZoom));
        } else {
          layers.add(_buildCluster(layer));
        }
      }
    }

    return layers;
  }

  List<Widget> _buildLayers() {
    if (widget.map!.zoom != _previousZoomDouble) {
      _previousZoomDouble = widget.map!.zoom;

      _unspiderfy();
    }

    int zoom = widget.map!.zoom.ceil();

    List<Widget> layers = <Widget>[];

    if (_polygon != null) layers.add(_polygon!);

    if (zoom < _currentZoom! || zoom > _currentZoom!) {
      _previousZoom = _currentZoom;
      _currentZoom = zoom;

      _zoomController!
        ..reset()
        ..forward().then((_) => setState(_hidePolygon)); // for remove previous layer (animation)
    }

    _topClusterLevel.recursively(_currentZoom, widget.options.disableClusteringAtZoom, (dynamic layer) {
      layers.addAll(_buildLayer(layer));
    });

    PopupOptions? popupOptions = widget.options.popupOptions;
    if (popupOptions != null) {
      layers.add(
        MarkerPopup(
          mapState: widget.map,
          popupController: popupOptions.popupController,
          snap: popupOptions.popupSnap,
          popupBuilder: popupOptions.popupBuilder,
        ),
      );
    }

    return layers;
  }

  bool _isSpiderfyCluster(MarkerClusterNode cluster) {
    return _spiderfyCluster != null && _spiderfyCluster!.point == cluster.point;
  }

  Function _onClusterTap(MarkerClusterNode cluster) {
    return () {
      if (_zoomController!.isAnimating ||
          _centerMarkerController!.isAnimating ||
          _fitBoundController!.isAnimating ||
          _spiderfyController!.isAnimating) {
        return null;
      }

      // This is handled as an optional callback rather than leaving the package
      // user to wrap their cluster Marker child Widget in a GestureDetector as only one
      // GestureDetector gets triggered per gesture (usually the child one) and
      // therefore this _onClusterTap() function never gets called.
      if (widget.options.onClusterTap != null) {
        widget.options.onClusterTap!(cluster);
      }

      // check if children can un-cluster
      bool cannotDivide = cluster.markers
          .every((MarkerNode marker) => marker.parent!.zoom == _maxZoom && marker.parent == cluster.markers[0].parent);
      if (cannotDivide) {
        _spiderfy(cluster);
        return null;
      }

      if (!widget.options.zoomToBoundsOnClick) return null;

      _showPolygon(cluster.markers.fold<List<LatLng>>(<LatLng>[], (List<LatLng> result, MarkerNode marker) => result..add(marker.point)));

      LatLng center = widget.map!.center!;
      CenterZoom dest = widget.map!.getBoundsCenterZoom(cluster.bounds, widget.options.fitBoundsOptions);

      Tween<double> _latTween = Tween<double>(begin: center.latitude, end: dest.center!.latitude);
      Tween<double> _lngTween = Tween<double>(begin: center.longitude, end: dest.center!.longitude);
      Tween<double> _zoomTween = Tween<double>(begin: _currentZoom!.toDouble(), end: dest.zoom);

      Animation<double> animation =
          CurvedAnimation(parent: _fitBoundController!, curve: widget.options.animationsOptions.fitBoundCurves);

       void listener() => widget.map!.move(
          LatLng(_latTween.evaluate(animation), _lngTween.evaluate(animation)),
          _zoomTween.evaluate(animation),
        );

      _fitBoundController!.addListener(listener);

      _fitBoundController!.forward().then((_) {
        _fitBoundController!
          ..removeListener(listener)
          ..reset();
      });
    };
  }

  void _showPolygon(List<LatLng> points) {
    if (widget.options.showPolygon) {
      setState(() {
        _polygon = PolygonLayer(
          PolygonLayerOptions(polygons: <Polygon>[
            Polygon(
              points: QuickHull.getConvexHull(points),
              borderStrokeWidth: widget.options.polygonOptions.borderStrokeWidth,
              color: widget.options.polygonOptions.color,
              borderColor: widget.options.polygonOptions.borderColor,
              isDotted: widget.options.polygonOptions.isDotted,
            ),
          ]),
          widget.map,
          widget.stream,
        );
      });
    }
  }

  void _hidePolygon() {
    if (widget.options.showPolygon) {
      setState(() {
        _polygon = null;
      });
    }
  }

  Function _onMarkerTap(MarkerNode marker) {
    return () {
      if (_zoomController!.isAnimating || _centerMarkerController!.isAnimating || _fitBoundController!.isAnimating) {
        return null;
      }

      if (widget.options.popupOptions != null) {
        widget.options.popupOptions!.popupController!.togglePopup(marker.marker);
      }

      // This is handled as an optional callback rather than leaving the package
      // user to wrap their Marker child Widget in a GestureDetector as only one
      // GestureDetector gets triggered per gesture (usually the child one) and
      // therefore this _onMarkerTap function never gets called.
      if (widget.options.onMarkerTap != null) {
        widget.options.onMarkerTap!(marker.marker);
      }

      if (!widget.options.centerMarkerOnClick) return null;

      LatLng center = widget.map!.center!;

      Tween<double> _latTween = Tween<double>(begin: center.latitude, end: marker.point.latitude);
      Tween<double> _lngTween = Tween<double>(begin: center.longitude, end: marker.point.longitude);

      Animation<double> animation =
          CurvedAnimation(parent: _centerMarkerController!, curve: widget.options.animationsOptions.centerMarkerCurves);

      void listener() {
        widget.map!.move(
          LatLng(_latTween.evaluate(animation), _lngTween.evaluate(animation)),
          widget.map!.zoom,
        );
      }

      _centerMarkerController!.addListener(listener);

      _centerMarkerController!.forward().then((_) {
        _centerMarkerController!
          ..removeListener(listener)
          ..reset();
      });
    };
  }

  List<Point<num>> _generatePointSpiderfy(int count, Point<num> center) {
    if (widget.options.spiderfyShapePositions != null) {
      return widget.options.spiderfyShapePositions!(count, center);
    }
    if (count >= widget.options.circleSpiralSwitchover) {
      return Spiderfy.spiral(widget.options.spiderfySpiralDistanceMultiplier, count, center);
    }

    return Spiderfy.circle(widget.options.spiderfyCircleRadius, count, center);
  }

  @override
  void initState() {
    _currentZoom = _previousZoom = widget.map!.zoom.ceil();
    _minZoom = widget.map!.options.minZoom?.ceil() ?? 1;
    _maxZoom = widget.map!.options.maxZoom?.floor() ?? 20;

    _initializeAnimationController();
    _initializeClusters();
    _addLayers();

    _zoomController!.forward();

    super.initState();
  }

  @override
  void dispose() {
    _zoomController!.dispose();
    _fitBoundController!.dispose();
    _centerMarkerController!.dispose();
    _spiderfyController!.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MarkerClusterLayer oldWidget) {
    if (oldWidget.options.markers != widget.options.markers) {
      _initializeClusters();
      _addLayers();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<void>(
      stream: widget.stream, // a Stream<void> or null
      builder: (BuildContext context, _) {
        return Container(
          child: Stack(
            children: _buildLayers(),
          ),
        );
      },
    );
  }
}
