import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AnimacaoCarregando extends StatelessWidget {
  const AnimacaoCarregando({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Lottie.asset('assets/animacoes/loading-sand.json'),);
  }
}