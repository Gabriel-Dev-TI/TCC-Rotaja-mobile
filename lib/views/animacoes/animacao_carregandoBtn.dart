import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AnimacaoCarregandoBtn extends StatelessWidget {
  const AnimacaoCarregandoBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Lottie.asset('assets/animacoes/carregando.json'),);
  }
}