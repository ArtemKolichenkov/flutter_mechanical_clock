import 'package:flutter/material.dart';
import 'dart:math' as math;
import './math_helpers.dart';

// full circle = 6.283185307 radians
double fullCircleRads = 6.283185307;

void makeSmoothGearPath(
  List<List<double>> cartesianPoints,
  Path gearPath,
) {
  // TODO: this prevXY doesn't get used right? make it different null-like value?
  double prevX = cartesianPoints.last[0];
  double prevY = cartesianPoints.last[1];
  cartesianPoints.asMap().forEach((index, pair) {
    double x = pair[0];
    double y = pair[1];
    int iOne = index + 1;
    var outerTooth = toothPointIndex(iOne) == 0;
    if (outerTooth) {
      prevX = cartesianPoints[index - 1][0];
      prevY = cartesianPoints[index - 1][1];
      gearPath.lineTo(prevX, prevY);
      if (index == cartesianPoints.length - 1) {
        gearPath.cubicTo(x, y, cartesianPoints[0][0], cartesianPoints[0][1],
            cartesianPoints[1][0], cartesianPoints[1][1]);
      } else {
        gearPath.cubicTo(
            x,
            y,
            cartesianPoints[index + 1][0],
            cartesianPoints[index + 1][1],
            cartesianPoints[index + 2][0],
            cartesianPoints[index + 2][1]);
      }
    }
  });
}

void makeBarsAndMiddle(
  Path gearPath,
  double outlineRadiusMin,
  double outerThickness,
  double holeRadius,
  double innerThickness,
  int bars,
  double barWidth,
) {
  double frameRadius = outlineRadiusMin - outerThickness;
  double holeRadiusOuter = holeRadius + innerThickness;
  double smallBarWidth = (frameRadius * barWidth / holeRadiusOuter);
  double arcStep = fullCircleRads / bars - barWidth;
  double arcStepSmall = fullCircleRads / bars - smallBarWidth;
  double position = barWidth / 2;
  double positionSmall = smallBarWidth / 2; // smallBarWidth / bars;
  List<List<double>> polarBars = [];
  // Drawing the rings with empty spaces for bars in them
  for (int i = 0; i < bars; i++) {
    polarBars.addAll([
      [position, frameRadius],
      [positionSmall, holeRadiusOuter],
      [position + arcStep, frameRadius],
      [positionSmall + arcStepSmall, holeRadiusOuter]
    ]);
    gearPath.addArc(Rect.fromCircle(center: Offset(0, 0), radius: frameRadius),
        position, arcStep);
    gearPath.addArc(
        Rect.fromCircle(center: Offset(0, 0), radius: holeRadiusOuter),
        positionSmall,
        arcStepSmall);
    position = position + arcStep + barWidth;
    positionSmall = positionSmall + arcStepSmall + smallBarWidth;
  }
  // Drawing bars
  List<List<double>> cartesianBars = convertToCartesian(polarBars);
  cartesianBars.asMap().forEach((index, pair) {
    if (index % 2 == 0) {
      gearPath.moveTo(pair[0], pair[1]);
    } else {
      gearPath.lineTo(pair[0], pair[1]);
    }
  });
  // Drawing inner hole
  
  gearPath.addOval(Rect.fromCircle(center: Offset(0, 0), radius: holeRadius));
}

Map<String, dynamic> makeGear({
  @required diameter,
  @required teeth,
  bool smoothTeeth = false,
  double teethSize = 0,
  double teethBaseAngle = 0,
  bool clockTeeth = false,
  double outerThickness = 0,
  double innerThickness = 0,
  double holeRadius = 0,
  int bars = 0,
  double barWidth = 0.25,
  bool axleGear = false,
  int axleTeeth = 8,
  double axleDiameter = 15,
  double teethWidth = 0,
  bool balanceWheel = false,
  bool escapementWheel = false,
  int hand = 0,
}) {
  // TODO: check for parameters that don't make sense + protect from recursion with axleGear
  // NOTE: for straight teeth teethBaseAngle: 0.02,
  // 1. First we define the Path and calculate basic geometric properties
  Path gearPath = Path();
  int pointsPerTeeth = escapementWheel ? 5 : 4;
  List<int> points = List.generate(teeth * pointsPerTeeth, (i) => i + 1);
  double outlineRadiusMax = diameter / 2;
  double outlineRadiusMin =
      outlineRadiusMax - 2 * (diameter * math.pi / points.length) - teethSize;
  //When few teeth (< ~10)
  outlineRadiusMin = math.max(outlineRadiusMin, outlineRadiusMax / 2);

  // 2. Generate points that describe the gear on polar coordinate system
  List<List<double>> polarPoints = makePolarPoints(points, outlineRadiusMax,
      outlineRadiusMin, teethBaseAngle, teethWidth, escapementWheel);
  // 3. Convert it to cartesian coordinate system
  List<List<double>> cartesianPoints = convertToCartesian(polarPoints);

  // 4. Starting point is different due to the way we draw sharp or smooth gears
  List<double> startingPoint = smoothTeeth
      ? [cartesianPoints[2][0], cartesianPoints[2][1]]
      : [cartesianPoints[0][0], cartesianPoints[0][1]];
  gearPath.moveTo(startingPoint[0], startingPoint[1]);

  // 5. Make path for the gear outline
  if (smoothTeeth) {
    makeSmoothGearPath(cartesianPoints, gearPath);
  } else if (clockTeeth) {
    cartesianPoints.asMap().forEach((index, pair) {
      double x = pair[0];
      double y = pair[1];
      int iOne = index + 1;
      var outerTooth = toothPointIndex(iOne) == 1;
      if (outerTooth) {
        // arc to this point
        gearPath.arcToPoint(Offset(x, y), radius: Radius.circular(1));
      } else if (index == cartesianPoints.length - 1) {
        // line to this point and arc starting point
        gearPath.lineTo(x, y);
        gearPath.arcToPoint(
            Offset(cartesianPoints[0][0], cartesianPoints[0][1]),
            radius: Radius.circular(1));
      } else {
        gearPath.lineTo(x, y);
      }
    });
  } else {
    cartesianPoints.forEach((pair) {
      gearPath.lineTo(pair[0], pair[1]);
    });
  }

  gearPath.lineTo(startingPoint[0], startingPoint[1]);

  // 6. Thicknness of the gear if there is no bars inside of it
  if (outerThickness != 0 && bars == 0) {
    double frameRadius = outlineRadiusMin - outerThickness;
    gearPath
        .addOval(Rect.fromCircle(center: Offset(0, 0), radius: frameRadius));
  }

  // 7. Drawing arcs and bars
  if (bars != 0 && outerThickness != 0 && innerThickness != 0) {
    makeBarsAndMiddle(gearPath, outlineRadiusMin, outerThickness, holeRadius,
        innerThickness, bars, barWidth);
  }

  // 8. Make axle gear
  // TODO: conditions - has bars and center hole
  if (axleGear) {
    Map<String, dynamic> axleGearData = makeGear(
        diameter: axleDiameter,
        teeth: axleTeeth,
        clockTeeth: true,
        teethSize: -1);
    Path axleGearPath = axleGearData['path'];
    List<double> axleStartingPoint = axleGearData['startingPoint'];
    gearPath.moveTo(axleStartingPoint[0], axleStartingPoint[1]);
    gearPath.extendWithPath(axleGearPath, Offset(0, 0));
  }

  // 9. Make balance wheel spring
  if (balanceWheel) {
    Path springPath = Path();
    gearPath.moveTo(0, 0);
    List<List<double>> polarSpring = makePolarSpring();
    List<List<double>> cartesianSpring = convertToCartesian(polarSpring);
    cartesianSpring.forEach((pair) {
      springPath.arcToPoint(
        Offset(pair[0], pair[1]),
        radius: Radius.circular(30),
      );
    });
    gearPath.extendWithPath(springPath, Offset(0, 0));
  }

  // 10. Attach hand
  if (hand != 0) {
    Map<String, dynamic> handDimensions = getHandDimensions(hand, diameter);
    double handThickness = handDimensions['thickness'];
    double handLength = handDimensions['length'];
    double arcStart = 1.5708 - handThickness / 2;
    double handRadius = innerThickness + holeRadius + holeRadius / 2;
    List<double> cartesianHandStart = [
      handRadius * math.cos(-arcStart),
      handRadius * math.sin(-arcStart),
    ];
    gearPath.moveTo(0, 0);
    gearPath.addArc(
      Rect.fromCircle(center: Offset(0, 0), radius: handRadius),
      -arcStart,
      fullCircleRads - handThickness,
    );
    gearPath.lineTo(0, handLength);
    gearPath.lineTo(cartesianHandStart[0], cartesianHandStart[1]);
  }
  return {'path': gearPath, 'startingPoint': startingPoint};
}

Map<String, double> getHandDimensions(handNumber, diameter) {
  switch(handNumber) {
    case 1: {
      // minutes
      return { 'thickness': 1, 'length': -diameter.toDouble() - 10,};
    }
    break;
    case 2: {
      // hours
      return { 'thickness': 2, 'length': -diameter.toDouble() - 50,};
    }
    case 3: {
      // seconds
      return { 'thickness': 0.5, 'length': -diameter.toDouble() - 0,};
    }
    break;
  }
}