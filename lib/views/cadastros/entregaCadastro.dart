import 'package:flutter/material.dart';
import 'package:rotaja/controller/entregaController.dart';
import 'package:rotaja/controller/enderecoController.dart';
import 'package:rotaja/model/entregas.dart';
import 'package:rotaja/model/endereco.dart';
import 'package:rotaja/views/animacoes/animacao_carregando.dart';
import 'package:rotaja/views/cadastros/enderecoCadastro.dart';
import 'package:rotaja/views/widgets/snackbar.dart';

class EntregaCadastro extends StatefulWidget {
  const EntregaCadastro({super.key});

  @override
  State<EntregaCadastro> createState() => _EntregaCadastroState();
}

class _EntregaCadastroState extends State<EntregaCadastro> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _larguraController = TextEditingController();
  final _alturaController = TextEditingController();
  final _pesoController = TextEditingController();

  Endereco? _origemController;
  Endereco? _destinoController;

  bool isLoading = false;
  List<Endereco> _listaEnderecos = [];

  @override
  void initState() {
    super.initState();
    carregarEnderecos();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _larguraController.dispose();
    _alturaController.dispose();
    _pesoController.dispose();
    super.dispose();
  }

  Future<void> carregarEnderecos() async {
    final enderecos = await listarSharedPreferences();
    if (mounted) {
      setState(() => _listaEnderecos = enderecos);
    }
  }

  Future<void> abrirCadastroEndereco(bool isOrigem) async {
    final Endereco? enderecoNovo = await showDialog<Endereco>(
      context: context,
      builder: (context) => const EnderecoCadastro(),
    );

    if (enderecoNovo != null) {
      await carregarEnderecos();

      if (mounted) {
        setState(() {
          final selecionado = _listaEnderecos.firstWhere(
            (e) => e.id == enderecoNovo.id,
            orElse: () => enderecoNovo,
          );
          if (isOrigem) {
            _origemController = selecionado;
          } else {
            _destinoController = selecionado;
          }
        });
      }
    }
  }

  void cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_origemController == null || _destinoController == null) {
      mostraSnackBar.show(
        context,
        'Selecione ou cadastre os endereços de origem e destino.',
        true,
      );
      return;
    }

    setState(() => isLoading = true);

    String resposta = await  '';
    bool cadastroFalhou = resposta != 'entrega cadastrada com sucesso!';

    if (mounted) {
      if (!cadastroFalhou) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/entrega',
          (route) => false,
        );
      }
      mostraSnackBar.show(context, resposta, cadastroFalhou);
      setState(() => isLoading = false);
    }
  }

  List<DropdownMenuItem<int?>> buildDropdownItems() {
    final List<DropdownMenuItem<int?>> lista = [];

    // Opção para cadastrar novo endereço
    lista.add(
      DropdownMenuItem<int?>(
        value: -1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Cadastrar novo endereço',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
          ],
        ),
      ),
    );

    for (var endereco in _listaEnderecos) {
      if (endereco.id != null) {
        lista.add(
          DropdownMenuItem<int?>(
            value: endereco.id,
            child: Text(
              '${endereco.logradouro}, ${endereco.numero}',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        );
      }
    }

    return lista;
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final primaryColor = tema.colorScheme.primary;

    final int? origemSegura =
        (_origemController?.id != null &&
            _listaEnderecos.any((e) => e.id == _origemController?.id))
        ? _origemController?.id
        : null;

    final int? destinoSeguro =
        (_destinoController?.id != null &&
            _listaEnderecos.any((e) => e.id == _destinoController?.id))
        ? _destinoController?.id
        : null;

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
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.local_shipping_outlined,
                  size: 60,
                  color: primaryColor,
                ),
                const SizedBox(height: 10),
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
                const SizedBox(height: 15),

                Card(
                  color: tema.colorScheme.onSecondary,
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Nome/Descrição do item
                        TextFormField(
                          controller: _nomeController,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            labelText: 'Descrição do Pacote/Item',
                            prefixIcon: Icon(Icons.inventory_2_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe a descrição da entrega';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Largura, Altura e Peso lado a lado
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
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Dropdown Origem
                        DropdownButtonFormField<int?>(
                          key: ValueKey('origem_$origemSegura'),
                          value: origemSegura,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Endereço de Origem',
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                          hint: const Text('Selecione a origem'),
                          items: buildDropdownItems(),
                          onChanged: (int? novoValor) {
                            if (novoValor == -1) {
                              abrirCadastroEndereco(true);
                            } else if (novoValor != null) {
                              setState(() {
                                _origemController = _listaEnderecos.firstWhere(
                                  (e) => e.id == novoValor,
                                );
                              });
                            }
                          },
                          validator: (value) {
                            if (_origemController == null) {
                              return 'Selecione a origem';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Dropdown Destino
                        DropdownButtonFormField<int?>(
                          key: ValueKey('destino_$destinoSeguro'),
                          value: destinoSeguro,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Endereço de Destino',
                            prefixIcon: Icon(Icons.flag_outlined),
                          ),
                          hint: const Text('Selecione o destino'),
                          items: buildDropdownItems(),
                          onChanged: (int? novoValor) {
                            if (novoValor == -1) {
                              abrirCadastroEndereco(false);
                            } else if (novoValor != null) {
                              setState(() {
                                _destinoController = _listaEnderecos.firstWhere(
                                  (e) => e.id == novoValor,
                                );
                              });
                            }
                          },
                          validator: (value) {
                            if (_destinoController == null) {
                              return 'Selecione o destino';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : cadastrar,
                    child: isLoading
                        ? AnimacaoCarregando()
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
    );
  }
}
