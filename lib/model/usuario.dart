enum Cargo { administrador, entregador, empresa }

class Usuario {
  int? id;
  String nome;
  String email;
  String senha;
  String telefone;
  Cargo cargo; 
  String? criadoEm;

  Usuario({
    this.id,
    required this.telefone,
    required this.nome,
    required this.email,
    required this.senha,
    required this.cargo,
    this.criadoEm,
  });
}