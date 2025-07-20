import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:olx_uz/screen/sign_up.dart';
import 'package:provider/provider.dart';

import '../models/app_colors.dart';
import '../services/auth_services.dart';
import '../services/thime_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  String _currentLanguage = 'en-US';

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadCurrentLanguage();
  }

  Future<void> _loadCurrentLanguage() async {
    final locale = context.locale;
    setState(() {
      _currentLanguage = '${locale.languageCode}-${locale.countryCode}';
    });
  }

  Future<void> _changeLanguage(String languageCode) async {
    final parts = languageCode.split('-');
    if (parts.length == 2) {
      await context.setLocale(Locale(parts[0], parts[1]));
      setState(() {
        _currentLanguage = languageCode;
      });
    }
  }

  Future<void> _confirmAndSignOut() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text("confirm_logout".tr()),
        content: Text("sure_logout".tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("cancel".tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("logout".tr(), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await _performSignOut();
    }
  }

  Future<void> _performSignOut() async {
    try {
      await _authService.signOut();
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SignUpPage()));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('logout_error'.tr(args: [e.toString()])),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final bgColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final cardColor = isDarkMode ? Colors.grey[850] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          "nav_profile".tr(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.c4,
              child: Icon(Icons.person, size: 50, color: isDarkMode ? Colors.grey[900] : Colors.blueGrey),
            ),
            const SizedBox(height: 16),
            Text(
              _authService.currentUser?.email ?? "guest".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: cardColor,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Icon(FontAwesome.language, color: Colors.blue),
                title: Text("language".tr(), style: TextStyle(color: textColor)),
                subtitle: Text(_getLanguageName(_currentLanguage),
                    style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54)),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: _showLanguageSelector,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: cardColor,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Icon(Icons.dark_mode, color: Colors.orange),
                title: Text("dark_mode".tr(), style: TextStyle(color: textColor)),
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme(value);
                  },
                ),
              ),
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: _confirmAndSignOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? Colors.red[800] : Colors.red[50],
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Colors.red),
                ),
              ),
              child: Text("account_logout".tr(), style: TextStyle(color: isDarkMode ? Colors.white : Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                "select_language".tr(),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _customLangTile('uz-UZ', '🇺🇿 Oʻzbekcha'),
            _customLangTile('ru-RU', '🇷🇺 Русский'),
            _customLangTile('en-US', '🇺🇸 English'),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _customLangTile(String code, String name) {
    final isSelected = _currentLanguage == code;
    return ListTile(
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isSelected ? Colors.red : Colors.grey,
      ),
      title: Text(name),
      onTap: () {
        Navigator.pop(context);
        _changeLanguage(code);
      },
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'uz-UZ':
        return '🇺🇿 Oʻzbekcha';
      case 'ru-RU':
        return '🇷🇺 Русский';
      case 'en-US':
      default:
        return '🇺🇸 English';
    }
  }
}
