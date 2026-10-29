import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Cuts saw-tooth jagged teeth along the bottom edge of a widget
/// and punches circular ticket notches on the left and right sides.
///
/// Use this with [ClipPath] to shape thermal receipt paper.
class ZigZagReceiptClipper extends CustomClipper<Path> {
  /// Width of each triangular tooth in pixels.
  final double toothWidth;

  /// Depth of each tooth cut. Set to 0.0 for a flat bottom.
  final double toothHeight;

  /// Distance from top edge to the ticket notches.
  /// Defaults to 22% of widget height when null.
  final double? notchY;

  /// Radius of the semicircular side cutouts.
  final double notchRadius;

  const ZigZagReceiptClipper({
    this.toothWidth = 10.0,
    this.toothHeight = 7.0,
    this.notchY,
    this.notchRadius = 6.0,
  });

  @override
  Path getClip(Size size) {
    final Path path = Path();

    if (!size.width.isFinite ||
        !size.height.isFinite ||
        size.width <= 0 ||
        size.height <= toothHeight) {
      return path;
    }

    // Keep notches roughly a quarter down the ticket if no static offset is given.
    final double resolvedNotchY =
        notchY ?? (size.height * 0.22).clamp(40.0, size.height * 0.4);

    // Top-left origin
    path.moveTo(0, 0);

    // Top straight edge
    path.lineTo(size.width, 0);

    // Right edge and right notch
    final bool canPunchNotch =
        size.height > resolvedNotchY + (notchRadius * 2.5);
    if (canPunchNotch) {
      path.lineTo(size.width, resolvedNotchY - notchRadius);
      path.arcToPoint(
        Offset(size.width, resolvedNotchY + notchRadius),
        radius: Radius.circular(notchRadius),
        clockwise: false,
      );
    }
    path.lineTo(size.width, size.height - toothHeight);

    // Bottom saw-tooth edge drawn from right to left
    final double safeToothWidth = math.max(2.0, toothWidth);
    final int teethCount = math.max(1, (size.width / safeToothWidth).floor());
    final double adjustedToothWidth = size.width / teethCount;

    for (int i = 0; i < teethCount; i++) {
      final double xMid =
          size.width - (i * adjustedToothWidth) - (adjustedToothWidth / 2);
      final double xLeft = size.width - ((i + 1) * adjustedToothWidth);
      path.lineTo(xMid, size.height);
      path.lineTo(xLeft, size.height - toothHeight);
    }

    // Left edge and left notch
    if (canPunchNotch) {
      path.lineTo(0, resolvedNotchY + notchRadius);
      path.arcToPoint(
        Offset(0, resolvedNotchY - notchRadius),
        radius: Radius.circular(notchRadius),
        clockwise: false,
      );
    }

    // Return to start
    path.lineTo(0, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant ZigZagReceiptClipper oldClipper) =>
      oldClipper.toothWidth != toothWidth ||
      oldClipper.toothHeight != toothHeight ||
      oldClipper.notchY != notchY ||
      oldClipper.notchRadius != notchRadius;
}
