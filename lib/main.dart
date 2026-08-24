import 'package:flutter/material.dart';

import 'package:rotaja/views/autenticacao/escolha.dart';
import 'package:rotaja/views/cadastros/empresaCadastro.dart';
import 'package:rotaja/views/cadastros/enderecoCadastro.dart';
import 'package:rotaja/views/cadastros/entregaCadastro.dart';
import 'package:rotaja/views/cadastros/entregadorCadastro.dart';
import 'package:rotaja/views/empresas/lista_enderecos.dart';
import 'package:rotaja/views/entregadores/mapa.dart';
import 'package:rotaja/views/produtos/produto.dart';
import 'package:rotaja/views/entregadores/navegacao.dart';
import 'package:rotaja/views/empresas/navegacao.dart';
import 'package:rotaja/views/usuario/dados.dart';
import 'views/splash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color corRoxa = Color(0xFF6F42C1);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rota Já',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: corRoxa,
          primary: corRoxa,
          secondary: Color(0xFF090D16),
          onSecondary: const Color(0xFFF8F9FA),
          tertiary: Colors.grey[600],
          surface: Colors.white,
          onSurface: const Color(0xFF1C1B1F),
        ),
        textTheme: const TextTheme(
          //Titulo 1
          titleLarge: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: Color(0xFF1C1B1F),
          ),

          //Titulo 2
          titleMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1C1B1F),
          ),

          // Título 3 / Subtitulo
          titleSmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF49454F),
          ),

          // Texto Grande
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),

          // Texto Padrão
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF49454F),
            height: 1.5,
          ),

          // Texto Pequeno
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFF79747E),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: corRoxa,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          labelStyle: Theme.of(context).textTheme.bodyMedium,
          hintStyle: Theme.of(context).textTheme.bodyMedium,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: corRoxa, width: 2),
          ),
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const Splash(),
        '/escolha': (context) => const Escolha(),
        '/entregador': (context) => const NavegacaoEntregador(),
        '/empresa': (context) => const NavegacaoEmpresa(),
        '/empresaCadastro': (context) => EmpresaCadastro(),
        '/entregaCadastro': (context) => EntregaCadastro(),
        '/entregadorCadastro': (context) => EntregadorCadastro(),
        '/enderecoCadastro': (context) => EnderecoCadastro(),
        '/listaEnderecos': (context) => const ListaEnderecos(),
        '/produto': (context) => const Produto(),
        '/dados': (context) => const Dados(),
        '/mapa': (context) => const Mapa(),
      },
    );
  }
}
