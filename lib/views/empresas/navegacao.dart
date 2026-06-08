import 'package:flutter/material.dart';
import 'package:rotaja/configuracoes.dart';
import 'package:rotaja/views/empresas/historico.dart';
import 'package:rotaja/views/empresas/painel.dart';

class NavegacaoEmpresa extends StatefulWidget {
  const NavegacaoEmpresa({super.key});

  @override
  State<NavegacaoEmpresa> createState() => _NavegacaoEmpresaState();
}

class _NavegacaoEmpresaState extends State<NavegacaoEmpresa> {
  int abaAtual = 0;

  final List<Widget> telas = [Painel(), Historico(), Configuracoes()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset('assets/imagens/icone.png'),
        title: const Text('Olá, Empresa!'),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
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
