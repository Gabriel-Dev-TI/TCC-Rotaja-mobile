import 'package:flutter/material.dart';

class Historico extends StatelessWidget {
  const Historico({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        spacing: 10,
        crossAxisAlignment: .center,
        mainAxisAlignment: .center,
        children: [
          Icon(Icons.history_toggle_off),
          Text('Nenhum pedido foi feito ainda.'),
        ],
      ),
    );
  }
}
