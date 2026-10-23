import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AnimacaoEntregador extends StatelessWidget {
  const AnimacaoEntregador({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: .spaceEvenly,
        children: [
          Lottie.asset("assets/animacoes/mapaEntregador.json"),
          Text(
            "Calculando rota, aguarde.",
            style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
