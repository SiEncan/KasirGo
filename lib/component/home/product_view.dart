import 'package:flutter/material.dart';
class ProductView extends StatelessWidget {
  final List<Map<String, dynamic>> products = [
    {
      "name": "Nasi Goreng",
      "desc": "Nasi goreng spesial pedas",
      "price": 25000,
      "img": "https://images.pexels.com/photos/1639563/pexels-photo-1639563.jpeg?auto=compress&cs=tinysrgb&w=600"
    },
    {
      "name": "Ayam Bakar",
      "desc": "Ayam bakar madu",
      "price": 30000,
      "img": "https://images.pexels.com/photos/410648/pexels-photo-410648.jpeg?auto=compress&cs=tinysrgb&w=600"
    },
    {
      "name": "Sate Ayam",
      "desc": "Sate ayam bumbu kacang",
      "price": 20000,
      "img": "https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg?auto=compress&cs=tinysrgb&w=600"
    },
    {
      "name": "Bakso",
      "desc": "Bakso urat komplit",
      "price": 18000,
      "img": "https://images.pexels.com/photos/247466/pexels-photo-247466.jpeg?auto=compress&cs=tinysrgb&w=600"
    },
    {
      "name": "Nasi Goreng",
      "desc": "Nasi goreng spesial pedas",
      "price": 25000,
      "img": "https://images.pexels.com/photos/1639563/pexels-photo-1639563.jpeg?auto=compress&cs=tinysrgb&w=600"
    },
    {
      "name": "Ayam Bakar",
      "desc": "Ayam bakar madu",
      "price": 30000,
      "img": "https://images.pexels.com/photos/410648/pexels-photo-410648.jpeg?auto=compress&cs=tinysrgb&w=600"
    },
    {
      "name": "Sate Ayam",
      "desc": "Sate ayam bumbu kacang",
      "price": 20000,
      "img": "https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg?auto=compress&cs=tinysrgb&w=600"
    },
    {
      "name": "Bakso",
      "desc": "Bakso urat komplit",
      "price": 18000,
      "img": "https://images.pexels.com/photos/247466/pexels-photo-247466.jpeg?auto=compress&cs=tinysrgb&w=600"
    },
    {
      "name": "Nasi Goreng",
      "desc": "Nasi goreng spesial pedas",
      "price": 25000,
      "img": "https://images.pexels.com/photos/1639563/pexels-photo-1639563.jpeg?auto=compress&cs=tinysrgb&w=600"
    },
    {
      "name": "Ayam Bakar",
      "desc": "Ayam bakar madu",
      "price": 30000,
      "img": "https://images.pexels.com/photos/410648/pexels-photo-410648.jpeg?auto=compress&cs=tinysrgb&w=600"
    },
    {
      "name": "Sate Ayam",
      "desc": "Sate ayam bumbu kacang",
      "price": 20000,
      "img": "https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg?auto=compress&cs=tinysrgb&w=600"
    },
    {
      "name": "Bakso",
      "desc": "Bakso urat komplit",
      "price": 18000,
      "img": "https://images.pexels.com/photos/247466/pexels-photo-247466.jpeg?auto=compress&cs=tinysrgb&w=600"
    },
  ];

  ProductView({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.9,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final p = products[index];

        return InkWell(
          onTap: () {
            // TODO: tambahkan ke cart
            print("ADD PRODUCT: ${p['name']}");
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    p['img'],
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  p['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                Text(
                  p['desc'],
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const Spacer(),

                Text(
                  "Rp ${p['price']}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange.shade800,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}