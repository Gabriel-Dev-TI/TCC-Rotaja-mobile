import 'package:flutter/material.dart';
import 'package:rotaja/views/entregadores/navegacao.dart';
import 'package:rotaja/views/empresas/navegacao.dart';
import 'package:rotaja/views/autenticacao/login.dart';
import 'splash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color corRoxa = Color(0xFF6F42C1);
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove etiqueta do debug
      title: 'Rota Já',
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: corRoxa,
          primary: corRoxa,
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: corRoxa,
            foregroundColor: Colors.white,
          ),
        ),
      ),

      initialRoute: '/splash',
      routes: {
        '/splash': (context) => Splash(),
        '/login': (context) => Login(),
        '/entregador': (context) => NavegacaoEntregador(),
        '/empresa': (context) => NavegacaoEmpresa(),
      },
    );
  }
}
