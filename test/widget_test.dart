import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:first_flutter_project/main.dart';
import 'package:first_flutter_project/clippers/zigzag_receipt_clipper.dart';

void main() {
  testWidgets('Nuru Printer POS renders cleanly with ClipPath and triggers print flow',
      (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const NuruPrinterApp());
    await tester.pumpAndSettle();

    // Check header content
    expect(find.text('N U R U   &   W I Z Z Y'), findsWidgets);
    expect(find.text('Table 04 • Tasting Menu'), findsOneWidget);

    // Check order card and print button
    expect(find.text('TOTAL DUE'), findsOneWidget);
    expect(find.text('RWF 16500'), findsWidgets);
    expect(find.text('Print Receipt'), findsOneWidget);

    // Check default ClipPath configuration
    final clipPathFinder = find.byType(ClipPath);
    expect(clipPathFinder, findsWidgets);

    final clipPathWidget = tester.widget<ClipPath>(clipPathFinder.first);
    expect(clipPathWidget.clipBehavior, Clip.antiAlias);
    expect(clipPathWidget.clipper, isA<ZigZagReceiptClipper>());

    // Tap print and check status
    await tester.tap(find.text('Print Receipt'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('PRINTING...'), findsOneWidget);
  });

  testWidgets('ClipPath inspector modal opens and exposes clipper and clipBehavior controls',
      (WidgetTester tester) async {
    await tester.pumpWidget(const NuruPrinterApp());
    await tester.pumpAndSettle();

    // Open inspector from header
    final inspectorButton = find.text('ClipPath');
    expect(inspectorButton, findsOneWidget);
    await tester.tap(inspectorButton);
    await tester.pumpAndSettle();

    // Verify inspector properties
    expect(find.text('ClipPath Property Inspector'), findsOneWidget);
    expect(find.text('1. clipper: CustomClipper<Path>?'), findsOneWidget);
    expect(find.text('2. clipBehavior: Clip'), findsOneWidget);
    expect(find.text('antiAlias'), findsOneWidget);
    expect(find.text('hardEdge'), findsOneWidget);
    expect(find.text('none'), findsOneWidget);
  });
}
