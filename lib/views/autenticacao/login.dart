import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  const Login({super.key});

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
          Text(
            'Conectamos quem envia com quem entrega.',
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: .center,
          ),
          Text(
            'Entregas mais rápidas e eficientes.',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF6F42C1),
            ),
            textAlign: .center,
          ),
          Image.asset(
            'assets/imagens/fundo.png',
            width: MediaQuery.widthOf(context),
            height: MediaQuery.heightOf(context) * .5,
          ),
          
          Container(
            padding: EdgeInsets.all(10),
            width: 500,
            height: MediaQuery.heightOf(context) * .1,
            child: ElevatedButton(
              onPressed:() {
                Navigator.pushReplacementNamed(context, '/entregador');
              },
              child: Row(
                spacing: 5,
                mainAxisAlignment: .center,
                children: [
                Icon(Icons.motorcycle),
                Text('Entregador')
              ],),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            width: 500,
            height: MediaQuery.heightOf(context) * .1,
            child: ElevatedButton(
              onPressed:() {
                Navigator.pushReplacementNamed(context, '/empresa');
              },
              child: Row(
                spacing: 5,
                mainAxisAlignment: .center,
                children: [
                Icon(Icons.store),
                Text('Empresa')
              ],),
            ),
          ),
        ],
      ),
    );
  }
}
