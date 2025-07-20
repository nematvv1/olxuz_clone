import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';

import '../models/ads_model.dart';
import '../services/favorite_service.dart';

class AdDetailPage extends StatefulWidget {
  final AdsModel ad;

  const AdDetailPage({super.key, required this.ad});

  @override
  State<AdDetailPage> createState() => _AdDetailPageState();
}

class _AdDetailPageState extends State<AdDetailPage> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    checkFavorite();
  }

  void checkFavorite() async {
    bool fav = await FavoriteService.isFavorite(widget.ad.id);
    setState(() {
      isFavorite = fav;
    });
  }

  void toggleFavorite() async {
    if (isFavorite) {
      await FavoriteService.removeFavorite(widget.ad.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("removed".tr())),
      );
    } else {
      await FavoriteService.addFavorite(widget.ad.id, widget.ad.toJson());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("saved".tr())),
      );
    }
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = widget.ad.createdAt != null
        ? DateFormat('yyyy-MM-dd HH:mm')
        .format(DateTime.parse(widget.ad.createdAt!))
        : 'no_date'.tr();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.ad.imageUrl != null && widget.ad.imageUrl!.isNotEmpty
                ? Image.network(
              widget.ad.imageUrl!,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            )
                : Container(
              width: double.infinity,
              height: 250,
              color: Colors.grey[300],
              child: const Icon(Icons.image_not_supported, size: 80),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.ad.name ?? '',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "price".tr() + ": ${widget.ad.price ?? 'unknown'.tr()}",
                    style: TextStyle(fontSize: 18, color: Colors.green[700]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 20, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.ad.location ?? 'no_location'.tr(),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        formattedDate,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "description".tr(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.ad.description ?? "no_description".tr(),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text("contact".tr()),
                      content: Text(
                          "phone".tr() + ": ${widget.ad.userNumber ?? 'unknown'.tr()}"),
                      actions: [
                        TextButton(
                          child: Text("close".tr()),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.phone, color: Colors.black),
                label: Text("contact".tr(), style: const TextStyle(color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: toggleFavorite,
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.grey,
                ),
                label: Text("save".tr(),
                    style: const TextStyle(color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
