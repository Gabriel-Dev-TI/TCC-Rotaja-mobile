import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AnimacaoErro extends StatelessWidget {
  const AnimacaoErro({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: .spaceEvenly,
      children: [
        Lottie.asset("assets/animacoes/Error.json"),
        Text(
          "Erro ao consultar verifique sua conexão.",
          style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
