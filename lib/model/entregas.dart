import 'package:rotaja/model/empresa.dart';
import 'package:rotaja/model/endereco.dart';
import 'package:rotaja/model/entregador.dart';

enum Status { pendente, aceita, em_transito, concluido, cancelado }

class Entregas {
  int? id;
  Empresa? empresa;
  Entregador? entregador;
  Endereco? origem;
  Endereco? destino;
  Status? status;
  double? preco;
  double? peso;
  double? altura;
  double? largura;
  double? comprimento;
  double? distancia;
  int? tempoEstimado;
  String? nomeProduto;
  String? observacoes;
  String? descricao;
  String? data;
  String? hora;

  Entregas({
    this.id,
    this.empresa,
    this.entregador,
    this.origem,
    this.destino,
    this.status,
    this.preco,
    this.peso,
    this.largura,
    this.altura,
    this.observacoes,
    this.descricao,
    this.distancia,
    this.tempoEstimado,
    this.nomeProduto,
    this.comprimento,
    this.data,
    this.hora,
  });

  factory Entregas.fromJson(Map<String, dynamic> json) {
    // Helper para converter inteiros, doubles ou Strings numéricas sem quebrar
    double? paraDouble(dynamic valor) {
      if (valor == null) return null;
      if (valor is double) return valor;
      if (valor is int) return valor.toDouble();
      return double.tryParse(valor.toString());
    }

    return Entregas(
      id: json['id'],
      nomeProduto: json['nome_produto'],
      comprimento: paraDouble(json['comprimento']),
      preco: paraDouble(json['preco']),
      peso: paraDouble(json['peso']),
      altura: paraDouble(json['altura']),
      largura: paraDouble(json['largura']),
      distancia: paraDouble(json['distancia']),
      tempoEstimado: json['tempo_estimado_minutos'],
      empresa: json['empresa'] != null ? Empresa.fromJson(json['empresa']) : null,
      entregador: json['entregador'] != null ? Entregador.fromJson(json['entregador']) : null,
      origem: json['endereco_origem'] != null ? Endereco.fromJson(json['endereco_origem']) : null,
      destino: json['endereco_destino'] != null ? Endereco.fromJson(json['endereco_destino']) : null,
      status: Status.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => Status.pendente,
      ),
      observacoes: json['observacoes'],
      descricao: json['descricao'],
      data: json['data'],
      hora: json['hora'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome_produto': nomeProduto,
      'descricao': descricao,
      'largura': largura,
      'altura': altura,
      'peso': peso,
      'comprimento': comprimento,
      'origem': origem!.id,
      'destino': destino!.id,
      'observacoes': observacoes,
    };
  }
}