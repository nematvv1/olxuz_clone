import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/ads_model.dart';
import '../models/app_colors.dart';

class PreviewPage extends StatelessWidget {
  final AdsModel ad;
  final Uint8List? previewImageBytes;

  const PreviewPage({
    Key? key,
    required this.ad,
    this.previewImageBytes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.c4,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back_ios, color: AppColors.c2, size: 20),
        ),
        centerTitle: true,
        title: const Text(
          "Sizning e'loningiz",
          style: TextStyle(
            fontSize: 20,
            color: AppColors.c2,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildItem(ad),
      ),
    );
  }

  Widget _buildItem(AdsModel ad) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
              image: DecorationImage(
                image: ad.imageUrl != null && ad.imageUrl!.isNotEmpty
                    ? NetworkImage(ad.imageUrl!)
                    : previewImageBytes != null
                    ? MemoryImage(previewImageBytes!)
                    : const AssetImage('assets/images/img.png') as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ad.name ?? "",
                        style: const TextStyle(
                          color: AppColors.c2,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${ad.price ?? ""} so'm",
                        style: const TextStyle(
                          color: AppColors.c2,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ad.location ?? "",
                        style: const TextStyle(
                          color: AppColors.c2,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatDateSimple(ad.createdAt),
                        style: const TextStyle(
                          color: AppColors.c2,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String formatDateSimple(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return "";
    try {
      final dateTime = DateTime.parse(isoDate);
      return DateFormat('d MMM, HH:mm').format(dateTime);
    } catch (_) {
      return "";
    }
  }
}
