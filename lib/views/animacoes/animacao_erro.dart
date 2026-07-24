import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AnimacaoErro extends StatelessWidget {
  const AnimacaoErro({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        "assets/animacoes/sem-conexao.json",
        
      ),
    );
  }
}
