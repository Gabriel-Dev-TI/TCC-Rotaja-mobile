import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rotaja/controller/enderecoController.dart';
import 'package:rotaja/model/endereco.dart';
import 'package:rotaja/repository/cep.dart';
import 'package:rotaja/views/animacoes/animacao_carregandoBtn.dart';
import 'package:rotaja/views/widgets/snackbar.dart';

class EnderecoCadastro extends StatefulWidget {
  const EnderecoCadastro({super.key});

  @override
  State<EnderecoCadastro> createState() => _EnderecoCadastroState();
}

class _EnderecoCadastroState extends State<EnderecoCadastro> {
  final _secondformKey = GlobalKey<FormState>();

  final _cepController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _numeroController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _estadoController = TextEditingController();
  final _complementoController = TextEditingController();

  bool carregandoCep = false;
  bool isLoading = false;
  final cepService = CepService();

  @override
  void dispose() {
    _cepController.dispose();
    _logradouroController.dispose();
    _numeroController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    _complementoController.dispose();
    super.dispose();
  }

  Future<void> buscarCep() async {
    final cep = _cepController.text.trim();
    if (cep.isEmpty) return;

    setState(() => carregandoCep = true);

    final endereco = await cepService.buscarEndereco(cep);

    if (mounted) {
      if (endereco != null) {
        setState(() {
          _logradouroController.text = endereco.logradouro;
          _bairroController.text = endereco.bairro;
          _cidadeController.text = endereco.cidade;
          _estadoController.text = endereco.estado;
          carregandoCep = false;
        });
      } else {
        setState(() => carregandoCep = false);
        mostraSnackBar.show(context, "CEP não encontrado.", true);
      }
    }
  }

  void salvar() async {
  if (!_secondformKey.currentState!.validate()) return;

  setState(() => isLoading = true);

  Endereco endereco = Endereco(
    logradouro: _logradouroController.text.trim(),
    numero: _numeroController.text.trim(),
    bairro: _bairroController.text.trim(),
    cep: _cepController.text.trim(),
    cidade: _cidadeController.text.trim(),
    estado: _estadoController.text.trim(),
    complemento: _complementoController.text.trim(),
  );

  String resposta = await cadastrarEndereco(endereco);
  bool cadastroFalhou = resposta != 'Endereço salvo com sucesso!';

  if (!cadastroFalhou && mounted) {
    Navigator.pop(context, endereco);
  }

    mostraSnackBar.show(context, resposta, cadastroFalhou);
    setState(() => isLoading = false);
  
}

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cadastro de Endereço'),
      content: SingleChildScrollView(
        child: Form(
          key: _secondformKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _cepController,
                      keyboardType: TextInputType.number,
                      maxLength: 9,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      decoration: InputDecoration(
                        counterText: '',
                        labelText: 'CEP',
                        suffixIcon: carregandoCep
                            ? Transform.scale(
                                scale: 0.5,
                                child: const CircularProgressIndicator(),
                              )
                            : IconButton(
                                onPressed: buscarCep,
                                icon: const Icon(Icons.search),
                              ),
                      ),
                      validator: (value) {
                        if (value!.length != 9) {
                          return 'O CEP deve possuir 9 dígitos';
                        }
                        if (value!.isEmpty) {
                          return 'Informe o CEP';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _numeroController,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      decoration: const InputDecoration(
                        labelText: 'Número',
                        counterText: '',
                      ),
                      validator: (value) {
                        if (value!.length > 10) {
                          return 'O Número não pode ter mais de 10 dígitos';
                        }
                        if (value!.isEmpty) {
                          return 'Informe o Número';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _logradouroController,
                decoration: const InputDecoration(labelText: 'Logradouro'),
                validator: (value) => value!.isEmpty ? 'Informe a rua' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bairroController,
                decoration: const InputDecoration(labelText: 'Bairro'),
                validator: (value) =>
                    value!.isEmpty ? 'Informe o bairro' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _cidadeController,
                      decoration: const InputDecoration(labelText: 'Cidade'),
                      validator: (value) =>
                          value!.isEmpty ? 'Informe a Cidade' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _estadoController,
                      decoration: const InputDecoration(labelText: 'Estado'),
                      validator: (value) =>
                          value!.isEmpty ? 'Informe o Estado' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _complementoController,
                decoration: const InputDecoration(
                  labelText: 'Complemento (Opcional)',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        SizedBox(
          width: 100,
          height: 35,
          child: ElevatedButton(
            onPressed: isLoading ? null : salvar,
            child: isLoading ? AnimacaoCarregandoBtn() : const Text('Salvar'),
          ),
        ),
      ],
    );
  }
}
