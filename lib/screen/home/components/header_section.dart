import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class HeaderSection extends SliverPersistentHeaderDelegate {
  final TextEditingController searchController;
  final String searchQuery;
  final Function(String) onSearchChanged;
  final VoidCallback onClearSearch;

  HeaderSection({
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onClearSearch,
  });

  @override
  double get minExtent => 90.0;

  @override
  double get maxExtent => 90.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(
      height: maxExtent,
      child: Container(
        color: Colors.white,
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
                controller: searchController,
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: '   Search Anything Here',
                  hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 16,
                      fontWeight: FontWeight.normal),
                  suffixIcon: searchQuery.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Icon(Iconsax.search_normal),
                        )
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: onClearSearch,
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
                      color: Colors.deepOrange.shade400,
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
    );
  }

  @override
  bool shouldRebuild(HeaderSection oldDelegate) =>
      searchQuery != oldDelegate.searchQuery;
}
