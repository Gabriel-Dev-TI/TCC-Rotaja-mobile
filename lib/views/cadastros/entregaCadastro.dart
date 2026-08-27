import 'package:flutter/material.dart';
import 'package:rotaja/controller/entregaController.dart';
import 'package:rotaja/model/endereco.dart';
import 'package:rotaja/model/entregas.dart';
import 'package:rotaja/views/animacoes/animacao_carregandoBtn.dart';
import 'package:rotaja/views/widgets/dropdownitems.dart';
import 'package:rotaja/views/widgets/snackbar.dart';

class EntregaCadastro extends StatefulWidget {
  const EntregaCadastro({super.key});

  @override
  State<EntregaCadastro> createState() => _EntregaCadastroState();
}

class _EntregaCadastroState extends State<EntregaCadastro> {
  final _formKey = GlobalKey<FormState>();

  final _larguraController = TextEditingController();
  final _alturaController = TextEditingController();
  final _pesoController = TextEditingController();
  final _nomeController = TextEditingController();
  final _comprimentoController = TextEditingController();
  final _descricaoController = TextEditingController();

  Endereco? _origemController;
  Endereco? _destinoController;

  bool isLoading = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _comprimentoController.dispose();
    _descricaoController.dispose();
    _larguraController.dispose();
    _alturaController.dispose();
    _pesoController.dispose();
    super.dispose();
  }

  void cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_origemController == null || _destinoController == null) {
      mostraSnackBar.show(context, 'Selecione ou cadastre os endereços.', true);
      return;
    }

    setState(() => isLoading = true);

    Entregas entrega = Entregas(
      origem: _origemController!,
      destino: _destinoController!,
      largura:double.tryParse(_larguraController.text.replaceAll(',', '.')) ?? 0.0,
      altura:double.tryParse(_alturaController.text.replaceAll(',', '.')) ?? 0.0,
      peso: double.tryParse(_pesoController.text.replaceAll(',', '.')) ?? 0.0,
      comprimento: double.tryParse(_comprimentoController.text.replaceAll(',', '.')) ?? 0.0,
      descricao: _descricaoController.text,
      nomeProduto: _nomeController.text,
    );

    String resposta = await cadastraEntrega(entrega);
    bool cadastroFalhou = resposta != 'Entrega cadastrada com sucesso!';

    if (mounted) {
      if (!cadastroFalhou) {
        Navigator.pop(context);
      }
      mostraSnackBar.show(context, resposta, cadastroFalhou);
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final primaryColor = tema.colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: tema.colorScheme.surface),
        title: Text(
          'Cadastro de Entrega',
          style: tema.textTheme.titleLarge!.copyWith(
            color: tema.colorScheme.surface,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.local_shipping_outlined,
                    size: 60,
                    color: primaryColor,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Nova Entrega',
                    textAlign: TextAlign.center,
                    style: tema.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Preencha as informações do pacote\ne selecione os endereços.',
                    textAlign: TextAlign.center,
                    style: tema.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 10),

                  Card(
                    color: tema.colorScheme.onSecondary,
                    elevation: 10,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: .start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.inventory_2_outlined),
                              SizedBox(width: 10),
                              Text(
                                'Produto',
                                style: tema.textTheme.bodyMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                            Expanded(
                            flex: 2,
                            child: TextFormField(
                                    controller: _nomeController,
                                    keyboardType: TextInputType.name,
                                    decoration: const InputDecoration(
                                      labelText: 'Nome do Produto',
                                    ),
                                    validator: (v) =>
                                        v == null || v.isEmpty ? 'Informe' : null,
                                  ),
                          ),
                          const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller: _pesoController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    decoration: const InputDecoration(
                                      labelText: 'Peso (kg)',
                                    ),
                                    validator: (v) =>
                                        v == null || v.isEmpty ? 'Informe' : null,
                                  ),
                                ),
                          ],),
                          const SizedBox(height: 6),
                          TextFormField(
                                    controller: _descricaoController,
                                    keyboardType: TextInputType.name,
                                    decoration: const InputDecoration(
                                      labelText: 'Descrição do Produto',
                                    ),
                                    validator: (v) =>
                                        v == null || v.isEmpty ? 'Informe' : null,
                                  ),
                          const SizedBox(height: 6),
                              Text(
                                'Dimensões do Produto',
                                style: tema.textTheme.bodyMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          const SizedBox(height: 6),
                          

                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _larguraController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  decoration: const InputDecoration(
                                    labelText: 'Largura (cm)',
                                  ),
                                  validator: (v) =>
                                      v == null || v.isEmpty ? 'Informe' : null,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller: _alturaController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  decoration: const InputDecoration(
                                    labelText: 'Altura (cm)',
                                  ),
                                  validator: (v) =>
                                      v == null || v.isEmpty ? 'Informe' : null,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller: _comprimentoController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  decoration: const InputDecoration(
                                    labelText: 'Comprimento (cm)',
                                  ),
                                  validator: (v) =>
                                      v == null || v.isEmpty ? 'Informe' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          DropDownEndereco(
                            enderecoSelecionado: _origemController,
                            label: 'de Origem',
                            icon: const Icon(Icons.location_on_outlined),
                            salvarNaApi: true,
                            onChanged: (novoEndereco) {
                              setState(() {
                                _origemController = novoEndereco;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          DropDownEndereco(
                            enderecoSelecionado: _destinoController,
                            label: 'de Destino',
                            icon: const Icon(Icons.flag_outlined),
                            salvarNaApi: true,
                            onChanged: (novoEndereco) {
                              setState(() {
                                _destinoController = novoEndereco;
                              });
                            },
                          ),
                          
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : cadastrar,
                      child: isLoading
                          ? AnimacaoCarregandoBtn()
                          : Text(
                              'Cadastrar Entrega',
                              style: tema.textTheme.bodyLarge!.copyWith(
                                color: tema.colorScheme.surface,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
