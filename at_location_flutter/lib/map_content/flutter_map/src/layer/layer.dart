import 'package:flutter/foundation.dart';

/// Common type between all LayerOptions.
///
/// All LayerOptions have access to a stream that notifies when the map needs
/// rebuilding.
class LayerOptions {
  final Key? key;
  final Stream<void>? rebuild;
  LayerOptions({this.key, this.rebuild});
}
