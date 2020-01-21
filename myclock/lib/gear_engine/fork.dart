import 'package:flutter/material.dart';

class AnimatedFork extends StatefulWidget {
  AnimatedFork({Key key, this.animationDuration}) : super(key: key);
  // How long it takes to complete full circle in seconds
  final int animationDuration;

  @override
  _AnimatedForkState createState() => _AnimatedForkState();
}

class _AnimatedForkState extends State<AnimatedFork>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> angle;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(milliseconds: widget.animationDuration),
      vsync: this,
    );
    angle = Tween<double>(
      begin: 0.3,
      end: -0.3,
    ).animate(
      CurvedAnimation(parent: controller, curve: Curves.linear),
    );
    controller.forward();
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        controller.forward();
      }
    });
  }

  @override
  build(context) {
    return AnimatedBuilder(
        animation: controller,
        builder: (context, builder) {
          return CustomPaint(
            painter: ForkPainter(
              angle: angle.value,
            ),
            size: Size(245, 245),
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

class ForkPainter extends CustomPainter {
  final double angle;
  ForkPainter({this.angle}) : super();
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.black;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3.0;
    canvas.rotate(angle);
    canvas.scale(0.3);
    Path forkPath = generateForkPath();
    canvas.drawPath(forkPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

Path generateForkPath() {
  Path forkPath = Path();

  List<List<double>> halfForkWing = [
    [10, -20],
    [10, -55],
    [10, -65],
    [15, -70],
    // jewel
    [25, -60],
    [38, -60],
    [20, -80],
    // end jewel
    [30, -90],
    [0, -100],
    [-20, -70],
    [-10, -60],
    [-10, -20],
    [-20, -10],
  ];

  List<List<double>> halfForkHand = [
    [-70, -10],
    [-76, -10],
    [-80, -25],
    [-115, -25],
    [-105, -16],
    [-85, -10],
    // middle
    [-85, 0],
    [-85, -5],
    [-110, -5],
    [-115, 0],
  ];
  // starting point
  forkPath.moveTo(20, 0);
  halfForkWing.asMap().forEach((i, pair) {
    if (i == 0) {
      forkPath.arcToPoint(
        Offset(pair[0], pair[1]),
        radius: Radius.circular(25),
        clockwise: false,
      );
    }
    if (i == 1) {
      forkPath.lineTo(pair[0], pair[1]);
      forkPath.quadraticBezierTo(
        halfForkWing[2][0],
        halfForkWing[2][1],
        halfForkWing[3][0],
        halfForkWing[3][1],
      );
    } else if ([7, 8, 9, 10].contains(i)) {
      forkPath.arcToPoint(
        Offset(pair[0], pair[1]),
        radius: Radius.circular(25),
        clockwise: false,
      );
    } else if (i == 12) {
      forkPath.arcToPoint(
        Offset(pair[0], pair[1]),
        radius: Radius.circular(25),
      );
    } else if (![2, 3].contains(i)) {
      forkPath.lineTo(pair[0], pair[1]);
    }
  });

  halfForkHand.asMap().forEach((i, pair) {
    if (i == 0) {
      forkPath.lineTo(pair[0], pair[1]);
      forkPath.quadraticBezierTo(
        halfForkHand[1][0],
        halfForkHand[1][1],
        halfForkHand[2][0],
        halfForkHand[2][1],
      );
    } else if (i == 5) {
      forkPath.arcToPoint(Offset(pair[0], pair[1]),
          radius: Radius.circular(20));
    } else if (![1, 2].contains(i)) {
      forkPath.lineTo(pair[0], pair[1]);
    }
  });

  halfForkHand.reversed.toList().asMap().forEach((i, pair) {
    if (i == 5) {
      forkPath.arcToPoint(
        Offset(pair[0], pair[1] * -1),
        radius: Radius.circular(20),
      );
    } else if (i == 7) {
      forkPath.lineTo(pair[0], pair[1] * -1);
      forkPath.quadraticBezierTo(
        halfForkHand[1][0],
        halfForkHand[1][1] * -1,
        halfForkHand[0][0],
        halfForkHand[0][1] * -1,
      );
    } else if (![8, 9].contains(i)) {
      forkPath.lineTo(pair[0], pair[1] * -1);
    }
  });

  halfForkWing.reversed.toList().asMap().forEach((i, pair) {
    if (i == 9) {
      forkPath.lineTo(pair[0], pair[1] * -1);
      forkPath.quadraticBezierTo(
        halfForkWing[2][0],
        halfForkWing[2][1] * -1,
        halfForkWing[1][0],
        halfForkWing[1][1] * -1,
      );
    } else if ([4, 5, 6, 3].contains(i)) {
      forkPath.arcToPoint(
        Offset(pair[0], pair[1] * -1),
        radius: Radius.circular(25),
        clockwise: false,
      );
    } else if (i == 1) {
      forkPath.arcToPoint(
        Offset(pair[0], pair[1] * -1),
        radius: Radius.circular(25),
      );
    } else if (![10, 11].contains(i)) {
      forkPath.lineTo(pair[0], pair[1] * -1);
    }
  });
  forkPath.arcToPoint(
    Offset(20, 0),
    radius: Radius.circular(25),
    clockwise: false,
  );
  forkPath.addOval(Rect.fromCircle(
    center: Offset(0, 0),
    radius: 8,
  ));
  return forkPath;
}
