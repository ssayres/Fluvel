import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_front/cubits/cubits.dart';
import 'package:flutter_front/screens/chat_list/chat_list_screen.dart';
import 'package:flutter_login/flutter_login.dart';

class GuestScreen extends StatelessWidget {
  const GuestScreen({super.key});

  static const routeName = "guest";

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GuestCubit>();

    return FlutterLogin(
      scrollable: true,
      hideForgotPasswordButton: true,
      title: 'Via Chat',
      theme: LoginTheme(
        titleStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        pageColorDark: Color.fromARGB(255, 255, 200, 98),
        pageColorLight: Color.fromARGB(255, 254, 254, 255),
      ),
      logo: const AssetImage('assets/images/chat.png'),
      onLogin: cubit.signIn,
      onSignup: cubit.signUp,
      userValidator: (value) {
        if (value == null || !value.contains('@')) {
          return 'Please enter a valid email address';
        }
        return null;
      },
      passwordValidator: (value) {
        if (value == null || value.length < 5) {
          return "Please must be at least 5 chars";
        }
        return null;
      },
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacementNamed(ChatListScreen.routeName);
      },
      onRecoverPassword: (_) async => null,
    );
  }
}