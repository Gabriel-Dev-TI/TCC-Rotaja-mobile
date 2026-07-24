import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), () {
      redirecionamento();
    });
  }

  Future<void> redirecionamento() async {
    String? cargo = await verificaCargo();
    bool token = await verificaToken();

    // Garante que o widget ainda está na árvore antes de navegar
    if (!mounted) return;

    if (token && cargo == 'entregador') {
      Navigator.pushReplacementNamed(context, '/entregador');
    } else if (token && cargo == 'empresa') {
      Navigator.pushReplacementNamed(context, '/empresa');
    } else {
      Navigator.pushReplacementNamed(context, '/escolha');
    }
  }

  Future<bool> verificaToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString('token') != null;
  }

  Future<String?> verificaCargo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? cargo = prefs.getString('cargo');

    if (cargo == 'entregador') {
      return 'entregador';
    }
    if (cargo == 'empresa') {
      return 'empresa';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/imagens/logo.png',
          width: MediaQuery.sizeOf(context).width * .5,
          height: MediaQuery.sizeOf(context).height * .3,
        ),
      ),
    );
  }
}
