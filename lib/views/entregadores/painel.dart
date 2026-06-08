import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Painel extends StatelessWidget {
  const Painel({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Lottie.asset('assets/animacoes/mapaEntregador.json'));
  }
}
