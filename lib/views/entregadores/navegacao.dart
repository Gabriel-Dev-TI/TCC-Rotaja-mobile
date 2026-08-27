import 'package:flutter/material.dart';
import 'package:rotaja/views/entregadores/painel.dart';
import 'package:rotaja/views/produtos/historico.dart';
import 'package:rotaja/views/usuario/configuracoes.dart';

class NavegacaoEntregador extends StatefulWidget {
  const NavegacaoEntregador({super.key});

  @override
  State<NavegacaoEntregador> createState() => _NavegacaoEntregadorState();
}

class _NavegacaoEntregadorState extends State<NavegacaoEntregador> {
  int abaAtual = 0;

  final List<Widget> telas = [
    Painel(),
    Historico(),
    Configuracoes(isEntregador: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
