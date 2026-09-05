import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AnimacaoErro extends StatelessWidget {
  const AnimacaoErro({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Expanded(
              flex: 6,
              child: Lottie.asset("assets/animacoes/Error.json"),
            ),

            Expanded(
              child: Text(
                "Erro ao consultar verifique sua conexão.",
                style: Theme.of(
                  context,
                ).textTheme.titleSmall!.copyWith(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
