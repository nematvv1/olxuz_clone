import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_services.dart';
import 'home_page.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({Key? key}) : super(key: key);

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final TextEditingController _signInEmaileController = TextEditingController();
  final TextEditingController _signInPasswordController = TextEditingController();
  bool isPasswordObscure = true;
  bool isLoading = false;

  void togglePasswordVisibility() {
    setState(() {
      isPasswordObscure = !isPasswordObscure;
    });
  }

  void showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> handleLogin() async {
    String email = _signInEmaileController.text.trim();
    String password = _signInPasswordController.text.trim();
    final AuthService _authService = AuthService();

    if (email.isNotEmpty && password.isNotEmpty) {
      setState(() {
        isLoading = true;
      });

      try {
        User? user = await _authService.loginUser(email, password);
        if (user != null) {
          showSnack("Xush kelibsiz, ${user.email}!");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomePage()),
          );
        } else {
          showSnack("Login xato. Ma’lumotlarni tekshiring.");
        }
      } catch (e) {
        showSnack("Xatolik yuz berdi: $e");
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      showSnack("Iltimos, barcha maydonlarni to‘ldiring.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Электронная почта или телефон"),
        Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(width: 2, color: Colors.black),
          ),
          child: TextField(
            controller: _signInEmaileController,
            decoration: InputDecoration(border: InputBorder.none),
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
        ),
        SizedBox(height: 10),
        Text("Пароль"),
        Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(width: 2, color: Colors.black),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _signInPasswordController,
                  obscureText: isPasswordObscure,
                  decoration: InputDecoration(border: InputBorder.none),
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),
              IconButton(
                icon: Icon(
                  isPasswordObscure ? Icons.visibility : Icons.visibility_off,
                  color: Colors.black,
                ),
                onPressed: togglePasswordVisibility,
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        TextButton(
          onPressed: () {},
          child: Text(
            "Забыли пароль?",
            style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 10),
        isLoading
            ? Center(child: CircularProgressIndicator())
            : ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          onPressed: handleLogin,
          child: Center(
            child: Text(
              "Войти",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
