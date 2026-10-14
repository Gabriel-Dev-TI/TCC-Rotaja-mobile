import 'package:flutter/material.dart';
import 'package:rotaja/controller/enderecoController.dart';
import 'package:rotaja/model/endereco.dart';
import 'package:rotaja/repository/cep.dart';
import 'package:rotaja/repository/cordenadas.dart';
import 'package:rotaja/views/animacoes/animacao_carregandoBtn.dart';
import 'package:rotaja/views/widgets/snackbar.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:latlong2/latlong.dart';

class EnderecoCadastro extends StatefulWidget {
  final bool salvarNaApi;
  final Endereco? enderecoParaEditar; 

  EnderecoCadastro({
    super.key,
    this.salvarNaApi = true,
    this.enderecoParaEditar,
  });

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

  final maskCep = MaskTextInputFormatter(mask: "#####-###", filter: {"#": RegExp(r'[0-9]')});

  bool carregandoCep = false;
  bool isLoading = false;
  final cepService = CepService();

  bool get editando => widget.enderecoParaEditar != null;

  @override
  void initState() {
    super.initState();
    if (editando) {
      preencherCampos(widget.enderecoParaEditar!);
    }
  }

  void preencherCampos(Endereco e) {
    _cepController.text = e.cep ?? '';
    _logradouroController.text = e.logradouro ?? '';
    _numeroController.text = e.numero ?? '';
    _bairroController.text = e.bairro ?? '';
    _cidadeController.text = e.cidade ?? '';
    _estadoController.text = e.estado ?? '';
    _complementoController.text = e.complemento ?? '';
  }

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
    setState(() => carregandoCep = true);

    final endereco = await cepService.buscarEndereco(_cepController.text.trim());

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

  if (editando) {
    endereco.id = widget.enderecoParaEditar!.id;
  }

  if (!widget.salvarNaApi) {
    try {
      final conversao = Cordenadas();
      LatLng? cordenadas = await conversao.converteEmCordenadas(endereco);
      if (cordenadas != null) {
        endereco.latitude = cordenadas.latitude;
        endereco.longitude = cordenadas.longitude;
      }
    } catch (_) {}

    if (!mounted) return; 
    Navigator.pop(context, endereco);
    mostraSnackBar.show(context,
        editando ? 'Endereço atualizado com sucesso!' : 'Endereço selecionado com sucesso!', false);
    return;
  }

  String resposta;
  if (editando) {
    resposta = await editarEndereco(endereco);
  } else {
    resposta = await cadastrarEndereco(endereco);
  }

  bool cadastroFalhou = resposta != 'Endereço salvo com sucesso!';

  if (!mounted) return;

  if (!cadastroFalhou && widget.salvarNaApi) {
    final enderecos = await listarSharedPreferences();
    final enderecoSalvo = enderecos.lastWhere(
      (e) => e.logradouro == endereco.logradouro &&
             e.bairro == endereco.bairro &&
             e.cidade == endereco.cidade &&
             e.estado == endereco.estado &&
             e.numero == endereco.numero &&
             e.cep == endereco.cep,
    );
    Navigator.pop(context, enderecoSalvo);
  }

  if (mounted) {
    mostraSnackBar.show(context, resposta, cadastroFalhou);
    setState(() => isLoading = false);
  }
}   
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(editando ? 'Editar Endereço' : 'Cadastro de Endereço'),
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
                      inputFormatters: [maskCep],
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
                        if (value!.length != 9) return 'O CEP deve possuir 9 dígitos';
                        if (value!.isEmpty) return 'Informe o CEP';
                        return null;
                      },
                      onChanged: (value) {
                        if (value.length == 9) buscarCep();
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
                        if (value!.length > 10) return 'Máximo de 10 dígitos';
                        if (value!.isEmpty) return 'Informe o Número';
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
                validator: (value) => value!.isEmpty ? 'Informe o bairro' : null,
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
          height: 40,
          child: ElevatedButton(
            onPressed: isLoading ? null : salvar,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              minimumSize: const Size(120, 40), 
            ),
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: AnimacaoCarregandoBtn(),
                  )
                : Text(editando ? 'Atualizar' : 'Salvar'),
          ),
        ),   
      ],
    );
  }
}   