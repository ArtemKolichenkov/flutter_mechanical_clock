import 'package:flutter/material.dart';
import './gear_generator.dart';

enum GearType {
  minutes,
  hours,
  seconds,
  balanceWheel,
  escapementWheel,
  minsec,
  minhour,
}

class AnimatedGear extends StatefulWidget {
  AnimatedGear({
    Key key,
    this.gearType,
    this.animationDuration,
    this.initialAngle,
  }) : super(key: key);
  final GearType gearType;
  // How long it takes to complete full circle in seconds
  final int animationDuration;
  final double initialAngle;

  @override
  _AnimatedGearState createState() => _AnimatedGearState();
}

class _AnimatedGearState extends State<AnimatedGear>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> angle;

  @override
  void initState() {
    super.initState();
    if (widget.gearType == GearType.balanceWheel) {
      controller = AnimationController(
        duration: Duration(milliseconds: widget.animationDuration),
        vsync: this,
      );
      angle = Tween<double>(
        begin: 0,
        end: 3.14,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.linear,
        ),
      );
      controller.forward();
      controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      });
    } else {
      controller = AnimationController(
        duration: Duration(seconds: widget.animationDuration),
        vsync: this,
      );
      if ([
        GearType.escapementWheel,
        GearType.minsec,
        GearType.minhour,
      ].contains(widget.gearType)) {
        angle = Tween<double>(
          begin: fullCircleRads + 0.13,
          end: 0 + 0.13,
        ).animate(
          CurvedAnimation(parent: controller, curve: Curves.linear),
        );
      } else {
        angle = Tween<double>(
          begin: widget.initialAngle,
          end: widget.initialAngle + fullCircleRads,
        ).animate(
          CurvedAnimation(parent: controller, curve: Curves.linear),
        );
      }

      controller.repeat();
    }
  }

  @override
  build(context) {
    return AnimatedBuilder(
        animation: controller,
        builder: (context, builder) {
          return CustomPaint(
            painter: GearPainter(
              angle: angle.value,
              gearType: widget.gearType,
              color: Colors.black,
            ),
            willChange: true,
          );
        });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class GearHand extends StatelessWidget {
  final Color color = Colors.black;
  final GearType gearType;
  final double angleRadians;
  GearHand({
    @required Color color,
    @required this.gearType,
    @required double angleRadians,
  })  : assert(color != null),
        assert(gearType != null),
        assert(angleRadians != null),
        angleRadians = angleRadians;

  // provide color
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GearPainter(
        angle: angleRadians,
        gearType: gearType,
        color: color,
      ),
    );
  }
}

class GearPainter extends CustomPainter {
  final double angle;
  final GearType gearType;
  final Color color;
  GearPainter({this.angle, this.gearType, this.color}) : super();
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = color;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 0.6;
    canvas.rotate(angle);
    Path gearPath = getGearPath(gearType);
      
    canvas.drawPath(gearPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

getGearPath(GearType gearType) {
  switch (gearType) {
    case GearType.hours:
      {
        return makeGear(
          diameter: 70,
          teeth: 36,
          clockTeeth: true,
          teethSize: 3,
          teethBaseAngle: 0.02,
          teethWidth: 0.01,
          outerThickness: 6,
          innerThickness: 5,
          holeRadius: 3,
          bars: 4,
          barWidth: 0.2,
          axleGear: false,
          hand: 1,
        )['path'];
      }
      break;
    case GearType.minhour:
      {
        return makeGear(
          diameter: 70,
          teeth: 36,
          teethSize: 3,
          clockTeeth: true,
          teethBaseAngle: 0.02,
          teethWidth: 0.01,
          outerThickness: 6,
          innerThickness: 10,
          holeRadius: 4,
          bars: 4,
          barWidth: 0.2,
          axleGear: true,
          axleTeeth: 9,
          axleDiameter: 20,
        )['path'];
      }
      break;
    case GearType.minutes:
      {
        return makeGear(
          diameter: 122,
          teeth: 64,
          teethSize: 3,
          clockTeeth: true,
          teethBaseAngle: 0.02,
          teethWidth: 0.01,
          outerThickness: 11,
          innerThickness: 10,
          holeRadius: 6,
          bars: 4,
          barWidth: 0.2,
          axleGear: true,
          axleTeeth: 11,
          axleDiameter: 30,
          hand: 1,
        )['path'];
      }
      break;
    case GearType.minsec:
      {
        return makeGear(
          diameter: 96,
          teeth: 60,
          teethSize: 3,
          clockTeeth: true,
          teethBaseAngle: 0.02,
          teethWidth: 0.01,
          outerThickness: 7,
          innerThickness: 10,
          holeRadius: 4,
          bars: 4,
          barWidth: 0.2,
          axleGear: true,
          axleTeeth: 8,
          axleDiameter: 20,
        )['path'];
      }
      break;
    case GearType.seconds:
      {
        return makeGear(
          diameter: 95,
          teeth: 60,
          teethSize: 3,
          clockTeeth: true,
          teethBaseAngle: 0.02,
          teethWidth: 0.01,
          outerThickness: 10,
          innerThickness: 9,
          holeRadius: 4,
          bars: 4,
          barWidth: 0.2,
          hand: 3,
          axleGear: true,
          axleDiameter: 16,
          axleTeeth: 8,
        )['path'];
      }
      break;
    case GearType.balanceWheel:
      {
        return makeGear(
            diameter: 72,
            teeth: 10,
            teethSize: -15,
            teethBaseAngle: 0.12,
            teethWidth: 0.06,
            outerThickness: 10,
            innerThickness: 7,
            holeRadius: 8,
            bars: 2,
            barWidth: 0.2,
            balanceWheel: true)['path'];
      }
      break;
    case GearType.escapementWheel:
      {
        return makeGear(
            diameter: 72,
            teeth: 15,
            teethSize: 3,
            teethBaseAngle: 0.03,
            teethWidth: -0.04,
            outerThickness: 4,
            innerThickness: 10,
            holeRadius: 2,
            bars: 3,
            barWidth: 0.2,
            axleGear: true,
            axleTeeth: 6,
            escapementWheel: true)['path'];
      }
      break;
    default:
      {
        return makeGear(
            diameter: 226,
            teeth: 64,
            teethSize: 3,
            clockTeeth: true,
            teethBaseAngle: 0.02,
            teethWidth: 0.01,
            outerThickness: 15,
            innerThickness: 30,
            holeRadius: 9,
            bars: 4,
            barWidth: 0.2,
            axleGear: true,
            axleTeeth: 11,
            axleDiameter: 50)['path'];
      }
      break;
  }
}
