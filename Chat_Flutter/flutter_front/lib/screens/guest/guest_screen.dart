import 'package:flutter/material.dart';
import 'package:flutter_front/screens/chat_list/chat_list_screen.dart';
import 'package:flutter_login/flutter_login.dart';

const users = const {
  'dribble@gmail.com': '12345678',
  'hunter@gmail.com': 'hunter',
};

class GuestScreen extends StatelessWidget {
  const GuestScreen({super.key});

  static const routeName = "guest";

  Duration get loginTime => Duration(milliseconds: 2250);

  Future<String?> _authUser(LoginData data) {
    debugPrint('Name; ${data.name}, Password; ${data.password}');
    return Future.delayed(loginTime).then((_) {
      if (!users.containsKey(data.name)) {
        return 'User not exists';
      }
      if (users[data.name] != data.password) {
        return 'Password does not match';
      }
      return null;
    });
  }

  Future<String?> _signupUser(SignupData data) {
    debugPrint('Signup Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) {
      return null;
    });
  }

  Future<String?> _recoverPassword(String name) {
    debugPrint('Name : ${name}');
    return Future.delayed(loginTime).then((_) {
      if (!users.containsKey(name)) {
        return 'User not exists';
      }
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      scrollable: true,
      hideForgotPasswordButton: true,
      title: 'Via Chat',
      theme: LoginTheme(
        pageColorDark: Color.fromARGB(255, 223, 240, 253),
        pageColorLight: Color.fromARGB(255, 246, 159, 100),
      ),
      logo: const AssetImage('icons/icon.png'),
      onLogin: _authUser,
      onSignup: _signupUser,
      userValidator: (value) {
        if (value == null || !value.contains('@')) {
          return 'Por favor, coloque um endereço de e-mal válido';
        }
      },
      passwordValidator: (value) {
        if (value == null || value.length < 8) {
          return "Senha deve conter no mínimo 8 caracteres";
        }
        return null;
      },
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacementNamed(ChatListScreen.routeName);
      },
      onRecoverPassword: _recoverPassword,
    );
  }
}
