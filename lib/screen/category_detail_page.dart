import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';

import '../models/ads_model.dart';
import 'add_detial_page.dart';

class CategoryDetailPage extends StatefulWidget {
  final String categoryKey;
  final String category;

  const CategoryDetailPage({
    super.key,
    required this.categoryKey,
    required this.category,
  });

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  Stream<QuerySnapshot> loadAdsByCategory() {
    return FirebaseFirestore.instance
        .collection('ads')
        .where('type', isEqualTo: widget.categoryKey)
        .snapshots();
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return "";
    try {
      final dateTime = DateTime.parse(isoDate);
      return DateFormat('dd MMM, HH:mm').format(dateTime);
    } catch (_) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(widget.category)),
      body: StreamBuilder<QuerySnapshot>(
        stream: loadAdsByCategory(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(child: Text("no_ads".tr()));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: docs.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.70,
            ),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final adId = docs[index].id;
              final ad = AdsModel.fromJson(data)..id = adId;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AdDetailPage(ad: ad)),
                  );
                },
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(0.3)
                                : Colors.grey.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                            child: Image.network(
                              ad.imageUrl ?? '',
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 120,
                                color: Colors.grey,
                                child: const Center(child: Icon(Icons.image_not_supported)),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ad.name ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  ad.price != null ? "${ad.price} so'm" : '',
                                  style: const TextStyle(color: Colors.green),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  ad.description ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  ad.location ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white60 : Colors.black54,
                                  ),
                                ),
                                Text(
                                  _formatDate(ad.createdAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white38 : Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
