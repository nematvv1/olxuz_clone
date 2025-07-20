import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddBannerPage extends StatefulWidget {
  const AddBannerPage({super.key});

  @override
  State<AddBannerPage> createState() => _AddBannerPageState();
}

class _AddBannerPageState extends State<AddBannerPage> {
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  bool isLoading = false;

  Future<void> addBanner() async {
    final image = _imageUrlController.text.trim();
    final link = _linkController.text.trim();
    if (image.isEmpty || link.isEmpty) return;

    setState(() => isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('banners').add({
        'image': image,
        'url': link,
        'createdAt': DateTime.now().toIso8601String(),
      });
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Xatolik: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reklama qo‘shish"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Reklama rasmi URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _linkController,
              decoration: const InputDecoration(
                labelText: 'Bosilganda ochiladigan link',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
              onPressed: addBanner,
              icon: const Icon(Icons.upload),
              label: const Text("Saqlash reklama"),
            ),
          ],
        ),
      ),
    );
  }
}
