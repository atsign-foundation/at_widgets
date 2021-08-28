import 'dart:math';

class DistanceGrid<T> {
  final num cellSize;

  final num _sqCellSize;
  final Map<num, Map<num, List<T>>> _grid = <num, Map<num, List<T>>>{};
  final Map<T, Point<num>> _objectPoint = <T, Point<num>>{};

  DistanceGrid(this.cellSize) : _sqCellSize = cellSize * cellSize;

  void addObject(T obj, Point<num> point) {
    num x = _getCoord(point.x), y = _getCoord(point.y);
    Map<num, List<T>> row = _grid[y] ??= <num, List<T>>{};
    List<T> cell = row[x] ??= <T>[];

    _objectPoint[obj] = point;

    cell.add(obj);
  }

  void updateObject(T obj, Point<num> point) {
    removeObject(obj);
    addObject(obj, point);
  }

  //Returns true if the object was found
  bool removeObject(T obj) {
    Point<num>? point = _objectPoint[obj];
    if (point == null) return false;

    num x = _getCoord(point.x), y = _getCoord(point.y);
    Map<num, List<T>> row = _grid[y] ??= <num, List<T>>{};
    List<T> cell = row[x] ??= <T>[];

    _objectPoint.remove(obj);

    for (int i = 0, len = cell.length; i < len; i++) {
      if (cell[i] == obj) {
        cell.removeAt(i);

        if (len == 1) {
          row.remove(x);

          if (_grid[y]!.isEmpty) {
            _grid.remove(y);
          }
        }

        return true;
      }
    }
    return false;
  }

  void eachObject(Function(T) fn) {
    for (num i in _grid.keys) {
      Map<num, List<T>> row = _grid[i]!;

      for (num j in row.keys) {
        List<T> cell = row[j]!;

        for (int k = 0, len = cell.length; k < len; k++) {
          fn(cell[k]);
        }
      }
    }
  }

  T? getNearObject(Point<num> point) {
    num x = _getCoord(point.x),
        y = _getCoord(point.y),
        closestDistSq = _sqCellSize;
    T? closest;

    for (int i = y.toInt() - 1; i <= y + 1; i++) {
      Map<num, List<T>>? row = _grid[i];
      if (row != null) {
        for (num j = x - 1; j <= x + 1; j++) {
          List<T>? cell = row[j];
          if (cell != null) {
            for (int k = 0, len = cell.length; k < len; k++) {
              T obj = cell[k];
              num dist = _sqDist(_objectPoint[obj]!, point);

              if (dist < closestDistSq ||
                  dist <= closestDistSq && closest == null) {
                closestDistSq = dist;
                closest = obj;
              }
            }
          }
        }
      }
    }
    return closest;
  }

  num _getCoord(num x) {
    double coord = x / cellSize;
    return coord.isFinite ? coord.floor() : x;
  }

  num _sqDist(Point<num> p1, Point<num> p2) {
    num dx = p2.x - p1.x, dy = p2.y - p1.y;
    return dx * dx + dy * dy;
  }
}
