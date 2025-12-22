import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:barcode_widget/barcode_widget.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          bottom: false,
          child: Row(children: [
            Container(
              width: 400,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  right: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Iconsax.receipt,
                            color: Colors.orange.shade700,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Receipts",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: TextEditingController(),
                      decoration: InputDecoration(
                        hintText: "Search",
                        prefixIcon: const Icon(Iconsax.search_normal, size: 20),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade200,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade500,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Divider(
                            color: Colors.grey.shade200,
                            thickness: 2,
                            height: 5,
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                            child: Text(
                              'Saturday, December 20, 2025',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ),
                          Divider(
                            color: Colors.grey.shade200,
                            thickness: 2,
                            height: 5,
                          ),
                          // List 1
                          ListView.builder(
                            padding: const EdgeInsets.all(0),
                            shrinkWrap:
                                true, // Wajib: agar list tidak mencoba expand tanpa batas
                            physics:
                                const NeverScrollableScrollPhysics(), // Wajib: matikan scroll list ini
                            itemCount: 5,
                            itemBuilder: (context, index) {
                              final amount = (index + 1) * 15000;
                              final money =
                                  "Rp${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
                              final transactionid = "#1-000${index + 1}";
                              return Column(
                                children: [
                                  Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(12, 8, 12, 8),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Iconsax.wallet,
                                          color: Colors.grey.shade800,
                                          size: 32,
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              money,
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            Text(
                                              '8.45 AM',
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        Text(
                                          transactionid,
                                        )
                                      ],
                                    ),
                                  ),
                                  index != 4
                                      ? Divider(
                                          color: Colors.grey.shade200,
                                          thickness: 2,
                                          height: 5,
                                        )
                                      : const SizedBox(),
                                ],
                              );
                            },
                          ),

                          // Grup Tanggal Kedua
                          Divider(
                            color: Colors.grey.shade200,
                            thickness: 2,
                            height: 5,
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                            child: Text(
                              'Friday, December 19, 2025',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ),
                          Divider(
                            color: Colors.grey.shade200,
                            thickness: 2,
                            height: 5,
                          ),

                          // List 2
                          ListView.builder(
                            shrinkWrap: true, // Wajib
                            physics:
                                const NeverScrollableScrollPhysics(), // Wajib
                            itemCount: 5,
                            itemBuilder: (context, index) {
                              final amount = (index + 1) * 15000;
                              final money =
                                  "Rp${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
                              final transactionid = "#1-000${index + 1}";
                              return Column(
                                children: [
                                  Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(12, 8, 12, 8),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Iconsax.wallet,
                                          color: Colors.grey.shade800,
                                          size: 32,
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              money,
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            Text(
                                              '8.45 AM',
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        Text(
                                          transactionid,
                                        )
                                      ],
                                    ),
                                  ),
                                  index != 4
                                      ? Divider(
                                          color: Colors.grey.shade200,
                                          thickness: 2,
                                          height: 5,
                                        )
                                      : const SizedBox(),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            VerticalDivider(
              color: Colors.grey.shade200,
              thickness: 1,
              width: 1,
            ),
            Expanded(
                child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    color: Colors.grey.shade100,
                    child: Center(
                      child: CustomPaint(
                        painter: ZigZagShadowPainter(),
                        child: ClipPath(
                          clipper: ZigZagClipper(),
                          child: Container(
                            width: 400,
                            color: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 48, vertical: 32),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    "KasirGo",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Jl. Setiabudhi No. 123, Jakarta',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.grey.shade900,
                                    ),
                                  ),
                                  Text(
                                    'Telp: 021-23456789',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.grey.shade900,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16.0),
                                    child: DashedDivider(
                                        color: Colors.grey.shade700),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'No. Order',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w300,
                                          color: Colors.grey.shade900,
                                        ),
                                      ),
                                      const Spacer(),
                                      const Text(
                                        'ORD-001',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        'Tanggal',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w300,
                                          color: Colors.grey.shade900,
                                        ),
                                      ),
                                      const Spacer(),
                                      const Text(
                                        '20 Dec 25 08.45',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        'Kasir',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w300,
                                          color: Colors.grey.shade900,
                                        ),
                                      ),
                                      const Spacer(),
                                      const Text(
                                        'Bahlil',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        'Pembayaran',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w300,
                                          color: Colors.grey.shade900,
                                        ),
                                      ),
                                      const Spacer(),
                                      const Text(
                                        'Cash',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        'Status',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w300,
                                          color: Colors.grey.shade900,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade100,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Text(
                                          'Paid',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.green.shade500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16.0),
                                    child: DashedDivider(
                                        color: Colors.grey.shade700),
                                  ),
                                  Text(
                                    'Americano',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        '2 x Rp 40.000',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w300,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                      const Spacer(),
                                      const Text(
                                        'Rp 80.000',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Americano',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        '2 x Rp 40.000',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w300,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                      const Spacer(),
                                      const Text(
                                        'Rp 80.000',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Croissant',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        '2 x Rp 18.000',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w300,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                      const Spacer(),
                                      const Text(
                                        'Rp 36.000',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16.0),
                                    child: DashedDivider(
                                        color: Colors.grey.shade700),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Subtotal',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w300,
                                          color: Colors.grey.shade900,
                                        ),
                                      ),
                                      const Spacer(),
                                      const Text(
                                        'Rp 116.000',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        'Tax (10%)',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w300,
                                          color: Colors.grey.shade900,
                                        ),
                                      ),
                                      const Spacer(),
                                      const Text(
                                        'Rp 11.600',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16.0),
                                    child: DashedDivider(
                                        color: Colors.grey.shade700),
                                  ),
                                  const SizedBox(height: 4),
                                  const Row(
                                    children: [
                                      Text(
                                        'TOTAL',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Spacer(),
                                      Text(
                                        'Rp 127.600',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16.0),
                                    child: DashedDivider(
                                        color: Colors.grey.shade700),
                                  ),
                                  Text(
                                    'Terima kasih atas kunjungan anda!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.grey.shade900,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Barang yang sudah dibeli tidak dapat',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.grey.shade900,
                                    ),
                                  ),
                                  Text(
                                    'dikembalikan',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.grey.shade900,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  BarcodeWidget(
                                    barcode: Barcode.code128(),
                                    data: 'ORD-001',
                                    height: 50,
                                    drawText: false,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'ORD-001',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.grey.shade900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )))
          ])),
    );
  }
}

Path getZigZagPath(Size size) {
  Path path = Path();
  // Smaller zig-zag size
  double toothWidth = 10.0;
  double toothHeight = 6.0;

  // Calculate exact tooth width to fit perfectly
  int count = (size.width / toothWidth).ceil();
  double actualToothWidth = size.width / count;

  path.moveTo(0, toothHeight);

  // Top Zigzag (Spikes pointing up)
  for (int i = 0; i < count; i++) {
    double x = i * actualToothWidth;
    path.lineTo(x + actualToothWidth / 2, 0);
    path.lineTo(x + actualToothWidth, toothHeight);
  }

  // Right Side
  path.lineTo(size.width, size.height - toothHeight);

  // Bottom Zigzag (Spikes pointing down)
  for (int i = 0; i < count; i++) {
    double x = size.width - (i * actualToothWidth);
    path.lineTo(x - actualToothWidth / 2, size.height);
    path.lineTo(x - actualToothWidth, size.height - toothHeight);
  }

  // Left Side
  path.lineTo(0, toothHeight);

  path.close();
  return path;
}

class ZigZagShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path = getZigZagPath(size);

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.grey.shade300
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ZigZagClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => getZigZagPath(size);

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class DashedDivider extends StatelessWidget {
  final double height;
  final Color color;
  final double dashWidth;

  const DashedDivider({
    super.key,
    this.height = 1,
    this.color = Colors.black,
    this.dashWidth = 5.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: height,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}
