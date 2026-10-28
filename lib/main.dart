import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const AurumSageApp());
}


class StudioTokens {
  static const Color background = Color(0xFF0C0D0F);
  static const Color surface = Color(0xFF14161A);
  static const Color surfaceBorder = Color(0xFF22262E);
  static const Color slotColor = Color(0xFF07080A);

  // Golden-Green color
  static const Color goldenGreen = Color(0xFF9EAD86);
  static const Color goldenGreenGlow = Color(0xFFB5C49E);
  static const Color warmGold = Color(0xFFC8A97E);

  // Thermal Receipt Paper
  static const Color thermalPaper = Color(0xFFFAF7F0);
  static const Color carbonInk = Color(0xFF18191B);
  static const Color mutedInk = Color(0xFF72706B);

  static TextStyle mono({
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w600,
    Color color = Colors.white,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: 'monospace',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle sans({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w600,
    Color color = Colors.white,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }
}

class AurumSageApp extends StatelessWidget {
  const AurumSageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NURU PRINTER',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: StudioTokens.background,
        colorScheme: const ColorScheme.dark(
          primary: StudioTokens.goldenGreen,
          surface: StudioTokens.surface,
        ),
        useMaterial3: true,
      ),
      home: const CleanReceiptScreen(),
    );
  }
}

class CleanReceiptScreen extends StatefulWidget {
  const CleanReceiptScreen({super.key});

  @override
  State<CleanReceiptScreen> createState() => _CleanReceiptScreenState();
}

class _CleanReceiptScreenState extends State<CleanReceiptScreen>
    with TickerProviderStateMixin {
  late final AnimationController _printController;
  late final AnimationController _tearController;

  late final Animation<double> _paperFeedAnim;
  late final Animation<double> _stampAnim;
  late final Animation<double> _tearDropAnim;
  late final Animation<double> _tearRotateAnim;

  bool _isPrinted = false;
  int _orderId = 419;

  final List<Map<String, dynamic>> _items = [
    {'name': 'chapita(FROM TEMU)', 'price': 2000.00, 'qty': 1},
    {'name': 'Chicken & fries', 'price': 5000.00, 'qty': 1},
    {'name': 'Coca-Cola', 'price': 1500.00, 'qty': 1},
  ];

  double get _subtotal => _items.fold(
        0.0,
        (sum, item) => sum + (item['price'] as double) * (item['qty'] as int),
      );

  double get _tax => _subtotal * 0.10; // 10%
  double get _total => _subtotal + _tax;

  @override
  void initState() {
    super.initState();

    _printController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _paperFeedAnim = CurvedAnimation(
      parent: _printController,
      curve: const Interval(0.08, 0.85, curve: Curves.easeOutCubic),
    );

    _stampAnim = CurvedAnimation(
      parent: _printController,
      curve: const Interval(0.80, 1.0, curve: Curves.elasticOut),
    );

    _tearController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _tearDropAnim = Tween<double>(begin: 0.0, end: 420.0).animate(
      CurvedAnimation(parent: _tearController, curve: Curves.easeInQuad),
    );

    _tearRotateAnim = Tween<double>(begin: 0.0, end: -0.08).animate(
      CurvedAnimation(parent: _tearController, curve: Curves.easeOut),
    );

    _printController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        HapticFeedback.mediumImpact();
        setState(() => _isPrinted = true);
      }
    });
  }

  @override
  void dispose() {
    _printController.dispose();
    _tearController.dispose();
    super.dispose();
  }

  void _triggerPrint() {
    if (_printController.isAnimating) return;
    HapticFeedback.selectionClick();
    setState(() => _isPrinted = false);
    _tearController.reset();
    _printController.forward(from: 0.0);
  }

  Future<void> _triggerTear() async {
    if (!_isPrinted || _tearController.isAnimating) return;
    HapticFeedback.heavyImpact();
    await _tearController.forward(from: 0.0);
    setState(() {
      _orderId++;
      _isPrinted = false;
      _printController.reset();
      _tearController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StudioTokens.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 18),
            // Minimal, elegant brand title
            _buildMinimalHeader(),
            const SizedBox(height: 24),

            // Center: The Clean Order Card + Extruding Receipt Paper
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  children: [
                    _buildOrderTerminalCard(),
                  ],
                ),
              ),
            ),

            // Bottom: Single sleek minimal CTA button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              child: _buildActionButton(),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // 1. MINIMAL HEADER
  // ==========================================================================
  Widget _buildMinimalHeader() {
    return Column(
      children: [
        Text(
          'N U R U & W I Z Z Y',
          style: StudioTokens.mono(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 3.2,
            color: StudioTokens.goldenGreen,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Table 04 • Tasting Menu',
          style: StudioTokens.sans(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }

  // ---
  // 2. THE ORDER TERMINAL + RECEIPT EXTRUSION
  // ----
  Widget _buildOrderTerminalCard() {
    return AnimatedBuilder(
      animation: Listenable.merge([_printController, _tearController]),
      builder: (context, _) {
        final bool isPrinting =
            _printController.isAnimating && _paperFeedAnim.value < 1.0;

        // Subtle micro-shake while printer head runs
        final double jitterX = isPrinting
            ? math.sin(_printController.value * math.pi * 32) * 1.2
            : 0.0;

        return Transform.translate(
          offset: Offset(jitterX, 0),
          child: Column(
            children: [
              // THE MINIMAL TOP CARD (Order details + total)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                decoration: BoxDecoration(
                  color: StudioTokens.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(22),
                    bottom: Radius.circular(14),
                  ),
                  border: Border.all(color: StudioTokens.surfaceBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOTAL DUE',
                              style: StudioTokens.mono(
                                fontSize: 10,
                                letterSpacing: 1.5,
                                color: StudioTokens.goldenGreen,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'RWF ${_total.toStringAsFixed(0)}',
                              style: StudioTokens.sans(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        // Clean status pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: isPrinting
                                ? StudioTokens.warmGold.withValues(alpha: 0.15)
                                : (_isPrinted
                                    ? StudioTokens.goldenGreen
                                        .withValues(alpha: 0.15)
                                    : Colors.white.withValues(alpha: 0.05)),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isPrinting
                                  ? StudioTokens.warmGold.withValues(alpha: 0.4)
                                  : (_isPrinted
                                      ? StudioTokens.goldenGreen
                                          .withValues(alpha: 0.5)
                                      : Colors.white12),
                            ),
                          ),
                          child: Text(
                            isPrinting
                                ? 'PRINTING...'
                                : (_isPrinted ? 'READY' : 'CONFIRMED'),
                            style: StudioTokens.mono(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: isPrinting
                                  ? StudioTokens.warmGold
                                  : (_isPrinted
                                      ? StudioTokens.goldenGreen
                                      : Colors.white60),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Subtle item summary line
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '3 Courses • 1 Guest',
                          style: StudioTokens.sans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                            color: Colors.white54,
                          ),
                        ),
                        Text(
                          'Order #$_orderId',
                          style: StudioTokens.mono(
                            fontSize: 11.5,
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Recessed Paper Exit Slot
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: StudioTokens.slotColor,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Center(
                        child: Container(
                          height: 1.5,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          color: isPrinting
                              ? StudioTokens.goldenGreen.withValues(alpha: 0.7)
                              : Colors.white10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // THE PHYSICAL THERMAL PAPER (Emerges from slot)
              ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: _paperFeedAnim.value,
                  child: Transform.translate(
                    offset: Offset(0, _tearDropAnim.value),
                    child: Transform.rotate(
                      angle: _tearRotateAnim.value,
                      alignment: Alignment.topRight,
                      child: Opacity(
                        opacity: (1.0 - (_tearController.value * 1.2))
                            .clamp(0.0, 1.0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: GestureDetector(
                            onVerticalDragEnd: (details) {
                              if ((details.primaryVelocity ?? 0) > 160) {
                                _triggerTear();
                              }
                            },
                            child: _buildCleanPaper(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================================
  // 3. THE CLEAN SERRATED PAPER RECEIPT
  // ==========================================================================
  Widget _buildCleanPaper() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipPath(
        clipper: const ZigZagReceiptClipper(toothWidth: 10, toothHeight: 7),
        child: Container(
          color: StudioTokens.thermalPaper,
          child: Stack(
            children: [
              // Inner top shadow for paper slot depth
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 14,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.28),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Text(
                        'N U R U   &   W I Z Z Y',
                        style: StudioTokens.mono(
                          color: StudioTokens.carbonInk,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Center(
                      child: Text(
                        'Dine-in • Table 04 • Server: Gideon',
                        style: StudioTokens.mono(
                          color: StudioTokens.mutedInk,
                          fontSize: 9.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Dashed line
                    const SizedBox(
                      height: 2,
                      width: double.infinity,
                      child: CustomPaint(painter: DashedReceiptLinePainter()),
                    ),
                    const SizedBox(height: 12),

                    // Items
                    ..._items.map((item) {
                      final name = item['name'] as String;
                      final price = item['price'] as double;
                      final qty = item['qty'] as int;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 7),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${qty}x  $name',
                              style: StudioTokens.mono(
                                color: StudioTokens.carbonInk,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              'RWF ${(price * qty).toStringAsFixed(2)}',
                              style: StudioTokens.mono(
                                color: StudioTokens.carbonInk,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 8),
                    const SizedBox(
                      height: 2,
                      width: double.infinity,
                      child: CustomPaint(painter: DashedReceiptLinePainter()),
                    ),
                    const SizedBox(height: 10),

                    // Totals
                    _buildReceiptRow('SUBTOTAL', _subtotal),
                    const SizedBox(height: 4),
                    _buildReceiptRow('TAX (10%)', _tax),
                    const SizedBox(height: 10),

                    // Total Bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 8,
                      ),
                      color: StudioTokens.carbonInk,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TOTAL',
                            style: StudioTokens.mono(
                              color: StudioTokens.thermalPaper,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'RWF ${_total.toStringAsFixed(2)}',
                            style: StudioTokens.mono(
                              color: StudioTokens.thermalPaper,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Barcode
                    SizedBox(
                      height: 32,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: ThermalBarcodePainter(seed: _orderId),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        '*AS-$_orderId-T04*',
                        style: StudioTokens.mono(
                          color: StudioTokens.mutedInk,
                          fontSize: 9,
                          letterSpacing: 2.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // GOLDEN-GREEN RUBBER INK STAMP
              if (_stampAnim.value > 0.01)
                Positioned(
                  right: 20,
                  bottom: 58,
                  child: Transform.scale(
                    scale: 2.0 - (1.0 * _stampAnim.value),
                    child: Transform.rotate(
                      angle: -0.18,
                      child: Opacity(
                        opacity: _stampAnim.value.clamp(0.0, 0.95),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF6C8352),
                              width: 2.2,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            'PAID • ORDER READY',
                            style: StudioTokens.mono(
                              color: const Color(0xFF6C8352),
                              fontWeight: FontWeight.w900,
                              fontSize: 10.5,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: StudioTokens.mono(
            color: StudioTokens.mutedInk,
            fontSize: 10,
          ),
        ),
        Text(
          'RWF ${amount.toStringAsFixed(2)}',
          style: StudioTokens.mono(
            color: StudioTokens.carbonInk,
            fontWeight: FontWeight.w600,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  // ----
  // 4. BOTTOM SLEEK MINIMAL CTA BUTTON
  // ----
  Widget _buildActionButton() {
    final bool isPrinting = _printController.isAnimating;

    if (_isPrinted) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: _triggerTear,
          style: ElevatedButton.styleFrom(
            backgroundColor: StudioTokens.goldenGreen,
            foregroundColor: StudioTokens.background,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.content_cut_rounded, size: 18),
          label: Text(
            'Tear Ticket (or Swipe Down)',
            style: StudioTokens.sans(
              fontWeight: FontWeight.w700,
              fontSize: 14.5,
              color: StudioTokens.background,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: isPrinting ? null : _triggerPrint,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isPrinting
                ? StudioTokens.goldenGreen.withValues(alpha: 0.3)
                : StudioTokens.goldenGreen,
            width: 1.4,
          ),
          foregroundColor: StudioTokens.goldenGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: isPrinting
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  color: StudioTokens.goldenGreen,
                ),
              )
            : const Icon(Icons.receipt_long_rounded, size: 19),
        label: Text(
          isPrinting ? 'Feeding Receipt...' : 'Print Receipt',
            style: StudioTokens.sans(
            fontWeight: FontWeight.w700,
            fontSize: 14.5,
            color: StudioTokens.goldenGreen,
          ),
        ),
      ),
    );
  }
}

// ----
// CUSTOM CLIPPER: SERRATED ZIG-ZAG TEETH & TICKET NOTCHES
// ----
class ZigZagReceiptClipper extends CustomClipper<Path> {
  final double toothWidth;
  final double toothHeight;

  const ZigZagReceiptClipper({
    this.toothWidth = 10.0,
    this.toothHeight = 7.0,
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

    path.moveTo(0, 0);
    path.lineTo(size.width, 0);

    // Right edge down with subtle notch
    const double notchY = 95.0;
    const double notchRadius = 6.0;
    if (size.height > notchY + notchRadius * 2) {
      path.lineTo(size.width, notchY - notchRadius);
      path.arcToPoint(
        Offset(size.width, notchY + notchRadius),
        radius: const Radius.circular(notchRadius),
        clockwise: false,
      );
    }

    path.lineTo(size.width, size.height - toothHeight);

    // Bottom zig-zag teeth
    final int teethCount = math.max(1, (size.width / toothWidth).floor());
    final double adjustedToothWidth = size.width / teethCount;

    for (int i = 0; i < teethCount; i++) {
      final double xMid =
          size.width - (i * adjustedToothWidth) - (adjustedToothWidth / 2);
      final double xLeft = size.width - ((i + 1) * adjustedToothWidth);
      path.lineTo(xMid, size.height);
      path.lineTo(xLeft, size.height - toothHeight);
    }

    // Left edge up with subtle notch
    if (size.height > notchY + notchRadius * 2) {
      path.lineTo(0, notchY + notchRadius);
      path.arcToPoint(
        const Offset(0, notchY - notchRadius),
        radius: const Radius.circular(notchRadius),
        clockwise: false,
      );
    }

    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant ZigZagReceiptClipper oldClipper) =>
      oldClipper.toothWidth != toothWidth ||
      oldClipper.toothHeight != toothHeight;
}

// ----
// CUSTOM PAINTER: PERFORATED DASHED LINE
// ----
class DashedReceiptLinePainter extends CustomPainter {
  const DashedReceiptLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double maxWidth =
        (size.width.isFinite && size.width > 0) ? size.width : 260.0;
    final Paint paint = Paint()
      ..color = const Color(0xFFC0B9A8)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const double dashWidth = 4.5;
    const double dashSpace = 3.5;
    double startX = 0.0;

    while (startX < maxWidth) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(math.min(startX + dashWidth, maxWidth), size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ----
// CUSTOM PAINTER: VECTOR BARCODE
// ----
class ThermalBarcodePainter extends CustomPainter {
  final int seed;

  const ThermalBarcodePainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final double width =
        (size.width.isFinite && size.width > 24) ? size.width : 260.0;
    final Paint paint = Paint()
      ..color = StudioTokens.carbonInk
      ..style = PaintingStyle.fill;

    final math.Random rng = math.Random(seed);
    double x = 12.0;
    final double maxX = width - 12.0;

    while (x < maxX) {
      final double barWidth = (rng.nextInt(3) + 1) * 1.5;
      final double gapWidth = (rng.nextInt(2) + 1) * 1.7;
      if (x + barWidth <= maxX) {
        canvas.drawRect(
          Rect.fromLTWH(x, 0, barWidth, size.height),
          paint,
        );
      }
      x += barWidth + gapWidth;
    }
  }

  @override
  bool shouldRepaint(covariant ThermalBarcodePainter oldDelegate) =>
      oldDelegate.seed != seed;
}
