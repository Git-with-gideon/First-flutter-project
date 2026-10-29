import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:first_flutter_project/main.dart';
import 'package:first_flutter_project/clippers/zigzag_receipt_clipper.dart';

void main() {
  testWidgets('Nuru Printer POS renders cleanly with ClipPath and triggers print flow',
      (WidgetTester tester) async {
    // 1. Pump the root NuruPrinterApp
    await tester.pumpWidget(const NuruPrinterApp());
    await tester.pumpAndSettle();

    // 2. Verify branding and header
    expect(find.text('N U R U   &   W I Z Z Y'), findsWidgets);
    expect(find.text('Table 04 • Tasting Menu'), findsOneWidget);

    // 3. Verify total due and action button
    expect(find.text('TOTAL DUE'), findsOneWidget);
    expect(find.text('RWF 16500'), findsWidgets);
    expect(find.text('Print Receipt'), findsOneWidget);

    // 4. Verify ClipPath widget is present in tree
    final clipPathFinder = find.byType(ClipPath);
    expect(clipPathFinder, findsWidgets);

    final clipPathWidget = tester.widget<ClipPath>(clipPathFinder.first);
    expect(clipPathWidget.clipBehavior, Clip.antiAlias);
    expect(clipPathWidget.clipper, isA<ZigZagReceiptClipper>());

    // 5. Trigger print receipt and verify dynamic state feedback
    await tester.tap(find.text('Print Receipt'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('PRINTING...'), findsOneWidget);
  });

  testWidgets('ClipPath inspector modal opens and exposes clipper and clipBehavior controls',
      (WidgetTester tester) async {
    await tester.pumpWidget(const NuruPrinterApp());
    await tester.pumpAndSettle();

    // Tap the ClipPath inspector button in header
    final inspectorButton = find.text('ClipPath');
    expect(inspectorButton, findsOneWidget);
    await tester.tap(inspectorButton);
    await tester.pumpAndSettle();

    // Verify properties are exposed in modal
    expect(find.text('ClipPath Property Inspector'), findsOneWidget);
    expect(find.text('1. clipper: CustomClipper<Path>?'), findsOneWidget);
    expect(find.text('2. clipBehavior: Clip'), findsOneWidget);
    expect(find.text('antiAlias'), findsOneWidget);
    expect(find.text('hardEdge'), findsOneWidget);
    expect(find.text('none'), findsOneWidget);
  });
}
