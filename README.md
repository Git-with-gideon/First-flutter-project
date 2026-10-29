# Nuru Printer: Thermal Receipt with ClipPath

A Flutter application that uses the `ClipPath` widget and a custom clipper (`ZigZagReceiptClipper`) to render torn thermal receipt paper in a point-of-sale interface.

---

## App Interface

![Nuru Printer Thermal Receipt](assets/screenshots/receipt_demo.png)

---

## 1. Real-World Problem and Practical Analogy

Most restaurant checkout screens display a flat order confirmation dialog with a spinning circle. They feel detached from the real physical experience of buying food at a counter.

This project recreates the physical feel of a thermal receipt printer. When a server taps **Print Receipt**, the app coordinates three animations:
1. Micro-vibrations across the terminal card as the simulated print head runs.
2. The paper feeding downward out of a recessed printer slot.
3. A green ink stamp (`PAID • ORDER READY`) applied at an angle to the bottom of the bill.

Users can then swipe down or tap **Tear Ticket** to detach the bill with rotation and gravity physics.

### The Cardboard Box Analogy
By default, Flutter widgets are rectangular boxes. Flutter knows how to draw borders, rounded corners, and boxes. It cannot cut jagged saw-tooth teeth or punch ticket alignment notches out of the box.

`ClipPath` solves this. You hand `ClipPath` a custom path, like a cutting stencil. Flutter runs that path through its 2D canvas and trims away everything outside your line. The widget inside stays completely intact, but its visible boundaries match your custom shape.

---

## 2. The Three Core Properties of ClipPath

Flutter defines `ClipPath` in `package:flutter/widgets.dart`. Here is how its three main constructor properties work in this application:

### Property 1: `clipper`
* **Type:** `CustomClipper<Path>?`
* **Default:** `null`
* **What it does:** When set to `null`, Flutter uses the basic bounding rectangle of the child widget. When passed `ZigZagReceiptClipper(toothWidth: 10.0, toothHeight: 7.0)`, Flutter delegates the boundary calculations to our custom path logic. It cuts triangular teeth across the bottom edge and punches circular notches into both sides.
* **Why adjust it:** Developers use this property to create non-rectangular UI elements such as ticket stubs, wave headers, coupon badges, or jagged paper edges without relying on image assets that blur on different screen densities.

### Property 2: `clipBehavior`
* **Type:** `Clip`
* **Default:** `Clip.antiAlias`
* **What it does:** Controls how the graphics engine handles pixel edges along the path.
  * `Clip.antiAlias`: Blends pixels along diagonal cuts for smooth vector edges on high-resolution screens.
  * `Clip.hardEdge`: Disables edge smoothing. Diagonal lines show pixel steps, but the GPU skips subpixel calculations.
  * `Clip.none`: Turns off boundary clipping completely, letting content bleed outside the container.
* **Why adjust it:** Developers switch from `antiAlias` to `hardEdge` when optimizing frame rates on low-end devices or during high-frequency animations where rendering speed matters more than edge smoothness.

### Property 3: `child`
* **Type:** `Widget?`
* **Default:** `null`
* **What it does:** Contains the widget tree placed inside the cutting boundary. In this app, the child is a `Container` holding the paper background, restaurant header, itemized dish list, subtotal, tax calculation, perforated fold line, barcode, and rubber stamp.
* **Why adjust it:** It wraps any arbitrary layout so the custom shape applies cleanly without needing to alter the inner column or text styling.

---

## 3. Interactive Debug Inspector

The app includes an on-screen debug panel for live demonstrations:

1. Tap the **ClipPath** button in the top right corner of the screen.
2. A bottom sheet appears with live controls:
   * **Clipper Toggle:** Switches between `ZigZagReceiptClipper` and `null` (demonstrating the fallback to a flat rectangle).
   * **ClipBehavior Selector:** Switches between `antiAlias`, `hardEdge`, and `none`.
   * **Tooth Width Slider (5.0 to 25.0 dp):** Adjusts the frequency and width of the saw-tooth cuts.
   * **Tooth Height Slider (0.0 to 14.0 dp):** Adjusts cut depth. Setting this to 0.0 creates a straight bottom edge.

All adjustments update the active receipt widget immediately.

---

## 4. Code Structure

The project separates the clipper logic from the UI presentation:

```
lib/
├── clippers/
│   └── zigzag_receipt_clipper.dart   # Vector path logic
└── main.dart                          # Terminal screen, animations, and live inspector
test/
└── widget_test.dart                   # Automated tests for layout and inspector
```

### Clipper Calculation
* **Teeth Count:** `math.max(1, (size.width / safeToothWidth).floor())`. This distributes triangular teeth evenly across any screen width.
* **Notch Placement:** `notchY ?? (size.height * 0.22)`. The side notches scale dynamically with receipt length instead of relying on fixed pixel offsets.

---

## 5. Test Suite and Static Analysis

The project compiles with zero warnings and passes all automated tests:

```bash
flutter analyze
# Result: No issues found!

flutter test
# Result: All tests passed! (2/2)
```

---

## 6. How to Run

Requirements: Flutter 3.14 or later.

```bash
# 1. Clone the repository
git clone https://github.com/Git-with-gideon/First-flutter-project.git

# 2. Enter directory
cd First-flutter-project

# 3. Get dependencies
flutter pub get

# 4. Run the project
flutter run
```

---

## 7. Credits

* **Concept:** Inspired by thermal printer animations in mobile point-of-sale designs.
* **Implementation:** Built with Flutter framework primitives (`ClipPath`, `CustomClipper`, `ClipRect`, `CustomPainter`) by **Erioluwa Gideon Olowoyo**.
