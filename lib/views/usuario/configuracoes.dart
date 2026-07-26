import 'package:flutter/material.dart';
import 'package:rotaja/repository/api.dart';
import 'package:rotaja/views/widgets/snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Configuracoes extends StatefulWidget {
  Configuracoes({super.key, this.isEntregador});

  @override
  State<Configuracoes> createState() => _ConfiguracoesState(isEntregador: isEntregador);
  bool? isEntregador;
}

RoundedRectangleBorder bordaArredondada(double tamanho, Color cor) {
  return RoundedRectangleBorder(
    borderRadius: BorderRadiusGeometry.circular(tamanho),
    side: BorderSide(color: cor),
  );
}

class _ConfiguracoesState extends State<Configuracoes> {
  _ConfiguracoesState({this.isEntregador});
  bool temaClaro = true;
  bool? isEntregador;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final temaCor = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0, left: 4.0),
            child: Text(
              'Configurações',
              style: tema.titleLarge,
            ),
          ),
          SizedBox(height: 20),
          Text("Conta", style: tema.titleMedium),
          InkWell(
            onTap: () async {
              Navigator.pushNamed(context, '/dados');
            },
            child: ListTile(
              title: Text("Dados da Conta"),
              leading: Icon(Icons.person),
              trailing: Icon(Icons.arrow_forward_ios),
              shape: bordaArredondada(5, temaCor.tertiary),
            ),
          ),
          SizedBox(height: 10),

          //O entregador não precisa cadastrar enderecos
          if(isEntregador == null || isEntregador == false)
          InkWell(
            onTap: () async {
              Navigator.pushNamed(context, '/listaEnderecos');
            },
            child: ListTile(
              title: Text("Endereços"),
              leading: Icon(Icons.location_on),
              trailing: Icon(Icons.arrow_forward_ios),
              shape: bordaArredondada(5, temaCor.tertiary),
            ),
          ),
          SizedBox(height: 20),
          Text("Preferências", style: tema.titleMedium),
          ListTile(
            title: Text("Tema Claro"),
            leading: Icon(Icons.color_lens),
            trailing: Switch(
              value: temaClaro,
              onChanged: (value) {
                setState(() {
                  temaClaro = !temaClaro;
                });
              },
            ),
            shape: bordaArredondada(5, temaCor.tertiary),
          ),
          SizedBox(height: 20),
          InkWell(
            onTap: () async {

              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.clear();
              
              Navigator.pushReplacementNamed(context, '/splash');
              
            },
            child: ListTile(
              title: Text("Sair da conta"),
              trailing: Icon(Icons.exit_to_app_outlined, color: temaCor.error),
              textColor: temaCor.error,
              shape: bordaArredondada(5, temaCor.error),
            ),
          ),
        ],
      ),
    );
  }
}
