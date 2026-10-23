import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:rotaja/model/endereco.dart';
import 'package:rotaja/controller/entregaController.dart';
import 'package:rotaja/repository/api.dart';
import 'package:rotaja/views/widgets/snackbar.dart';


Future<Map<String,dynamic>?> carregarDados() async {
  try{
    final resposta = await Api().get('/mapa');
    if (resposta.statusCode == 200 && resposta.body.isNotEmpty) {
      final dados = json.decode(resposta.body);
      return dados;
    }
    else {
      return null;
    }
  } catch (e) {
  return null;
  }
}