import 'package:flutter/material.dart';
import 'package:rotaja/views/entregadores/mapa.dart';
import 'package:rotaja/views/entregadores/painel.dart';
import 'package:rotaja/views/entregadores/historico.dart';
import 'package:rotaja/configuracoes.dart';

class NavegacaoEntregador extends StatefulWidget {
  const NavegacaoEntregador({super.key});

  @override
  State<NavegacaoEntregador> createState() => _NavegacaoEntregadorState();
}

class _NavegacaoEntregadorState extends State<NavegacaoEntregador> {
  int abaAtual = 1;

  final List<Widget> telas = [Mapa(), Painel(), Historico(), Configuracoes()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset(
          'assets/imagens/icone.png',
        ),
        title: const Text('Olá, Entregador!'),
      ),

      body: SafeArea(child: telas[abaAtual]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: abaAtual,
        onTap: (index) {
          setState(() {
            abaAtual = index;
          });
        },
        type: BottomNavigationBarType.fixed,

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(
            icon: Icon(Icons.motorcycle),
            label: 'Entregas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Histórico',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configurações',
          ),
        ],
      ),
    );
  }
}
