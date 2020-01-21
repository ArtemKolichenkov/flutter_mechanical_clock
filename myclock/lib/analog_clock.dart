// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' show radians;

import 'gear_engine/gear_painter.dart';
import 'gear_engine/fork.dart';

/// Total distance traveled by a second or a minute hand, each second or minute,
/// respectively.
final radiansPerTick = radians(360 / 60);

/// Total distance traveled by an hour hand, each hour, in radians.
final radiansPerHour = radians(360 / 12);

class AnalogClock extends StatefulWidget {
  const AnalogClock(this.model);

  final ClockModel model;

  @override
  _AnalogClockState createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock> {
  var _now = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // There are many ways to apply themes to your clock. Some are:
    //  - Inherit the parent Theme (see ClockCustomizer in the
    //    flutter_clock_helper package).
    //  - Override the Theme.of(context).colorScheme.
    //  - Create your own [ThemeData], demonstrated in [AnalogClock].
    //  - Create a map of [Color]s to custom keys, demonstrated in
    //    [DigitalClock].
    final customTheme = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).copyWith(
            // Hour hand.
            primaryColor: Color(0xFF4285F4),
            // Minute hand.
            highlightColor: Color(0xFF8AB4F8),
            // Second hand.
            accentColor: Color(0xFF669DF6),
            backgroundColor: Color(0xFFD2E3FC),
          )
        : Theme.of(context).copyWith(
            primaryColor: Color(0xFFD2E3FC),
            highlightColor: Color(0xFF4285F4),
            accentColor: Color(0xFF8AB4F8),
            backgroundColor: Color(0xFF3C4043),
          );

    final time = DateFormat.Hms().format(DateTime.now());
    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Analog clock with time $time',
        value: time,
      ),
      child: Container(
        color: customTheme.backgroundColor,
        child: Stack(
          children: [
            Positioned(
              left: 100,
              top: 200,
              child: AnimatedGear(
                animationDuration: 200,
                gearType: GearType.balanceWheel,
              ),
            ),
            Positioned(
              left: 151,
              top: 200,
              child: AnimatedFork(
                animationDuration: 200,
              ),
            ),
            Positioned(
              left: 200,
              top: 200,
              child: AnimatedGear(
                animationDuration: 6,
                gearType: GearType.escapementWheel,
              ),
            ),
            Positioned(
              left: 255,
              top: 198,
              child: AnimatedGear(
                animationDuration: 60,
                gearType: GearType.seconds,
                initialAngle: _now.second * radiansPerTick,
              ),
            ),
            Positioned(
              left: 311,
              top: 198,
              child: AnimatedGear(
                animationDuration: 480,
                gearType: GearType.minsec,
              ),
            ),
            Positioned(
              left: 382,
              top: 198,
              child: AnimatedGear(
                animationDuration: 3600,
                gearType: GearType.minutes,
                initialAngle: _now.minute * radiansPerTick,
              ),
            ),
            Positioned(
              left: 432,
              top: 198,
              child: AnimatedGear(
                animationDuration: 32400,
                gearType: GearType.minhour,
              ),
            ),
            Positioned(
              left: 476,
              top: 198,
              child: AnimatedGear(
                animationDuration: 86400,
                gearType: GearType.hours,
                initialAngle: _now.hour * radiansPerHour,
              ),
            ),
            Positioned(
              left: 460,
              top: 100,
              child: Text('Hours'),
            ),
            Positioned(
              left: 360,
              top: 100,
              child: Text('Minutes'),
            ),
            Positioned(
              left: 230,
              top: 100,
              child: Text('Seconds'),
            ),
          ],
        ),
      ),
    );
  }
}
