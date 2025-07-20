import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_services.dart';
import 'home_page.dart';

class RegisterWidget extends StatefulWidget {
  @override
  State<RegisterWidget> createState() => _RegisterWidgetState();
}

class _RegisterWidgetState extends State<RegisterWidget> {
  final TextEditingController _signUpEmailController = TextEditingController();
  final TextEditingController _signUpPasswordController = TextEditingController();
  bool isPasswordObscure = true;
  bool isChecked = false;
  bool isLoading = false;

  @override
  void dispose() {
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();
    super.dispose();
  }

  bool isPasswordValid(String password) {
    final lengthReg = RegExp(r'.{9,}');
    final upperReg = RegExp(r'[A-Z]');
    final lowerReg = RegExp(r'[a-z]');
    final digitReg = RegExp(r'\d');
    final specialReg = RegExp(r'[!@#\$%^&*(),.?":{}|<>]');

    return lengthReg.hasMatch(password) &&
        upperReg.hasMatch(password) &&
        lowerReg.hasMatch(password) &&
        digitReg.hasMatch(password) &&
        specialReg.hasMatch(password);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Электронная почта или телефон"),
        Container(
          margin: const EdgeInsets.only(top: 8, bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(width: 2, color: Colors.black),
          ),
          child: TextField(
            controller: _signUpEmailController,
            decoration: const InputDecoration(border: InputBorder.none),
            style: const TextStyle(color: Colors.black, fontSize: 20),
          ),
        ),
        Text("Пароль"),
        Container(
          margin: const EdgeInsets.only(top: 8, bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(width: 2, color: Colors.black),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _signUpPasswordController,
                  obscureText: isPasswordObscure,
                  decoration: const InputDecoration(border: InputBorder.none),
                  style: const TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),
              IconButton(
                icon: Icon(
                  isPasswordObscure ? Icons.visibility : Icons.visibility_off,
                  color: Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    isPasswordObscure = !isPasswordObscure;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text("Пароль должен содержать:"),
        const SizedBox(height: 6),
        bulletText("не менее 9 символов;"),
        bulletText("прописную букву;"),
        bulletText("строчную букву;"),
        bulletText("цифру;"),
        bulletText("специальный символ (!@#\$...)."),
        const SizedBox(height: 16),
        RichText(
          text: TextSpan(
            text: "Я соглашаюсь с ",
            style: const TextStyle(color: Colors.black),
            children: [
              TextSpan(
                text: "Условия использования",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()..onTap = () {
                  // TODO: link ochish
                },
              ),
              const TextSpan(
                text:
                ", а также с передачей и обработкой моих данных в OLX. Я подтверждаю свое совершеннолетие и ответственность за размещение объявления.",
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: Icon(
                isChecked ? Icons.check_box : Icons.check_box_outline_blank,
                color: Colors.black,
              ),
              onPressed: () {
                setState(() {
                  isChecked = !isChecked;
                });
              },
            ),
            const Expanded(
              child: Text(
                "Да, я хочу получать информацию о новостях и акциях на OLX.",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          onPressed: isLoading ? null : () async {
            String email = _signUpEmailController.text.trim();
            String password = _signUpPasswordController.text.trim();
            final AuthService _authService = AuthService();

            if (email.isEmpty || password.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Iltimos, barcha maydonlarni to‘ldiring.")),
              );
              return;
            }

            if (!isPasswordValid(password)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Parol 9 ta belgidan iborat bo‘lishi, katta va kichik harf, raqam va belgi bo‘lishi kerak."),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            setState(() => isLoading = true);

            User? user = await _authService.signUp(email, password);

            setState(() => isLoading = false);

            if (user != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Ro‘yxatdan o‘tishda xatolik!")),
              );
            }
          },
          child: Center(
            child: isLoading
                ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text(
              "Зарегистрироваться",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget bulletText(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("• "),
        Expanded(child: Text(text)),
      ],
    );
  }
}
