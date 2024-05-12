import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:hehe/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
const users =  {
  'dribbble@gmail.com': '12345',
  'hunter@gmail.com': 'hunter',
};

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Duration get loginTime => const Duration(milliseconds: 2250);

  Future<String?> _authUser(LoginData data) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: data.name,
        password: data.password,
      );
      // Đăng nhập thành công, không cần trả về lỗi
      return null;
    } catch (e) {
      // Xử lý lỗi nếu có
      print("Lỗi khi đăng nhập: $e");
      return 'Đăng nhập không thành công';
    }
  }

  Future<String?> _signupUser(SignupData data) async {

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: data.name!,
        password: data.password!,
      );
      // Đăng ký thành công, không cần trả về lỗi
      return null;
    } catch (e) {
      // Xử lý lỗi nếu có
      print("Lỗi khi đăng ký: $e");
      return 'Đăng ký không thành công';
    }
  }


  Future<String?> _recoverPassword(String name) {
    debugPrint('Name: $name');
    return Future.delayed(loginTime).then((_) {
      if (!users.containsKey(name)) {
        return 'Người dùng không tồn tại';
      }
      return null;
    });
  }


  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'To Do',
      onLogin: _authUser,
      onSignup: _signupUser,
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const MyApp(),
        ));
      },
      onRecoverPassword: _recoverPassword,
    );
  }
}