import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rotaja/controller/enderecoController.dart';
import 'package:rotaja/model/endereco.dart';
import 'package:rotaja/views/animacoes/animacao_carregando.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListaEnderecos extends StatefulWidget {
  const ListaEnderecos({super.key});

  @override
  State<ListaEnderecos> createState() => _ListaEnderecosState();
}

Future<List<Endereco>> carregarEnderecosSalvos() async {
  final prefs = await SharedPreferences.getInstance();
  final String? enderecosJson = prefs.getString('enderecos');

  if (enderecosJson != null && enderecosJson.isNotEmpty) {
    final List<dynamic> listaDecodificada = jsonDecode(enderecosJson);
    
    // Mapeia cada Map para uma instância da model Endereco
    return listaDecodificada
        .map((item) => Endereco.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  return [];
}

class _ListaEnderecosState extends State<ListaEnderecos> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meus Endereços',
        ),
      ),
      body: FutureBuilder<List<Endereco>>(
        future: carregarEnderecosSalvos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return AnimacaoCarregando();
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhum endereço cadastrado.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cadastre novos locais para traçar rotas.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            );
          }

          List<Endereco> lista = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lista.length,
            itemBuilder: (context, index) {
              final endereco = lista[index];

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${endereco.logradouro}, Nº ${endereco.numero}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF090D16),
                              ),
                            ),
                            if (endereco.complemento != null && endereco.complemento!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                "Complemento: ${endereco.complemento}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                            const SizedBox(height: 6),
                            Text(
                              "Bairro: ${endereco.bairro}",
                              style: const TextStyle(fontSize: 14, color: Color(0xFF475569)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "${endereco.cidade} - ${endereco.estado}",
                              style: const TextStyle(fontSize: 14, color: Color(0xFF475569)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "CEP: ${endereco.cep}",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF475569),
                              ),
                            ),
                             Text(
                              "${endereco.longitude} - ${endereco.latitude} -- id:${endereco.id}",
                              style: const TextStyle(fontSize: 14, color: Color(0xFF475569)),
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                      
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}