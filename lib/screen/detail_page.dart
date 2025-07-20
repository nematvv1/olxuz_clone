import 'dart:io' as io;
import 'package:universal_io/io.dart' as io;
import 'package:flutter/foundation.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui';
import 'package:flutter/painting.dart';
import 'package:olx_uz/screen/prewiev_page.dart';
import '../models/ads_model.dart';
import '../models/app_colors.dart';

import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({Key? key}) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final titleController = TextEditingController();
  final imgUrlController = TextEditingController();
  final categoryController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final contactNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController(text: "+998");
  String? selectedCategory;
  String? selectedRegion;
  final List<String> categories = [
    "category_cars",
    "category_electronics",
    "category_home",
    "category_jobs",
    "category_services",
    "category_animals",
    "category_sports",
    "category_fashion",
  ];

  final List<String> regions = [
    "Andijon",
    "Buxoro",
    "Jizzax",
    "Qashqadaryo",
    "Navoi",
    "Namangan",
    "Samarqand",
    "Sirdaryo",
    "Surxandaryo",
    "Toshkent",
    "Farg'ona",
    "Xorazm",
  ];
  bool isLoading = false;

  bool validateFields() {
    final title = titleController.text.trim();
    final desc = descriptionController.text.trim();
    final imgUrl = imgUrlController.text.trim();
    final price = priceController.text.trim();
    final contactName = contactNameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();

    if (imgUrl.isEmpty ||
        title.isEmpty ||
        selectedCategory == null ||
        desc.isEmpty ||
        price.isEmpty ||
        selectedRegion == null ||
        contactName.isEmpty ||
        email.isEmpty ||
        phone.isEmpty) {
      showCustomSnackbar(
        context,
        "error_fill_fields".tr(),
        isError: true,
      );
      return false;
    }

    if (title.length < 10) {
      showCustomSnackbar(
        context,
        "error_title_short".tr(),
        isError: true,
      );
      return false;
    }

    if (desc.length < 30) {
      showCustomSnackbar(
        context,
        "error_desc_short".tr(),
        isError: true,
      );
      return false;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      showCustomSnackbar(
        context,
        "error_email".tr(),
        isError: true,
      );
      return false;
    }

    final phoneRegex = RegExp(r'^\+998\d{9}$');
    if (!phoneRegex.hasMatch(phone)) {
      showCustomSnackbar(
        context,
        "error_phone".tr(),
        isError: true,
      );
      return false;
    }

    return true;
  }

  void add() async {
    if (!validateFields()) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      showCustomSnackbar(context, "User not logged in", isError: true);
      return;
    }

    setState(() {
      isLoading = true;
    });

    String? imageUrl;

    if (_selectedImage != null || _webImageBytes != null) {
      imageUrl = await StorageService.uploadImageToStorage(
        currentUser.uid,
        _selectedImage,
        _webImageBytes,
      );
    }

    if ((imageUrl == null || imageUrl.isEmpty) &&
        imgUrlController.text.trim().isNotEmpty) {
      imageUrl = imgUrlController.text.trim();
    }

    AdsModel ad = AdsModel(
      uid: currentUser.uid,
      imageUrl: imageUrl ?? "",
      name: titleController.text.trim(),
      type: selectedCategory!,
      description: descriptionController.text.trim(),
      price: priceController.text.trim(),
      location: selectedRegion!,
      userName: contactNameController.text.trim(),
      userEmail: emailController.text.trim(),
      userNumber: phoneController.text.trim(),
      createdAt: DateTime.now().toIso8601String(),
    );

    try {
      await FirestoreService.addAd(ad);
      if (mounted) {
        showCustomSnackbar(context, "success_posted".tr(), isError: false);
        Navigator.pop(context);
      }
    } catch (e) {
      showCustomSnackbar(context, "error_not_posted".tr(), isError: true);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void showCustomSnackbar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    final color = isError ? Colors.red.shade600 : Colors.green.shade600;
    final icon = isError ? Icons.error_outline : Icons.check_circle_outline;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          height: 50,
          width: double.infinity,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  InputDecoration customDecoration(String hint, {bool isDark = false}) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      filled: true,
      fillColor: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF1F1F1),
      hintText: hint,
      hintStyle: TextStyle(
        color: isDark ? Colors.white60 : Colors.black54,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide.none,
      ),
    );
  }


  io.File? _selectedImage;
  Uint8List? _webImageBytes;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text('gallery'.tr()),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile =
                    await _picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  if (kIsWeb) {
                    final bytes = await pickedFile.readAsBytes();
                    setState(() {
                      _webImageBytes = bytes;
                      _selectedImage = null;
                    });
                  } else {
                    setState(() {
                      _selectedImage = io.File(pickedFile.path);
                      _webImageBytes = null;
                    });
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text('camera'.tr()),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile =
                    await _picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  if (kIsWeb) {
                    final bytes = await pickedFile.readAsBytes();
                    setState(() {
                      _webImageBytes = bytes;
                      _selectedImage = null;
                    });
                  } else {
                    setState(() {
                      _selectedImage = io.File(pickedFile.path);
                      _webImageBytes = null;
                    });
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const labelStyle = TextStyle(fontSize: 14, color: AppColors.c2);
    return Scaffold(
      appBar:AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: isDark ? Colors.white : Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        elevation: 0,
      ),



      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            scrolledUnderElevation: 0,
            backgroundColor: isDark ? Colors.grey[900] : Colors.white,
            pinned: true,
            expandedHeight: 100,
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "post_ad".tr(),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "image".tr(),
                    style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black),
                  ),
                  SizedBox(height: 6),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 170,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[700] : AppColors.c3,
                        borderRadius: BorderRadius.circular(5),
                        image: _selectedImage != null
                            ? DecorationImage(
                                image: FileImage(_selectedImage!),
                                fit: BoxFit.cover,
                              )
                            : (_webImageBytes != null
                                ? DecorationImage(
                                    image: MemoryImage(_webImageBytes!),
                                    fit: BoxFit.cover,
                                  )
                                : null),
                      ),
                      child: _selectedImage == null && _webImageBytes == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.photo_library,
                                    size: 40, color: Colors.grey),
                                const SizedBox(height: 15),
                                Column(
                                  children: [
                                    Text(
                                      "attach_photo".tr(),
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white60
                                            : AppColors.c2,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Builder(
                                      builder: (context) {
                                        final text = "attach_photo".tr();
                                        final textStyle = const TextStyle(
                                            color: AppColors.c2);
                                        final textPainter = TextPainter(
                                          text: TextSpan(
                                              text: text, style: textStyle),
                                          maxLines: 1,
                                          textDirection:
                                              Directionality.of(context),
                                        )..layout();
                                        return Container(
                                          width: textPainter.size.width + 7,
                                          height: 2,
                                          color: isDark
                                              ? Colors.white54
                                              : Colors.black,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Stack(
                              children: [
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: kIsWeb
                                        ? Image.memory(_webImageBytes!,
                                            fit: BoxFit.cover)
                                        : Image.file(_selectedImage!,
                                            fit: BoxFit.cover),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedImage = null;
                                        _webImageBytes = null;
                                      });
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(Icons.close,
                                          color: Colors.red, size: 20),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text("image_url".tr(),
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black)),
                  SizedBox(height: 6),
                  TextField(
                    controller: imgUrlController,
                    maxLength: 70,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: customDecoration("https:", isDark: isDark),
                  ),

                  SizedBox(height: 12),
                  Text("title".tr(),
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black)),
                  SizedBox(height: 6),
                  TextField(
                    controller: titleController,
                    maxLength: 70,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: customDecoration("example_title".tr(), isDark: isDark),
                  ),

                  SizedBox(height: 12),
                  // CATEGORY
                  Text(
                    "category".tr(),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () async {
                      final selected = await showModalBottomSheet<String>(
                        context: context,
                        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (context) {
                          return ListView(
                            shrinkWrap: true,
                            children: categories.map((category) {
                              return ListTile(
                                title: Text(
                                  category.tr(),
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                                onTap: () => Navigator.pop(context, category),
                              );
                            }).toList(),
                          );
                        },
                      );
                      if (selected != null) {
                        setState(() {
                          selectedCategory = selected;
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        style: TextStyle(
                          color: selectedCategory == null
                              ? Colors.grey
                              : (isDark ? Colors.white : Colors.black),
                        ),
                        decoration: customDecoration("select".tr(), isDark: isDark).copyWith(
                          hintText: selectedCategory == null
                              ? "select".tr()
                              : selectedCategory!.tr(),
                          hintStyle: TextStyle(
                            color: selectedCategory == null
                                ? Colors.grey
                                : (isDark ? Colors.white : Colors.black),
                          ),
                          suffixIcon: Icon(
                            Icons.arrow_drop_down,
                            color: selectedCategory == null
                                ? Colors.grey
                                : (isDark ? Colors.white : Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ),

// DESCRIPTION
                  const SizedBox(height: 12),
                  Text(
                    "description".tr(),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: descriptionController,
                    maxLines: 4,
                    maxLength: 500,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: customDecoration("example_description".tr(), isDark: isDark),
                  ),

// PRICE
                  const SizedBox(height: 12),
                  Text(
                    "price".tr(),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    keyboardType: TextInputType.number,
                    controller: priceController,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: customDecoration("500 000", isDark: isDark),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Expanded(child: SizedBox()),
                      Text(
                        "uzs".tr(),
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black87,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 13),
                    ],
                  ),

// LOCATION
                  const SizedBox(height: 12),
                  Text(
                    "location".tr(),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () async {
                      final selected = await showModalBottomSheet<String>(
                        context: context,
                        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        builder: (context) {
                          return ListView(
                            shrinkWrap: true,
                            children: regions.map((region) {
                              return ListTile(
                                title: Text(
                                  region,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                                onTap: () => Navigator.pop(context, region),
                              );
                            }).toList(),
                          );
                        },
                      );
                      if (selected != null) {
                        setState(() {
                          selectedRegion = selected;
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        style: TextStyle(
                          color: selectedRegion == null
                              ? Colors.grey
                              : (isDark ? Colors.white : Colors.black),
                        ),
                        decoration: customDecoration("select".tr(), isDark: isDark).copyWith(
                          hintText: selectedRegion ?? "select".tr(),
                          hintStyle: TextStyle(
                            color: selectedRegion == null
                                ? Colors.grey
                                : (isDark ? Colors.white : Colors.black),
                          ),
                          suffixIcon: Icon(
                            Icons.arrow_drop_down,
                            color: selectedRegion == null
                                ? Colors.grey
                                : (isDark ? Colors.white : Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 12),
                  Text("contact_person".tr(),
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black)),
                  SizedBox(height: 6),
                  TextField(
                    controller: contactNameController,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: customDecoration("name".tr(), isDark: isDark),
                  ),

                  SizedBox(height: 12),
                  Text("E-mail",
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black)),
                  SizedBox(height: 6),
                  TextField(
                    controller: emailController,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: customDecoration("example_email".tr(), isDark: isDark),
                  ),

                  SizedBox(height: 12),
                  Text("phone".tr(),
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black)),
                  SizedBox(height: 6),
                  TextField(
                    controller: phoneController,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    maxLength: 13,
                    keyboardType: TextInputType.phone,
                    decoration: customDecoration("+998", isDark: isDark),
                  ),

                  SizedBox(height: 50),
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        if (!validateFields()) return;
                        final previewAd = AdsModel(
                          imageUrl: imgUrlController.text.trim(),
                          name: titleController.text.trim(),
                          type: selectedCategory ?? '',
                          description: descriptionController.text.trim(),
                          price: priceController.text.trim(),
                          location: selectedRegion ?? '',
                          userName: contactNameController.text.trim(),
                          userEmail: emailController.text.trim(),
                          userNumber: phoneController.text.trim(),
                          createdAt: DateTime.now().toIso8601String(),
                        );

                        Uint8List? previewImageBytes;
                        if (_webImageBytes != null) {
                          previewImageBytes = _webImageBytes;
                        } else if (_selectedImage != null) {
                          previewImageBytes =
                              await _selectedImage!.readAsBytes();
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PreviewPage(
                              ad: previewAd,
                              previewImageBytes: previewImageBytes,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "preview".tr(),
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 3),
                          Builder(
                            builder: (context) {
                              final text = "preview".tr();
                              final textStyle = TextStyle(
                                color:isDark ? Colors.white : AppColors.c2,
                                fontSize: 16,
                              );
                              final textPainter = TextPainter(
                                text: TextSpan(text: text, style: textStyle),
                                maxLines: 1,
                                textDirection: Directionality.of(context),
                              )..layout();
                              return Container(
                                width: textPainter.size.width + 7,
                                height: 2,
                                color: AppColors.c2,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: add,
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white : Colors.black,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: isLoading
                            ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDark ? Colors.black : Colors.white,
                            ),
                            strokeWidth: 2,
                          ),
                        )
                            : Text(
                                "post".tr(),
                                style: TextStyle(
                                    color: isDark ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
