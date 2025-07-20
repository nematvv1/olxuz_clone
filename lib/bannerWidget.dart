import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BannerWidget extends StatelessWidget {
  const BannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
          child: Text(
            "Reklama",
            style: TextStyle(fontSize: 16, ),
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('banners').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(
                height: 130,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final banners = snapshot.data!.docs;

            if (banners.isEmpty) {
              return const SizedBox();
            }

            return SizedBox(
              height: 130,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: banners.length,
                itemBuilder: (context, index) {
                  final data = banners[index].data() as Map<String, dynamic>;
                  final imageUrl = data['imageUrl'] as String? ?? '';
                  final link = data['link'] as String? ?? '';

                  return GestureDetector(
                    onTap: () async {
                      if (await canLaunchUrl(Uri.parse(link))) {
                        await launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: 300,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: progress.expectedTotalBytes != null
                                    ? progress.cumulativeBytesLoaded /
                                    (progress.expectedTotalBytes ?? 1)
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Center(
                                child: Icon(Icons.broken_image,
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.black54),
                              ),
                        )
                            : Center(
                          child: Icon(Icons.image_not_supported,
                              color: isDark
                                  ? Colors.white60
                                  : Colors.black54),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
