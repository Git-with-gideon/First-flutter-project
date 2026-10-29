import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A custom vector clipper that cuts a jagged saw-tooth bottom edge
/// and circular ticket alignment notches into any rectangular widget.
///
/// Used with Flutter's [ClipPath] to simulate physically torn thermal receipt
/// paper in point-of-sale applications.
class ZigZagReceiptClipper extends CustomClipper<Path> {
  /// The horizontal width of each individual triangular saw tooth.
  /// Smaller values yield fine register perforations; larger values yield coupon-style tabs.
  final double toothWidth;

  /// The vertical depth of each triangular saw tooth cut.
  /// Set to 0.0 for a clean straight cut, or higher for exaggerated tearing.
  final double toothHeight;

  /// Optional absolute vertical position (from the top) for the ticket notches.
  /// If omitted (null), the clipper calculates this proportionally at 22% of total height.
  final double? notchY;

  /// The radius of the circular alignment punch notches on the left and right edges.
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

    // Guard against degenerate or zero-size canvas dimensions
    if (!size.width.isFinite ||
        !size.height.isFinite ||
        size.width <= 0 ||
        size.height <= toothHeight) {
      return path;
    }

    // Dynamic notch positioning: adapt proportionally if no static override is supplied
    final double resolvedNotchY =
        notchY ?? (size.height * 0.22).clamp(40.0, size.height * 0.4);

    // 1. Start at top-left corner
    path.moveTo(0, 0);

    // 2. Top straight edge across to top-right
    path.lineTo(size.width, 0);

    // 3. Right edge down, punching the right ticket notch if height permits
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

    // 4. Serrated bottom zig-zag edge (traversed right-to-left)
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

    // 5. Left edge up, punching the matching left ticket notch
    if (canPunchNotch) {
      path.lineTo(0, resolvedNotchY + notchRadius);
      path.arcToPoint(
        Offset(0, resolvedNotchY - notchRadius),
        radius: Radius.circular(notchRadius),
        clockwise: false,
      );
    }

    // 6. Return to origin and seal the vector path
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
