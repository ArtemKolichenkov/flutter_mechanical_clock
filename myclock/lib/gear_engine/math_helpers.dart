import 'dart:math' as math;

int toothPointIndex(point) {
  return point % 4;
}

int escapementToothPointIndex(point) {
  return point % 5;
}

List<List<double>> convertToCartesian(
  List<List<double>> polarPoints,
) {
  return polarPoints.map((point) {
    double x = point[1] * math.cos(point[0]);
    double y = point[1] * math.sin(point[0]);
    return [x, y];
  }).toList();
}

List<List<double>> makePolarPoints(
  List<int> points,
  double outlineRadiusMax,
  double outlineRadiusMin,
  double teethBaseAngle,
  double teethWidth,
  bool escapementWheel,
) {
  double angleDelta = (2 * math.pi) / (points.length);
  //Widen the "inner teeth" so they are as wide as the "outer teeth":
  double angleWidener =
      angleDelta * ((outlineRadiusMax / outlineRadiusMin) - 1) / 2 +
          teethBaseAngle;
  double makeRadius(i) {
    double toothRadius = 0.0;
    if (escapementWheel) {
      if (escapementToothPointIndex(i) == 1 || escapementToothPointIndex(i) == 4) {
        toothRadius = outlineRadiusMax;
      } else if (escapementToothPointIndex(i) == 0) {
        toothRadius = outlineRadiusMax + 5;
      } else {
        // 2 3
        toothRadius = outlineRadiusMin;
      }
    } else {
      bool outerTooth = ([0, 1].indexOf(toothPointIndex(i)) >= 0);
      toothRadius = outerTooth ? outlineRadiusMax : outlineRadiusMin;
    }
    return toothRadius;
  }

  double makeAngle(i) {
    var angle = i * angleDelta;
    if (escapementWheel) {
      if (escapementToothPointIndex(i) == 2) {
        angle = i * angleDelta - angleWidener + teethWidth;
      } else if (escapementToothPointIndex(i) == 3) {
        angle = i * angleDelta + angleWidener - teethWidth;
      } else if (escapementToothPointIndex(i) == 1) {
        angle = i * angleDelta + teethWidth + 0.3;
      } else if (escapementToothPointIndex(i) == 4) {
        angle = i * angleDelta - teethWidth + 0.3;
      } else if (escapementToothPointIndex(i) == 0) {
        angle = i * angleDelta - teethWidth + 0.2;
      }
    } else {
      if (toothPointIndex(i) == 2) {
        angle = i * angleDelta - angleWidener + teethWidth;
      } else if (toothPointIndex(i) == 3) {
        angle = i * angleDelta + angleWidener - teethWidth;
      } else if (toothPointIndex(i) == 1) {
        angle = i * angleDelta + teethWidth;
      } else if (toothPointIndex(i) == 0) {
        angle = i * angleDelta - teethWidth;
      }
    }
    return angle;
  }

  return points.fold([], (List prev, point) {
    double r = makeRadius(point);
    double angle = makeAngle(point);
    prev.add([angle, r]);
    return prev;
  });
}

List<List<double>> makePolarSpring() {
  List<int> points = List.generate(48, (i) => i + 1);
  double makeRadius(i) {
    return i * 0.5;
  }

  double makeAngle(i) {
    return i + 0.1;
  }

  return points.fold([], (List prev, point) {
    double r = makeRadius(point);
    double angle = makeAngle(point);
    prev.add([angle, r]);
    return prev;
  });
}
