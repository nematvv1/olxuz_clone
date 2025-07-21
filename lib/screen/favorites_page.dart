// importlar o'zgartirilmagan
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import 'package:another_flushbar/flushbar.dart';

import '../services/favorite_service.dart';
import '../models/ads_model.dart';
import 'add_detial_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  void _showFlush(String message) {
    Flushbar(
      message: message,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.grey[900]!,
      flushbarPosition: FlushbarPosition.BOTTOM,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      borderRadius: BorderRadius.circular(12),
      icon: const Icon(Icons.favorite, color: Colors.redAccent),
      messageSize: 16,
      animationDuration: const Duration(milliseconds: 400),
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "my_liked".tr(),
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FavoriteService.getFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final ads = snapshot.data ?? [];

          if (ads.isEmpty) {
            return Center(
              child: Text("no_like".tr(), style: textTheme.bodyLarge),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: ads.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.65, // ⚠️ muhim: sig‘ishi uchun kichikroq qildik
            ),
            itemBuilder: (context, index) {
              final adMap = ads[index];
              if (adMap['id'] == null || adMap['id'].toString().isEmpty) {
                return const SizedBox();
              }

              final ad = AdsModel.fromJson(adMap);
              final adId = ad.id;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AdDetailPage(ad: ad)),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          ad.imageUrl ?? '',
                          height: 120, // ⚠️ kamaytirdik
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 120,
                            color: Colors.grey[800],
                            child: const Center(child: Icon(Icons.image_not_supported)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ad.name ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            if ((ad.description ?? '').isNotEmpty)
                              Text(
                                ad.description!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodySmall?.copyWith(
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: Colors.grey.shade700,
                              ),
                              child: Text(
                                "new_badge".tr(),
                                style: textTheme.labelSmall?.copyWith(color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "${ad.price} сум",
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.greenAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    ad.location ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.bodySmall?.copyWith(color: Colors.grey),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  ad.createdAt != null
                                      ? DateFormat('dd MMM, HH:mm')
                                      .format(DateTime.parse(ad.createdAt!))
                                      : '',
                                  style: textTheme.bodySmall?.copyWith(color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
