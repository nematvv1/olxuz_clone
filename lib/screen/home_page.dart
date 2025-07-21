import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../FavoriteProvider.dart';
import '../add_banner.dart';
import '../bannerWidget.dart';
import '../services/favorite_service.dart';
import '../models/ads_model.dart';
import '../models/app_colors.dart';
import 'favorites_page.dart';
import 'profil_page.dart';
import 'detail_page.dart';
import 'add_detial_page.dart';
import 'category_detail_page.dart';
import 'my_elon.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<AdsModel> ads = [];
  bool isLoading = false;
  String searchText = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> categories = [
    {"key": "category_electronics", "icon": Icons.devices_other},
    {"key": "category_cars", "icon": Icons.directions_car},
    {"key": "category_home", "icon": Icons.home},
    {"key": "category_jobs", "icon": Icons.work},
    {"key": "category_services", "icon": Icons.build},
    {"key": "category_animals", "icon": Icons.pets},
    {"key": "category_sports", "icon": Icons.sports_soccer},
    {"key": "category_fashion", "icon": Icons.checkroom},
  ];

  @override
  void initState() {
    super.initState();
    loadAds();
    loadFavorites();
  }

  Future<void> loadAds() async {
    setState(() => isLoading = true);
    final snapshot = await FirebaseFirestore.instance.collection('ads').get();
    ads = snapshot.docs.map((doc) {
      final ad = AdsModel.fromJson(doc.data());
      ad.id = doc.id;
      return ad;
    }).toList();
    ads.shuffle();
    setState(() => isLoading = false);
  }

  void loadFavorites() {
    final favProvider = Provider.of<FavoriteProvider>(context, listen: false);
    FirebaseFirestore.instance
        .collection('favorites')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('likedAds')
        .snapshots()
        .listen((snapshot) {
      final ids = snapshot.docs.map((doc) => doc.id).toList();
      favProvider.setFavorites(ids);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isAdmin = user != null && user.email == 'nematvv1@gmail.com';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredAds = ads.where((ad) {
      final name = ad.name?.toLowerCase() ?? '';
      return name.contains(searchText.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppColors.c4,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20, left: 20, top: 45),
            child: _buildTopBar(isDark),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: RefreshIndicator(
              onRefresh: loadAds,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Text("categories".tr(),
                        style: TextStyle(
                            color: isDark ? Colors.white : AppColors.c2,
                            fontSize: 17)),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      physics: const NeverScrollableScrollPhysics(),
                      children: categories
                          .map((cat) => _categoryItem(
                          cat['key'], cat['icon'], isDark))
                          .toList(),
                    ),
                    const SizedBox(height: 20),

                    /// ✅ Admin tugmasi
                    if (isAdmin) ...[
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                  const AddBannerPage()),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text("Reklama qo‘shish"),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    /// Reklama Banner
                    const BannerWidget(),

                    const SizedBox(height: 20),
                    Text("ads".tr(),
                        style: TextStyle(
                            color: isDark ? Colors.white : AppColors.c2,
                            fontSize: 17)),
                    const SizedBox(height: 12),
                    if (filteredAds.isEmpty)
                      Center(
                        child: Text("no_results".tr(),
                            style: TextStyle(
                                color: isDark
                                    ? Colors.white54
                                    : Colors.black54)),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.70,
                        ),
                        itemCount: filteredAds.length,
                        itemBuilder: (context, index) =>
                            _buildItem(filteredAds[index], isDark),
                      ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: isDark ? Colors.white : Colors.black,
        unselectedItemColor: isDark ? Colors.white : Colors.black,
        showUnselectedLabels: true,
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const FavoritesPage()))
                .then((_) => loadAds());
          }
          if (index == 2) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const DetailPage()))
                .then((_) => loadAds());
          }
          if (index == 3) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const MyAdsPage()))
                .then((_) => loadAds());
          }
          if (index == 4) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ProfilePage()))
                .then((_) => loadAds());
          }
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home,
                  color: isDark ? Colors.white : AppColors.c2),
              label: "ads".tr()),
          BottomNavigationBarItem(
              icon: const Icon(Icons.favorite_border),
              label: "nav_favorites".tr()),
          BottomNavigationBarItem(
              icon: const Icon(Icons.add_circle_outline),
              label: "nav_create".tr()),
          BottomNavigationBarItem(
              icon: const Icon(Icons.chat_bubble_outline),
              label: "nav_chat".tr()),
          BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              label: "nav_profile".tr()),
        ],
      ),
    );
  }

  Widget _categoryItem(String key, IconData icon, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryDetailPage(
              category: key.tr(),
              categoryKey: key,
            ),
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon,
                color: isDark ? Colors.white : AppColors.c2, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            key.tr(),
            style: TextStyle(
              fontSize: 12
              ,
              color: isDark ? Colors.white : AppColors.c2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }


  Widget _buildTopBar(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                searchText = value.toLowerCase();
              });
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              hintText: "search_hint".tr(),
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: isDark ? Colors.grey[850] : Colors.white,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black),
          ),
        ),
        const SizedBox(width: 16),
        Icon(Icons.notifications_active,color: isDark ? Colors.white : Colors.black),
      ],
    );
  }

  Widget _buildItem(AdsModel ad, bool isDark) {
    final favProvider = context.watch<FavoriteProvider>();
    final isFav = favProvider.isFavorite(ad.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AdDetailPage(ad: ad)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(5),
                    ),
                    image: ad.imageUrl != null && ad.imageUrl!.isNotEmpty
                        ? DecorationImage(
                      image: NetworkImage(ad.imageUrl!),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: ad.imageUrl == null || ad.imageUrl!.isEmpty
                      ? const Center(child: Icon(Icons.image_not_supported))
                      : null,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () async {
                      if (isFav) {
                        await FavoriteService.removeFavorite(ad.id);
                        favProvider.removeFavorite(ad.id);
                      } else {
                        await FavoriteService.addFavorite(ad.id, ad.toJson());
                        favProvider.addFavorite(ad.id);
                      }
                    },
                    child: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.red : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ad.name ?? '',
                        style: TextStyle(
                            color: isDark ? Colors.white : AppColors.c2,
                            fontSize: 13),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text("${ad.price ?? ''} so'm",
                        style: TextStyle(
                            color: isDark ? Colors.white : AppColors.c2,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    if (ad.description != null && ad.description!.isNotEmpty)
                      Text(ad.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 11,
                              color:
                              isDark ? Colors.white60 : Colors.black54)),
                    const Spacer(),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            ad.location ?? '',
                            style: TextStyle(
                              color: isDark ? Colors.white60 : AppColors.c2,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _formatDate(ad.createdAt),
                          style: TextStyle(
                            color: isDark ? Colors.white60 : AppColors.c2,
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
      ),
    );
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return "";
    try {
      final dateTime = DateTime.parse(isoDate);
      return DateFormat('d MMM, HH:mm').format(dateTime);
    } catch (_) {
      return "";
    }
  }
}
