import 'package:rotaja/model/empresa.dart';
import 'package:rotaja/model/endereco.dart';
import 'package:rotaja/model/entregador.dart';

enum Status { pendente, aceito, em_transito, concluido, cancelado }

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
    required this.peso,
    required this.largura,
    required this.altura,
    this.observacoes,
    this.descricao,
    this.distancia,
    this.tempoEstimado,
    this.nomeProduto,
    this.comprimento,
    this.data,
    this.hora
  });

  factory Entregas.fromJson(Map<String, dynamic> json) {
    return Entregas(
      id: json['id'],
      nomeProduto: json['nome_produto'],
      comprimento: json['comprimento'],
      empresa: json['empresa'] != null ? Empresa.fromJson(json['empresa']) : null,
      entregador: json['entregador'] != null ? Entregador.fromJson(json['entregador']) : null,
      origem: json['endereco_origem'] != null ? Endereco.fromJson(json['endereco_origem']): null,
      destino: json['endereco_destino'] != null ? Endereco.fromJson(json['endereco_destino']): null, 
      status: Status.values.firstWhere((e) => e.name == json['status'],orElse: () => Status.pendente,),
      preco: double.tryParse(json['preco']),
      peso: double.tryParse(json['peso']),
      altura: double.tryParse(json['altura']),
      largura: double.tryParse(json['largura']),
      distancia: double.tryParse(json['distancia']),
      tempoEstimado: json['tempo_estimado_minutos'],
      observacoes: json['observacoes'],
      descricao: json['descricao'],
      data:json['data'],
      hora:json['hora']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome_produto':nomeProduto,
      'empresa': empresa?.toJson(),
      'entregador': entregador?.toJson(),
      'origem': origem!.id,
      'destino': destino!.id,
      'status': status?.name,
      'comprimento': comprimento,
      'peso': peso,
      'altura': altura,
      'largura': largura,
      'observacoes': observacoes,
      'descricao': descricao,
    };
  }
}
