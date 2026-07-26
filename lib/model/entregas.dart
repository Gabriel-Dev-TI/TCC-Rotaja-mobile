import 'package:rotaja/model/empresa.dart';
import 'package:rotaja/model/endereco.dart';
import 'package:rotaja/model/entregador.dart';
import 'package:rotaja/model/usuario.dart';

enum Status { pendente, em_transito, concluido, cancelado }

class Entregas {
  int? id;
  Empresa? empresa;
  Entregador? entregador;
  Endereco origem;
  Endereco destino;
  Status? status;
  double? preco;
  double peso;
  double altura;
  double largura;
  String? observacoes;
  String? data;
  String? hora;

  Entregas({
    this.id,
    this.empresa,
    this.entregador,
    required this.origem,
    required this.destino,
    this.status,
    this.preco,
    required this.peso,
    required this.largura,
    required this.altura,
    this.observacoes,
    this.data,
    this.hora
  });

  factory Entregas.fromJson(Map<String, dynamic> json) {
    return Entregas(
      id: json['id'],
      empresa:
          json['empresa'] != null && json['empresa'] is Map<String, dynamic>
          ? Empresa.fromJson(json['empresa'])
          : Empresa(
              nome: '',
              email: '',
              senha: '',
              cargo: Cargo.empresa,
              cnpj: '',
              telefone: '',
            ),

      entregador:
          json['entregador'] != null &&
              json['entregador'] is Map<String, dynamic>
          ? Entregador.fromJson(json['entregador'])
          : null,

      origem:
          (json['endereco_origem'] != null &&
              json['endereco_origem'] is Map<String, dynamic>)
          ? Endereco.fromJson(json['endereco_origem'])
          : Endereco.vazio(),

      destino:
          (json['endereco_destino'] != null &&
              json['endereco_destino'] is Map<String, dynamic>)
          ? Endereco.fromJson(json['endereco_destino'])
          : Endereco.vazio(),

      status: Status.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => Status.pendente,
      ),

      preco: double.tryParse(json['preco']?.toString() ?? '') ?? 0.0,
      peso: double.tryParse(json['peso']?.toString() ?? '') ?? 0.0,
      altura: double.tryParse(json['altura']?.toString() ?? '') ?? 0.0,
      largura: double.tryParse(json['largura']?.toString() ?? '') ?? 0.0,

      observacoes: json['observacoes']?.toString(),
      data:json['data'],
      hora:json['hora']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'empresa': empresa?.toJson(),
      'entregador': entregador?.toJson(),
      'origem': origem.toJson(),
      'destino': destino.toJson(),
      'status': status?.name,
      'preco': preco,
      'peso': peso,
      'altura': altura,
      'largura': largura,
      'observacoes': observacoes,
    };
  }
}
