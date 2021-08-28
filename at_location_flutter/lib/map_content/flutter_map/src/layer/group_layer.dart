import 'package:flutter/widgets.dart';
import 'package:at_location_flutter/map_content/flutter_map/flutter_map.dart';
import 'package:at_location_flutter/map_content/flutter_map/src/map/map.dart';

/// [LayerOptions] that describe a layer composed by multiple built-in layers.
class GroupLayerOptions extends LayerOptions {
  List<LayerOptions>? group = <LayerOptions>[];

  GroupLayerOptions({
    Key? key,
    this.group,
    dynamic rebuild,
  }) : super(key: key, rebuild: rebuild);
}

class GroupLayerWidget extends StatelessWidget {
  final GroupLayerOptions options;

  GroupLayerWidget({required this.options}) : super(key: options.key);

  @override
  Widget build(BuildContext context) {
    MapState mapState = MapState.of(context)!;
    return GroupLayer(options, mapState, mapState.onMoved);
  }
}

class GroupLayer extends StatelessWidget {
  final GroupLayerOptions groupOpts;
  final MapState? map;
  final Stream<void> stream;

  GroupLayer(this.groupOpts, this.map, this.stream) : super(key: groupOpts.key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints bc) {
        return _build(context);
      },
    );
  }

  Widget _build(BuildContext context) {
    return StreamBuilder<void>(
      stream: stream,
      builder: (BuildContext context, _) {
        List<Widget> layers = <Widget>[for (LayerOptions options in groupOpts.group!) _createLayer(options)];

        return Container(
          child: Stack(
            children: layers,
          ),
        );
      },
    );
  }

  Widget _createLayer(LayerOptions options) {
    if (options is MarkerLayerOptions) {
      return MarkerLayer(options, map, options.rebuild);
    }
    if (options is CircleLayerOptions) {
      return CircleLayer(options, map, options.rebuild);
    }
    if (options is PolylineLayerOptions) {
      return PolylineLayer(options, map, options.rebuild);
    }
    if (options is PolygonLayerOptions) {
      return PolygonLayer(options, map, options.rebuild);
    }
    if (options is OverlayImageLayerOptions) {
      return OverlayImageLayer(options, map, options.rebuild);
    }
    throw Exception('Unknown options type for GeometryLayer: $options');
  }
}
