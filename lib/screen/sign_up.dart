
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:olx_uz/screen/register_widgets.dart';


import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool isLoginSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFF23e5db),
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            SizedBox(height: 20),
            Column(
              children: [
                Text(
                  'ПРИВЕТСТВУЕМ В OLX!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 35,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003034),
                  ),
                ),
                socialButton(
                  text: 'Продолжить через Facebook',
                  icon: FontAwesome.facebook,
                  onTap: () {
                    print('Facebook bosildi');
                  },
                ),
                socialButton(
                  text: 'Продолжить через Google',
                  icon: FontAwesome.google,
                  onTap: () {
                    print('Google bosildi');
                  },
                ),
                socialButton(
                  text: 'Продолжить через Apple',
                  icon: FontAwesome.apple,
                  onTap: () {
                    print('Apple bosildi');
                  },
                ),

                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(height: 2, color: Color(0xFF003034)),
                      ),
                      SizedBox(width: 9),
                      Text("или"),
                      SizedBox(width: 9),
                      Expanded(
                        child: Container(height: 2, color: Color(0xFF003034)),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isLoginSelected = true;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Text(
                              "Войти",
                              style: TextStyle(
                                color:
                                isLoginSelected
                                    ? Colors.white
                                    : Color(0xFF003034),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isLoginSelected = false;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Text(
                              "Зарегистрироваться",
                              style: TextStyle(
                                color:
                                !isLoginSelected
                                    ? Colors.white
                                    : Color(0xFF003034),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                if (isLoginSelected) LoginWidget() else RegisterWidget(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget socialButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white70),
          borderRadius: BorderRadius.circular(8),
          color: Color(0xFF003034),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
