import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:at_location_flutter/map_content/flutter_map/src/core/bounds.dart';
import 'package:at_location_flutter/map_content/flutter_map/src/core/point.dart';
import 'package:at_location_flutter/map_content/flutter_map/src/core/util.dart' as util;
import 'package:at_location_flutter/map_content/flutter_map/src/geo/crs/crs.dart';
import 'package:at_location_flutter/map_content/flutter_map/src/layer/tile_provider/tile_provider.dart';
import 'package:at_location_flutter/map_content/flutter_map/src/map/map.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:latlong2/latlong.dart';
import 'package:tuple/tuple.dart';

import 'layer.dart';

typedef ErrorTileCallBack = void Function(Tile? tile, dynamic error);

/// Describes the needed properties to create a tile-based layer.
/// A tile is an image bound to a specific geographical position.
class TileLayerOptions extends LayerOptions {
  // to execute a function when zoom changes
  // final Function fnWhenZoomChanges;

  /// Defines the structure to create the URLs for the tiles.
  /// `{s}` means one of the available subdomains (can be omitted)
  /// `{z}` zoom level
  /// `{x}` and `{y}` — tile coordinates
  /// `{r}` can be used to add "&commat;2x" to the URL to load retina tiles (can be omitted)
  ///
  /// Example:
  ///
  /// https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png
  ///
  /// Is translated to this:
  ///
  /// https://a.tile.openstreetmap.org/12/2177/1259.png
  final String? urlTemplate;

  /// If `true`, inverses Y axis numbering for tiles (turn this on for
  /// [TMS](https://en.wikipedia.org/wiki/Tile_Map_Service) services).
  final bool tms;

  /// If not `null`, then tiles will pull's WMS protocol requests
  final WMSTileLayerOptions? wmsOptions;

  /// Size for the tile.
  /// Default is 256
  final double tileSize;

  // The minimum zoom level down to which this layer will be
  // displayed (inclusive).
  final double minZoom;

  /// The maximum zoom level up to which this layer will be
  /// displayed (inclusive).
  /// In most tile providers goes from 0 to 19.
  final double maxZoom;

  /// Minimum zoom number the tile source has available. If it is specified,
  /// the tiles on all zoom levels lower than minNativeZoom will be loaded
  /// from minNativeZoom level and auto-scaled.
  final double? minNativeZoom;

  /// Maximum zoom number the tile source has available. If it is specified,
  /// the tiles on all zoom levels higher than maxNativeZoom will be loaded
  /// from maxNativeZoom level and auto-scaled.
  final double? maxNativeZoom;

  /// If set to true, the zoom number used in tile URLs will be reversed (`maxZoom - zoom` instead of `zoom`)
  final bool zoomReverse;

  /// The zoom number used in tile URLs will be offset with this value.
  final double zoomOffset;

  /// List of subdomains for the URL.
  ///
  /// Example:
  ///
  /// Subdomains = {a,b,c}
  ///
  /// and the URL is as follows:
  ///
  /// https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png
  ///
  /// then:
  ///
  /// https://a.tile.openstreetmap.org/{z}/{x}/{y}.png
  /// https://b.tile.openstreetmap.org/{z}/{x}/{y}.png
  /// https://c.tile.openstreetmap.org/{z}/{x}/{y}.png
  final List<String> subdomains;

  /// Color shown behind the tiles.
  final Color backgroundColor;

  /// Opacity of the rendered tile
  final double opacity;

  /// Provider to load the tiles. The default is CachedNetworkTileProvider,
  /// which loads tile images from network and caches them offline.
  ///
  /// If you don't want to cache the tiles, use NetworkTileProvider instead.
  ///
  /// In order to use images from the asset folder set this option to
  /// AssetTileProvider() Note that it requires the urlTemplate to target
  /// assets, for example:
  ///
  /// ```dart
  /// urlTemplate: "assets/map/anholt_osmbright/{z}/{x}/{y}.png",
  /// ```
  ///
  /// In order to use images from the filesystem set this option to
  /// FileTileProvider() Note that it requires the urlTemplate to target the
  /// file system, for example:
  ///
  /// ```dart
  /// urlTemplate: "/storage/emulated/0/tiles/some_place/{z}/{x}/{y}.png",
  /// ```
  ///
  /// Furthermore you create your custom implementation by subclassing
  /// TileProvider
  ///
  final TileProvider tileProvider;

  /// When panning the map, keep this many rows and columns of tiles before
  /// unloading them.
  final int keepBuffer;

  /// Placeholder to show until tile images are fetched by the provider.
  final ImageProvider? placeholderImage;

  /// Tile image to show in place of the tile that failed to load.
  final ImageProvider? errorImage;

  /// Static informations that should replace placeholders in the [urlTemplate].
  /// Applying API keys is a good example on how to use this parameter.
  ///
  /// Example:
  ///
  /// ```dart
  ///
  /// TileLayerOptions(
  ///     urlTemplate: "https://api.tiles.mapbox.com/v4/"
  ///                  "{id}/{z}/{x}/{y}{r}.png?access_token={accessToken}",
  ///     additionalOptions: {
  ///         'accessToken': '<PUT_ACCESS_TOKEN_HERE>',
  ///          'id': 'mapbox.streets',
  ///     },
  /// ),
  /// ```
  ///
  final Map<String, String> additionalOptions;

  /// Tiles will not update more than once every `updateInterval`
  /// (default 200 milliseconds) when panning.
  /// It can be null (but it will calculating for loading tiles every frame when panning / zooming, flutter is fast)
  /// This can save some fps and even bandwidth
  /// (ie. when fast panning / animating between long distances in short time)
  final Duration? updateInterval;

  /// Tiles fade in duration in milliseconds (default 100),
  /// it can be null to avoid fade in
  final Duration? tileFadeInDuration;

  /// Opacity start value when Tile starts fade in (0.0 - 1.0)
  /// Takes effect if `tileFadeInDuration` is not null
  final double tileFadeInStart;

  /// Opacity start value when an exists Tile starts fade in with different Url (0.0 - 1.0)
  /// Takes effect when `tileFadeInDuration` is not null and if `overrideTilesWhenUrlChanges` if true
  final double tileFadeInStartWhenOverride;

  /// `false`: current Tiles will be first dropped and then reload via new url (default)
  /// `true`: current Tiles will be visible until new ones aren't loaded (new Tiles are loaded independently)
  /// @see https://github.com/johnpryan/flutter_map/issues/583
  final bool overrideTilesWhenUrlChanges;

  /// If `true`, it will request four tiles of half the specified size and a
  /// bigger zoom level in place of one to utilize the high resolution.
  ///
  /// If `true` then MapOptions's `maxZoom` should be `maxZoom - 1` since retinaMode
  /// just simulates retina display by playing with `zoomOffset`.
  /// If geoserver supports retina `@2` tiles then it it advised to use them
  /// instead of simulating it (use {r} in the [urlTemplate])
  ///
  /// It is advised to use retinaMode if display supports it, write code like this:
  /// TileLayerOptions(
  ///     retinaMode: true && MediaQuery.of(context).devicePixelRatio > 1.0,
  /// ),
  final bool retinaMode;

  /// This callback will be execute if some errors by getting tile
  final ErrorTileCallBack? errorTileCallback;

  /// Whether or not to enable dark mode.
  final bool darkMode;

  TileLayerOptions({
    Key? key,
    // this.fnWhenZoomChanges,
    this.urlTemplate,
    double tileSize = 256.0,
    double minZoom = 0.0,
    double maxZoom = 18.0,
    this.minNativeZoom,
    this.maxNativeZoom,
    this.zoomReverse = false,
    double zoomOffset = 0.0,
    this.additionalOptions = const <String, String>{},
    this.subdomains = const <String>[],
    this.keepBuffer = 2,
    this.backgroundColor = const Color(0xFF86CCFA),
    this.placeholderImage,
    this.errorImage,
    this.tileProvider = const CachedNetworkTileProvider(),
    this.tms = false,
    // ignore: avoid_init_to_null
    this.wmsOptions = null,
    this.opacity = 1.0,
    // Tiles will not update more than once every `updateInterval` milliseconds
    // (default 200) when panning.
    // It can be 0 (but it will calculating for loading tiles every frame when panning / zooming, flutter is fast)
    // This can save some fps and even bandwidth
    // (ie. when fast panning / animating between long distances in short time)
    int updateInterval = 200,
    // Tiles fade in duration in milliseconds (default 100),
    // it can 0 to avoid fade in
    int tileFadeInDuration = 100,
    this.tileFadeInStart = 0.0,
    this.tileFadeInStartWhenOverride = 0.0,
    this.overrideTilesWhenUrlChanges = false,
    this.retinaMode = false,
    this.errorTileCallback,
    dynamic rebuild,
    this.darkMode = false,
  })  : updateInterval = updateInterval <= 0 ? null : Duration(milliseconds: updateInterval),
        tileFadeInDuration = tileFadeInDuration <= 0 ? null : Duration(milliseconds: tileFadeInDuration),
        assert(tileFadeInStart >= 0.0 && tileFadeInStart <= 1.0),
        assert(tileFadeInStartWhenOverride >= 0.0 && tileFadeInStartWhenOverride <= 1.0),
        maxZoom = wmsOptions == null && retinaMode && maxZoom > 0.0 && !zoomReverse ? maxZoom - 1.0 : maxZoom,
        minZoom =
            wmsOptions == null && retinaMode && maxZoom > 0.0 && zoomReverse ? math.max(minZoom + 1.0, 0.0) : minZoom,
        zoomOffset = wmsOptions == null && retinaMode && maxZoom > 0.0
            ? (zoomReverse ? zoomOffset - 1.0 : zoomOffset + 1.0)
            : zoomOffset,
        tileSize = wmsOptions == null && retinaMode && maxZoom > 0.0 ? (tileSize / 2.0).floorToDouble() : tileSize,
        super(key: key, rebuild: rebuild);
}

class WMSTileLayerOptions {
  final String service = 'WMS';
  final String request = 'GetMap';

  /// url of WMS service.
  /// Ex.: 'http://ows.mundialis.de/services/service?'
  final String baseUrl;

  /// list of WMS layers to show
  final List<String> layers;

  /// list of WMS styles
  final List<String> styles;

  /// WMS image format (use 'image/png' for layers with transparency)
  final String format;

  /// Version of the WMS service to use
  final String version;

  /// tile transperency flag
  final bool transparent;

  final Crs crs;

  /// other request parameters
  final Map<String, String> otherParameters;

  String? _encodedBaseUrl;

  late double _versionNumber;

  WMSTileLayerOptions({
    required this.baseUrl,
    this.layers = const <String>[],
    this.styles = const <String>[],
    this.format = 'image/png',
    this.version = '1.1.1',
    this.transparent = true,
    this.crs = const Epsg3857(),
    this.otherParameters = const <String, String>{},
  }) {
    _versionNumber = double.tryParse(version.split('.').take(2).join('.')) ?? 0;
    _encodedBaseUrl = _buildEncodedBaseUrl();
  }

  String _buildEncodedBaseUrl() {
    String projectionKey = _versionNumber >= 1.3 ? 'crs' : 'srs';
    StringBuffer buffer = StringBuffer(baseUrl)
      ..write('&service=$service')
      ..write('&request=$request')
      ..write('&layers=${layers.map(Uri.encodeComponent).join(',')}')
      ..write('&styles=${styles.map(Uri.encodeComponent).join(',')}')
      ..write('&format=${Uri.encodeComponent(format)}')
      ..write('&$projectionKey=${Uri.encodeComponent(crs.code)}')
      ..write('&version=${Uri.encodeComponent(version)}')
      ..write('&transparent=$transparent');
    otherParameters.forEach((String k, String v) => buffer.write('&$k=${Uri.encodeComponent(v)}'));
    return buffer.toString();
  }

  String getUrl(Coords<num> coords, int tileSize, bool retinaMode) {
    CustomPoint<num> tileSizePoint = CustomPoint<num>(tileSize, tileSize);
    CustomPoint<num> nvPoint = coords.scaleBy(tileSizePoint);
    CustomPoint<num> sePoint = nvPoint + tileSizePoint;
    LatLng? nvCoords = crs.pointToLatLng(nvPoint, coords.z!.toDouble());
    LatLng? seCoords = crs.pointToLatLng(sePoint, coords.z!.toDouble());
    CustomPoint<num> nv = crs.projection.project(nvCoords);
    CustomPoint<num> se = crs.projection.project(seCoords);
    Bounds<num> bounds = Bounds<num>(nv, se);
    List<num> bbox = (_versionNumber >= 1.3 && crs is Epsg4326)
        ? <num>[bounds.min.y, bounds.min.x, bounds.max.y, bounds.max.x]
        : <num>[bounds.min.x, bounds.min.y, bounds.max.x, bounds.max.y];

    StringBuffer buffer = StringBuffer(_encodedBaseUrl!);
    buffer.write('&width=${retinaMode ? tileSize * 2 : tileSize}');
    buffer.write('&height=${retinaMode ? tileSize * 2 : tileSize}');
    buffer.write('&bbox=${bbox.join(',')}');
    return buffer.toString();
  }
}

class TileLayerWidget extends StatefulWidget {
  final TileLayerOptions options;

  TileLayerWidget({required this.options}) : super(key: options.key);

  @override
  State<StatefulWidget> createState() => _TileLayerWidgetState();
}

class _TileLayerWidgetState extends State<TileLayerWidget> {
  @override
  Widget build(BuildContext context) {
    MapState mapState = MapState.of(context)!;

    return TileLayer(
      mapState: mapState,
      stream: mapState.onMoved,
      options: widget.options,
    );
  }
}

class TileLayer extends StatefulWidget {
  final TileLayerOptions options;
  final MapState? mapState;
  final Stream<void>? stream;

  TileLayer({
    required this.options,
    this.mapState,
    this.stream,
  }) : super(key: options.key);

  @override
  State<StatefulWidget> createState() {
    return _TileLayerState();
  }
}

class _TileLayerState extends State<TileLayer> with TickerProviderStateMixin {
  MapState? get map => widget.mapState;

  TileLayerOptions get options => widget.options;
  Bounds<num>? _globalTileRange;
  Tuple2<double, double>? _wrapX;
  Tuple2<double, double>? _wrapY;
  double? _tileZoom;
  Level? _level;
  StreamSubscription<void>? _moveSub;
  StreamController<LatLng?>? _throttleUpdate;
  CustomPoint<num>? _tileSize;

  final Map<String, Tile> _tiles = <String, Tile>{};
  final Map<double, Level> _levels = <double, Level>{};

  @override
  void initState() {
    super.initState();
    _tileSize = CustomPoint<num>(options.tileSize, options.tileSize);
    _resetView();
    _update(null);
    _moveSub = widget.stream!.listen((_) => _handleMove());

    _initThrottleUpdate();
  }

  @override
  void didUpdateWidget(TileLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    bool reloadTiles = false;

    if (oldWidget.options.tileSize != options.tileSize) {
      _tileSize = CustomPoint<num>(options.tileSize, options.tileSize);
      reloadTiles = true;
    }

    if (oldWidget.options.retinaMode != options.retinaMode) {
      reloadTiles = true;
    }

    if (oldWidget.options.updateInterval != options.updateInterval) {
      _throttleUpdate?.close();
      _initThrottleUpdate();
    }

    if (!reloadTiles) {
      String? oldUrl = oldWidget.options.wmsOptions?._encodedBaseUrl ?? oldWidget.options.urlTemplate;
      String? newUrl = options.wmsOptions?._encodedBaseUrl ?? options.urlTemplate;
      if (oldUrl != newUrl) {
        if (options.overrideTilesWhenUrlChanges) {
          for (Tile tile in _tiles.values) {
            tile.imageProvider = options.tileProvider.getImage(_wrapCoords(tile.coords!), options);
            tile.loadTileImage();
          }
        } else {
          reloadTiles = true;
        }
      }
    }

    if (reloadTiles) {
      _removeAllTiles();
      _resetView();
      _update(null);
    }
  }

  void _initThrottleUpdate() {
    if (options.updateInterval == null) {
      _throttleUpdate = null;
    } else {
      _throttleUpdate = StreamController<LatLng?>(sync: true);
      _throttleUpdate!.stream
          .transform(
            util.throttleStreamTransformerWithTrailingCall<LatLng?>(
              options.updateInterval!,
            ),
          )
          .listen(_update);
    }
  }

  @override
  void dispose() {
    // print('_TileLayerState dispose called');
    _removeAllTiles();
    _moveSub?.cancel();
    options.tileProvider.dispose();
    _throttleUpdate?.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Tile> tilesToRender = _tiles.values.toList()..sort();

    List<Widget> tileWidgets = <Widget>[for (Tile tile in tilesToRender) _createTileWidget(tile)];

    return Opacity(
      opacity: options.opacity,
      child: Container(
        color: options.backgroundColor,
        child: Stack(
          children: tileWidgets,
        ),
      ),
    );
  }

  Widget _createTileWidget(Tile tile) {
    CustomPoint<num> tilePos = tile.tilePos!;
    Level level = tile.level!;
    CustomPoint<num> tileSize = getTileSize()!;
    CustomPoint<num> pos = (tilePos).multiplyBy(level.scale) + level.translatePoint;
    num width = tileSize.x * level.scale;
    num height = tileSize.y * level.scale;

    Widget content = AnimatedTile(
      tile: tile,
      errorImage: options.errorImage,
      darkMode: widget.options.darkMode,
    );

    return Positioned(
      key: ValueKey<String?>(tile.coordsKey),
      left: pos.x.toDouble(),
      top: pos.y.toDouble(),
      width: width.toDouble(),
      height: height.toDouble(),
      child: content,
    );
  }

  void _abortLoading() {
    List<String> toRemove = <String>[];
    for (MapEntry<String, Tile> entry in _tiles.entries) {
      Tile tile = entry.value;

      if (tile.coords!.z != _tileZoom) {
        if (tile.loaded == null) {
          toRemove.add(entry.key);
        }
      }
    }

    for (String key in toRemove) {
      Tile tile = _tiles[key]!;

      tile.tileReady = null;
      tile.dispose();
      _tiles.remove(key);
    }
  }

  CustomPoint<num>? getTileSize() {
    return _tileSize;
  }

  bool _hasLevelChildren(double lvl) {
    for (Tile tile in _tiles.values) {
      if (tile.coords!.z == lvl) {
        return true;
      }
    }

    return false;
  }

  Level? _updateLevels() {
    double? zoom = _tileZoom;
    double maxZoom = options.maxZoom;

    if (zoom == null) return null;

    List<double> toRemove = <double>[];
    for (MapEntry<double, Level> entry in _levels.entries) {
      double z = entry.key;
      Level lvl = entry.value;

      if (z == zoom || _hasLevelChildren(z)) {
        lvl.zIndex = maxZoom - (zoom - z).abs();
      } else {
        toRemove.add(z);
      }
    }

    for (double z in toRemove) {
      _removeTilesAtZoom(z);
      _levels.remove(z);
    }

    Level? level = _levels[zoom];
    MapState? map = this.map;

    if (level == null) {
      level = _levels[zoom] = Level();
      level.zIndex = maxZoom;
      //// Removed because of nulls safety
      // level.origin = map!.project(map.unproject(map.getPixelOrigin()!), zoom) ??
      //     CustomPoint(0.0, 0.0);
      level.origin = map!.project(map.unproject(map.getPixelOrigin()!), zoom);
      level.zoom = zoom;

      _setZoomTransform(level, map.center, map.zoom);
    }

    return _level = level;
  }

  void _pruneTiles() {
    if (map == null) {
      return;
    }

    double? zoom = _tileZoom;
    if (zoom == null) {
      _removeAllTiles();
      return;
    }

    for (MapEntry<String, Tile> entry in _tiles.entries) {
      Tile tile = entry.value;
      tile.retain = tile.current;
    }

    for (MapEntry<String, Tile> entry in _tiles.entries) {
      Tile tile = entry.value;

      if (tile.current && !tile.active) {
        Coords<double> coords = tile.coords!;
        if (!_retainParent(coords.x, coords.y, coords.z!, coords.z! - 5)) {
          _retainChildren(coords.x, coords.y, coords.z, coords.z! + 2);
        }
      }
    }

    List<String> toRemove = <String>[];
    for (MapEntry<String, Tile> entry in _tiles.entries) {
      Tile tile = entry.value;

      if (!tile.retain) {
        toRemove.add(entry.key);
      }
    }

    for (String key in toRemove) {
      _removeTile(key);
    }
  }

  void _removeTilesAtZoom(double zoom) {
    List<String> toRemove = <String>[];
    for (MapEntry<String, Tile> entry in _tiles.entries) {
      if (entry.value.coords!.z != zoom) {
        continue;
      }
      toRemove.add(entry.key);
    }

    for (String key in toRemove) {
      _removeTile(key);
    }
  }

  void _removeAllTiles() {
    Map<String, Tile> toRemove = Map<String, Tile>.from(_tiles);

    for (String key in toRemove.keys) {
      _removeTile(key);
    }
  }

  bool _retainParent(double x, double y, double z, double minZoom) {
    double x2 = (x / 2).floorToDouble();
    double y2 = (y / 2).floorToDouble();
    double z2 = z - 1;
    Coords<double> coords2 = Coords<double>(x2, y2);
    coords2.z = z2;

    String key = _tileCoordsToKey(coords2);

    Tile? tile = _tiles[key];
    if (tile != null) {
      if (tile.active) {
        tile.retain = true;
        return true;
      } else if (tile.loaded != null) {
        tile.retain = true;
      }
    }

    if (z2 > minZoom) {
      return _retainParent(x2, y2, z2, minZoom);
    }

    return false;
  }

  void _retainChildren(double x, double y, double? z, double maxZoom) {
    for (double i = 2 * x; i < 2 * x + 2; i++) {
      for (double j = 2 * y; j < 2 * y + 2; j++) {
        Coords<double> coords = Coords<double>(i, j);
        coords.z = z! + 1;

        String key = _tileCoordsToKey(coords);

        Tile? tile = _tiles[key];
        if (tile != null) {
          if (tile.active) {
            tile.retain = true;
            continue;
          } else if (tile.loaded != null) {
            tile.retain = true;
          }
        }

        if (z + 1 < maxZoom) {
          _retainChildren(i, j, z + 1, maxZoom);
        }
      }
    }
  }

  void _resetView() {
    _setView(map!.center, map!.zoom);
  }

  double? _clampZoom(double zoom) {
    if (null != options.minNativeZoom && zoom < options.minNativeZoom!) {
      return options.minNativeZoom;
    }

    if (null != options.maxNativeZoom && options.maxNativeZoom! < zoom) {
      return options.maxNativeZoom;
    }

    return zoom;
  }

  void _setView(LatLng? center, double zoom) {
    double? tileZoom = _clampZoom(zoom.roundToDouble());
    // ignore: unnecessary_null_comparison
    if ((options.maxZoom != null && tileZoom! > options.maxZoom) ||
        // ignore: unnecessary_null_comparison
        (options.minZoom != null && tileZoom! < options.minZoom)) {
      tileZoom = null;
    }

    _tileZoom = tileZoom;

    _abortLoading();

    _updateLevels();
    _resetGrid();

    if (_tileZoom != null) {
      // widget.options
      //     .fnWhenZoomChanges(_tileZoom); // execute the zoomChanges Function
      _update(center);
    }

    _pruneTiles();
  }

  void _setZoomTransforms(LatLng? center, double zoom) {
    for (double i in _levels.keys) {
      _setZoomTransform(_levels[i]!, center, zoom);
    }
  }

  void _setZoomTransform(Level level, LatLng? center, double zoom) {
    double scale = map!.getZoomScale(zoom, level.zoom);
    CustomPoint<num> pixelOrigin = map!.getNewPixelOrigin(center, zoom).round();
    if (level.origin == null) {
      return;
    }
    CustomPoint<num> translate = level.origin!.multiplyBy(scale) - pixelOrigin;
    level.translatePoint = translate;
    level.scale = scale;
  }

  void _resetGrid() {
    MapState map = this.map!;
    Crs crs = map.options.crs;
    CustomPoint<num>? tileSize = getTileSize();
    double? tileZoom = _tileZoom;

    Bounds<num>? bounds = map.getPixelWorldBounds(_tileZoom);
    if (bounds != null) {
      _globalTileRange = _pxBoundsToTileRange(bounds);
    }

    // wrapping
    _wrapX = crs.wrapLng;
    if (_wrapX != null) {
      double first = (map.project(LatLng(0.0, crs.wrapLng!.item1), tileZoom).x / tileSize!.x).floorToDouble();
      double second = (map.project(LatLng(0.0, crs.wrapLng!.item2), tileZoom).x / tileSize.y).ceilToDouble();
      _wrapX = Tuple2<double, double>(first, second);
    }

    _wrapY = crs.wrapLat;
    if (_wrapY != null) {
      double first = (map.project(LatLng(crs.wrapLat!.item1, 0.0), tileZoom).y / tileSize!.x).floorToDouble();
      double second = (map.project(LatLng(crs.wrapLat!.item2, 0.0), tileZoom).y / tileSize.y).ceilToDouble();
      _wrapY = Tuple2<double, double>(first, second);
    }
  }

  void _handleMove() {
    double? tileZoom = _clampZoom(map!.zoom.roundToDouble());

    if (_tileZoom == null) {
      // if there is no _tileZoom available it means we are out within zoom level
      // we will restore fully via _setView call if we are back on trail
      // ignore: unnecessary_null_comparison
      if ((options.maxZoom != null && tileZoom! <= options.maxZoom) &&
          // ignore: unnecessary_null_comparison
          (options.minZoom != null && tileZoom >= options.minZoom)) {
        _tileZoom = tileZoom;
        setState(() {
          _setView(map!.center, tileZoom);

          _setZoomTransforms(map!.center, map!.zoom);
        });
      }
    } else {
      if (_tileZoom! > 1) {
        setState(() {
          if ((tileZoom! - _tileZoom!).abs() >= 1) {
            // It was a zoom lvl change
            _setView(map!.center, tileZoom);

            _setZoomTransforms(map!.center, map!.zoom);
          } else {
            if (null == _throttleUpdate) {
              _update(null);
            } else {
              _throttleUpdate!.add(null);
            }

            _setZoomTransforms(map!.center, map!.zoom);
          }
        });
      }
    }
  }

  Bounds<num> _getTiledPixelBounds(LatLng center) {
    double scale = map!.getZoomScale(map!.zoom, _tileZoom);
    CustomPoint<num> pixelCenter = map!.project(center, _tileZoom).floor();
    CustomPoint<num> halfSize = map!.size! / (scale * 2);

    return Bounds<num>(pixelCenter - halfSize, pixelCenter + halfSize);
  }

  // Private method to load tiles in the grid's active zoom level according to map bounds
  void _update(LatLng? center) {
    if (map == null || _tileZoom == null) {
      return;
    }

    double zoom = _clampZoom(map!.zoom)!;
    if ((zoom < 1) || (zoom > 18)) {
      return;
    }
    center ??= map!.center;

    Bounds<num> pixelBounds = _getTiledPixelBounds(center!);
    Bounds<num> tileRange = _pxBoundsToTileRange(pixelBounds);
    CustomPoint<double> tileCenter = tileRange.getCenter();
    List<Coords<num>> queue = <Coords<num>>[];
    int margin = options.keepBuffer;
    Bounds<num> noPruneRange = Bounds<num>(
      tileRange.bottomLeft - CustomPoint<num>(margin, -margin),
      tileRange.topRight + CustomPoint<num>(margin, -margin),
    );

    for (MapEntry<String, Tile> entry in _tiles.entries) {
      Tile tile = entry.value;
      Coords<double>? c = tile.coords;

      if (tile.current == true && (c!.z != _tileZoom || !noPruneRange.contains(CustomPoint<num>(c.x, c.y)))) {
        tile.current = false;
      }
    }

    // _update just loads more tiles. If the tile zoom level differs too much
    // from the map's, let _setView reset levels and prune old tiles.
    if ((zoom - _tileZoom!).abs() > 1) {
      _setView(center, zoom);
      return;
    }

    // create a queue of coordinates to load tiles from
    for (num j = tileRange.min.y; j <= tileRange.max.y; j++) {
      for (num i = tileRange.min.x; i <= tileRange.max.x; i++) {
        Coords<double> coords = Coords<double>(i.toDouble(), j.toDouble());
        coords.z = _tileZoom;

        if (!_isValidTile(coords)) {
          continue;
        }

        Tile? tile = _tiles[_tileCoordsToKey(coords)];
        if (tile != null) {
          tile.current = true;
        } else {
          queue.add(coords);
        }
      }
    }

    // sort tile queue to load tiles in order of their distance to center
    queue.sort((Coords<num> a, Coords<num> b) => (a.distanceTo(tileCenter) - b.distanceTo(tileCenter)).toInt());

    for (int i = 0; i < queue.length; i++) {
      _addTile(queue[i] as Coords<double>);
    }
  }

  bool _isValidTile(Coords<num> coords) {
    Crs crs = map!.options.crs;

    if (!crs.infinite) {
      // don't load tile if it's out of bounds and not wrapped
      Bounds<num>? bounds = _globalTileRange;
      if ((crs.wrapLng == null && (coords.x < bounds!.min.x || coords.x > bounds.max.x)) ||
          (crs.wrapLat == null && (coords.y < bounds!.min.y || coords.y > bounds.max.y))) {
        return false;
      }
    }

    return true;
  }

  String _tileCoordsToKey(Coords<num> coords) {
    return '${coords.x}:${coords.y}:${coords.z}';
  }

  Coords<num> _keyToTileCoords(String key) {
    List<String> k = key.split(':');
    Coords<double> coords = Coords<double>(double.parse(k[0]), double.parse(k[1]));
    coords.z = double.parse(k[2]);

    return coords;
  }

  void _removeTile(String key) {
    Tile? tile = _tiles[key];
    if (tile == null) {
      return;
    }

    tile.dispose();
    _tiles.remove(key);
  }

  void _addTile(Coords<double> coords) {
    String tileCoordsToKey = _tileCoordsToKey(coords);
    Tile tile = _tiles[tileCoordsToKey] = Tile(
      coords: coords,
      coordsKey: tileCoordsToKey,
      tilePos: _getTilePos(coords),
      current: true,
      level: _levels[coords.z!],
      imageProvider: options.tileProvider.getImage(_wrapCoords(coords), options),
      tileReady: _tileReady,
    );

    tile.loadTileImage();
  }

  void _tileReady(Coords<double>? coords, dynamic error, Tile? tile) {
    if (null != error) {
      print(error);

      tile!.loadError = true;

      if (options.errorTileCallback != null) {
        options.errorTileCallback!(tile, error);
      }
    } else {
      tile!.loadError = false;
    }

    String key = _tileCoordsToKey(coords!);
    tile = _tiles[key];
    if (null == tile) {
      return;
    }

    double fadeInStart = tile.loaded == null ? options.tileFadeInStart : options.tileFadeInStartWhenOverride;
    tile.loaded = DateTime.now();
    if (options.tileFadeInDuration == null || fadeInStart == 1.0 || (tile.loadError && null == options.errorImage)) {
      tile.active = true;
    } else {
      tile.startFadeInAnimation(
        options.tileFadeInDuration,
        this,
        from: fadeInStart,
      );
    }

    if (mounted) {
      setState(() {});
    }

    if (_noTilesToLoad()) {
      // Wait a bit more than tileFadeInDuration (the duration of the tile fade-in)
      // to trigger a pruning.
      Future<dynamic>.delayed(
        options.tileFadeInDuration != null
            ? options.tileFadeInDuration! + const Duration(milliseconds: 50)
            : const Duration(milliseconds: 50),
        () {
          if (mounted) {
            setState(_pruneTiles);
          }
        },
      );
    }
  }

  CustomPoint<num> _getTilePos(Coords<num> coords) {
    Level level = _levels[coords.z!.toDouble()]!;
    return coords.scaleBy(getTileSize()!) - level.origin!;
  }

  Coords<num> _wrapCoords(Coords<num> coords) {
    Coords<num> newCoords = Coords<num>(
      _wrapX != null ? util.wrapNum(coords.x.toDouble(), _wrapX!) : coords.x.toDouble(),
      _wrapY != null ? util.wrapNum(coords.y.toDouble(), _wrapY!) : coords.y.toDouble(),
    );
    newCoords.z = coords.z!.toDouble();
    return newCoords;
  }

  Bounds<num> _pxBoundsToTileRange(Bounds<num> bounds) {
    CustomPoint<num> tileSize = getTileSize()!;
    return Bounds<num>(
      bounds.min.unscaleBy(tileSize).floor(),
      bounds.max.unscaleBy(tileSize).ceil() - const CustomPoint<num>(1, 1),
    );
  }

  bool _noTilesToLoad() {
    for (MapEntry<String, Tile> entry in _tiles.entries) {
      if (entry.value.loaded == null) {
        return false;
      }
    }
    return true;
  }
}

typedef TileReady = void Function(Coords<double>? coords, dynamic error, Tile tile);

class Tile implements Comparable<Tile> {
  final String? coordsKey;
  final Coords<double>? coords;
  final CustomPoint<num>? tilePos;
  ImageProvider? imageProvider;
  final Level? level;

  bool current;
  bool retain;
  bool active;
  bool loadError;
  DateTime? loaded;

  AnimationController? animationController;
  double get opacity => animationController == null ? (active ? 1.0 : 0.0) : animationController!.value;

  // callback when tile is ready / error occurred
  // it maybe be null forinstance when download aborted
  TileReady? tileReady;
  ImageInfo? imageInfo;
  ImageStream? _imageStream;
  late ImageStreamListener _listener;

  Tile({
    this.coordsKey,
    this.coords,
    this.tilePos,
    this.imageProvider,
    this.tileReady,
    this.level,
    this.current = false,
    this.active = false,
    this.retain = false,
    this.loadError = false,
  });

  void loadTileImage() {
    try {
      ImageStream? oldImageStream = _imageStream;
      _imageStream = imageProvider!.resolve(const ImageConfiguration());

      if (_imageStream!.key != oldImageStream?.key) {
        oldImageStream?.removeListener(_listener);

        _listener = ImageStreamListener(_tileOnLoad, onError: _tileOnError);
        _imageStream!.addListener(_listener);
      }
    } catch (e, s) {
      // make sure all exception is handled - #444 / #536
      _tileOnError(e, s);
    }
  }

  // call this before GC!
  void dispose([bool evict = false]) {
    if (evict && imageProvider != null) {
      imageProvider!
          .evict()
          .then((bool succ) => print('evict tile: $coords -> $succ'))
          .catchError((dynamic error) => print('evict tile: $coords -> $error'));
    }

    animationController?.removeStatusListener(_onAnimateEnd);
    animationController?.dispose();
    _imageStream?.removeListener(_listener);
  }

  void startFadeInAnimation(Duration? duration, TickerProvider vsync, {double? from}) {
    animationController?.removeStatusListener(_onAnimateEnd);

    animationController = AnimationController(duration: duration, vsync: vsync)..addStatusListener(_onAnimateEnd);

    animationController!.forward(from: from);
  }

  void _onAnimateEnd(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      active = true;
    }
  }

  void _tileOnLoad(ImageInfo imageInfo, bool synchronousCall) {
    if (null != tileReady) {
      this.imageInfo = imageInfo;
      tileReady!(coords, null, this);
    }
  }

  void _tileOnError(dynamic exception, StackTrace? stackTrace) {
    if (null != tileReady) {
      tileReady!(coords, exception ?? 'Unknown exception during loadTileImage', this);
    }
  }

  @override
  int compareTo(Tile other) {
    double? zIndexA = level!.zIndex;
    double? zIndexB = other.level!.zIndex;

    if (zIndexA == zIndexB) {
      return 0;
    } else {
      return zIndexB!.compareTo(zIndexA!);
    }
  }

  @override
  int get hashCode => coords.hashCode;

  @override
  bool operator ==(Object other) {
    return other is Tile && coords == other.coords;
  }
}

class AnimatedTile extends StatefulWidget {
  final Tile tile;
  final ImageProvider? errorImage;
  final bool darkMode;

  AnimatedTile({Key? key, required this.tile, this.errorImage, this.darkMode = false}) : super(key: key);

  @override
  _AnimatedTileState createState() => _AnimatedTileState();
}

class _AnimatedTileState extends State<AnimatedTile> {
  bool listenerAttached = false;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.tile.opacity,
      child: (widget.tile.loadError && widget.errorImage != null)
          ? Image(
              image: widget.errorImage!,
              fit: BoxFit.fill,
            )
          : RawImage(
              invertColors: widget.darkMode,
              image: widget.tile.imageInfo?.image,
              fit: BoxFit.fill,
            ),
    );
  }

  @override
  void initState() {
    super.initState();

    if (null != widget.tile.animationController) {
      widget.tile.animationController!.addListener(_handleChange);
      listenerAttached = true;
    }
  }

  @override
  void dispose() {
    if (listenerAttached) {
      widget.tile.animationController?.removeListener(_handleChange);
    }

    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!listenerAttached && null != widget.tile.animationController) {
      widget.tile.animationController!.addListener(_handleChange);
      listenerAttached = true;
    }
  }

  void _handleChange() {
    if (mounted) {
      setState(() {});
    }
  }
}

class Level {
  double? zIndex;
  CustomPoint<num>? origin;
  double? zoom;
  late CustomPoint<num> translatePoint;
  late double scale;
}

class Coords<T extends num> extends CustomPoint<T> {
  T? z;

  Coords(T x, T y) : super(x, y);

  @override
  String toString() => 'Coords($x, $y, $z)';

  @override
  bool operator ==(dynamic other) {
    if (other is Coords) {
      return x == other.x && y == other.y && z == other.z;
    }
    return false;
  }

  @override
  int get hashCode => hashValues(x.hashCode, y.hashCode, z.hashCode);
}
