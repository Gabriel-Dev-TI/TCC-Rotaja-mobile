import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Painel extends StatelessWidget {
  const Painel({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: .center,
        children: [
          Text(
            'O Entregador está a caminho.',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Lottie.asset('assets/animacoes/mapaEntregador.json'),
        ],
      ),
    );
  }
}
