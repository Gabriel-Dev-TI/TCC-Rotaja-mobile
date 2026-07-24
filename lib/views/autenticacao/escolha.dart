import 'package:flutter/material.dart';
import 'package:rotaja/views/autenticacao/login.dart';

class Escolha extends StatelessWidget {
  const Escolha({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Image.asset(
            'assets/imagens/logo.png',
            width: MediaQuery.widthOf(context) * .5,
            height: MediaQuery.heightOf(context) * .2,
          ),
          const Text(
            'Conectamos quem envia com quem entrega.',
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: .center,
          ),
          Text(
            'Entregas mais rápidas e eficientes.',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: .center,
          ),
          Image.asset(
            'assets/imagens/fundo.png',
            width: MediaQuery.widthOf(context),
            height: MediaQuery.heightOf(context) * .5,
          ),
          Container(
            padding: const EdgeInsets.all(10),
            width: 450,
            height: MediaQuery.heightOf(context) * .1,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Login(cargo: 'entregador'),
                  ),
                );
              },
              child: Row(
                spacing: 5,
                mainAxisAlignment: .center,
                children: [const Icon(Icons.motorcycle),const Text('Entregador')],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            width: 450,
            height: MediaQuery.heightOf(context) * .1,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.all(Radius.circular(12)),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                backgroundColor: Theme.of(context).colorScheme.onPrimary,
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Login(cargo: 'empresa'),
                  ),
                );
              },
              child: Row(
                spacing: 5,
                mainAxisAlignment: .center,
                children: [const Icon(Icons.store), const Text('Empresa')],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
