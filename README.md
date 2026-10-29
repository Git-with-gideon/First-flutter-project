# Nuru Printer — `ClipPath` Thermal Receipt Showcase

A production-grade Flutter demonstration showcasing Flutter's **`ClipPath`** framework widget paired with a modular **`ZigZagReceiptClipper`** to render physical, serrated thermal receipt tickets for dining point-of-sale (POS) systems.

---

## Final App UI

![Nuru Printer Thermal Receipt Screenshot](assets/screenshots/receipt_demo.png)

---

## 1. Real-World Use Case & The Core Analogy (Sayed Protocol)

In typical point-of-sale (POS) and food-delivery apps, completing an order feels flat: you tap "Pay", a generic circular spinner spins, and a standard static dialog pops up.

**Nuru Printer** introduces tactile physical feedback to the screen. In our restaurant scenario (**Nuru & Wizzy**, Table 04, Order #419), when a waiter taps **Print Receipt**, the app coordinates Flutter's vector clipping engine and staggered animation curves to simulate:
1. Micro-jitter vibrations as the thermal printer head engages.
2. Extruding paper from a recessed, glowing printer slot.
3. Stamping an angled rubber ink seal (`PAID • ORDER READY`) onto the ticket.
4. Enabling a natural drag-down swipe or button tap to tear the paper away with rotation and drop physics.

### The Everyday Analogy
> Think of Flutter widgets as plain cardboard shipping boxes. By default, Flutter only knows how to cut 90-degree rectangles. It cannot cut jagged saw-tooth edges or punch circular ticket notches on its own.
>
> **`ClipPath`** is handing Flutter a custom stencil and a pair of serrated zig-zag pinking shears. You drop whatever you want inside the box (your receipt text, totals, barcode, rubber stamp), place the stencil on top, and `ClipPath` slices away everything outside your custom chalk line.

---

## 2. Key Widget & The Three Core Constructor Properties

The core Flutter framework primitive powering the physical paper ticket is **`ClipPath`** (located in `lib/main.dart` at line 460). 

Here are the three concrete constructor properties required by the rubric:

### Attribute 1: `clipper`
* **Type:** `CustomClipper<Path>?`
* **Default Value:** `null`
* **Visual Effect & Demonstration:**
  * When `clipper` is left as default (`null`), Flutter performs no custom shape manipulation; the receipt renders as a plain, flat rectangular box.
  * When set to our custom `ZigZagReceiptClipper(toothWidth: 10.0, toothHeight: 7.0)`, Flutter delegates path calculation to our 2D coordinate loop. It slices real triangular saw-tooth teeth across the bottom edge and punches circular ticket notches into the left and right sides.
* **Why a developer adjusts it:** Passing a custom clipper lets developers break free from standard rectangles to build authentic paper tickets, wave headers, ticket vouchers, or badge cutouts that scale dynamically across different screen widths without image distortion.

### Attribute 2: `clipBehavior`
* **Type:** `Clip`
* **Default Value:** `Clip.antiAlias`
* **Visual Effect & Demonstration:**
  * `Clip.antiAlias` (default): Flutter smoothes the edges of the diagonal saw-tooth teeth, ensuring crisp, clean lines on high-resolution displays.
  * `Clip.hardEdge`: Disables anti-aliasing. The diagonal cuts of the teeth show visible pixel staircasing (aliasing), but it saves GPU fill-rate cycles.
  * `Clip.none`: Skips clipping entirely, rendering child overflow beyond the boundaries.
* **Why a developer adjusts it:** A developer changes `clipBehavior` to balance visual fidelity against 60fps/120fps render budgets on low-spec hardware or during high-frequency extrusion animations.

### Attribute 3: `child`
* **Type:** `Widget?`
* **Default Value:** `null`
* **Visual Effect & Demonstration:**
  * The `child` receives the entire nested paper layout: order header, itemized dishes (`Kigali Suya Skewers`, `Truffle Herb Fries`, `Zobo Ginger Fizz`), subtotal, tax calculation, perforated divider line, barcode, and stamp.
  * The clipping boundary applies cleanly to the outer edge of this child without disturbing any of the inner padding, column alignment, or typography.
* **Why a developer adjusts it:** It allows any arbitrary widget tree (whether simple text or a complex scrollable column) to adopt the custom shape without rewriting internal layout code.

---

## 3. Interactive Live Debug Control Panel (In-Class Defense)

To satisfy live presentation criteria without needing hot-reload during a defense, the app features an on-screen **ClipPath Inspector**:

1. Tap the **`ClipPath`** badge in the top right header.
2. A bottom sheet modal opens with live hardware controls:
   * **`clipper` Toggle:** Switch live between `ZigZagReceiptClipper` and `null [Default Rectangle]`.
   * **`clipBehavior` Selector:** Instant switching between `Clip.antiAlias`, `Clip.hardEdge`, and `Clip.none`.
   * **`toothWidth` Slider (5.0 – 25.0 dp):** Controls the horizontal frequency of the teeth.
   * **`toothHeight` Slider (0.0 – 14.0 dp):** Controls the vertical cut depth (set to 0 for a straight cut).

---

## 4. Architecture & Clean Modular Structure

The codebase is split into modular primitives rather than a single monolithic file:

```
lib/
├── clippers/
│   └── zigzag_receipt_clipper.dart   # Pure CustomClipper<Path> vector engine
└── main.dart                          # Root app, tokens, animations & live inspector
test/
└── widget_test.dart                   # Automated tests verifying layout & inspector
```

### Clipper Parameter Math (`ZigZagReceiptClipper`)
* **`toothWidth` (default: `10.0`):** Calculates `teethCount = (size.width / toothWidth).floor()`. Evenly distributes triangular vertices right-to-left.
* **`toothHeight` (default: `7.0`):** Vector height offset applied to alternating bottom path vertices.
* **`notchY` & `notchRadius`:** Automatically calculates ticket punch circles at 22% of total height (`size.height * 0.22`), completely eliminating brittle hardcoded magic numbers.

---

## 5. Automated Verification & Quality Gates

The project passes all static analysis and automated test gates:

```bash
# Static analysis: 0 warnings, 0 errors
flutter analyze
# Output: No issues found!

# Unit & Widget Test Suite:
flutter test
# Output: All tests passed! (2/2 passed)
```

---

## 6. How to Run

Ensure Flutter SDK is installed:

```bash
# 1. Clone repository
git clone https://github.com/Git-with-gideon/First-flutter-project.git

# 2. Navigate to project
cd First-flutter-project

# 3. Fetch dependencies
flutter pub get

# 4. Run on connected mobile device, emulator, or desktop
flutter run
```

---

## 7. Credits & Attribution

* **Interaction Concept:** Inspired by thermal receipt animation patterns in modern POS UI design.
* **Architecture & Implementation:** Built with pure Flutter framework primitives (`ClipPath`, `CustomClipper`, `ClipRect`, and `CustomPainter`) by **Gideon Olowoyo**. Zero external animation packages used.
