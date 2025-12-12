import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kasir_go/component/home/order_detail.dart';
import 'package:kasir_go/component/home/product_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 24, right: 24),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Kasir',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepOrange.shade400,
                                  ),
                                ),
                                const TextSpan(
                                  text: 'Go',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: '   Search Anything Here',
                              hintStyle: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal),
                              suffixIcon: const Padding(
                                padding: EdgeInsets.only(right: 12),
                                child: Icon(Iconsax.search_normal),
                              ),
                              suffixIconColor: Colors.grey,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(32),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(32),
                                borderSide: BorderSide(
                                  color:
                                      Colors.grey.shade500, // warna saat fokus
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.deepOrange.shade300,
                              borderRadius: BorderRadius.circular(132),
                            ),
                            child: const Icon(
                              Iconsax.notification5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                        child: Text('Menu',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey.shade900)),
                      ),
                      const Text('(30 items)',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            Container(
                              width: 200,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.orange.shade800,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Center(
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 12),
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Colors.deepOrange.shade500,
                                        borderRadius: BorderRadius.circular(36),
                                      ),
                                      child: const Icon(
                                        Iconsax.category,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 12.0),
                                        child: Text('All Menu',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.orange.shade900)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 12.0, top: 4.0),
                                        child: Text('(30 items)',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.orange.shade800)),
                                      ),
                                    ],
                                  )
                                ],
                                
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 200,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Center(
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 12),
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(36),
                                      ),
                                      child:  Icon(
                                        Icons.restaurant,
                                        color: Colors.grey.shade400,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 12.0),
                                        child: Text('Main Course',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey.shade500)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 12.0, top: 4.0),
                                        child: Text('(7 items)',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.grey.shade500)),
                                      ),
                                    ],
                                  )
                                ],
                                
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 200,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Center(
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 12),
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(36),
                                      ),
                                      child:  Icon(
                                        Icons.local_drink,
                                        color: Colors.grey.shade400,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 12.0),
                                        child: Text('Beverages',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey.shade500)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 12.0, top: 4.0),
                                        child: Text('(10 items)',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.grey.shade500)),
                                      ),
                                    ],
                                  )
                                ],
                                
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 200,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Center(
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 12),
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(36),
                                      ),
                                      child:  Icon(
                                        Icons.restaurant,
                                        color: Colors.grey.shade400,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 12.0),
                                        child: Text('Desserts',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey.shade500)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 12.0, top: 4.0),
                                        child: Text('(5 items)',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.grey.shade500)),
                                      ),
                                    ],
                                  )
                                ],
                                
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                        ),
                      ),
                  ),
                  Expanded(
                    child: ProductView(),
                  ),
                ],
              ),
            ),
            VerticalDivider(
              color: Colors.grey.shade300,
              thickness: 1,
            ),
            const OrderDetails()
          ],
        ),
      ),
    );
  }
}