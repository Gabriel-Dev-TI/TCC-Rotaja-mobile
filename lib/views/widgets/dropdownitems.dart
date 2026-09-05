import 'package:flutter/material.dart';
import 'package:rotaja/controller/enderecoController.dart';
import 'package:rotaja/model/endereco.dart';
import 'package:rotaja/views/cadastros/enderecoCadastro.dart';

class DropDownEndereco extends StatefulWidget {
  final Endereco? enderecoSelecionado;
  final String label;
  final Widget icon;
  final ValueChanged<Endereco?> onChanged;
  final bool salvarNaApi;

  const DropDownEndereco({
    super.key,
    required this.enderecoSelecionado,
    required this.label,
    required this.icon,
    required this.onChanged,
    this.salvarNaApi = true,
  });

  @override
  State<DropDownEndereco> createState() => _DropDownEnderecoState();
}

class _DropDownEnderecoState extends State<DropDownEndereco> {
  List<Endereco> _listaEnderecos = [];

  @override
  void initState() {
    super.initState();
    carregarEnderecos();
  }

  Future<void> carregarEnderecos() async {
    final enderecos = await listarSharedPreferences();
    if (mounted) {
      setState(() => _listaEnderecos = enderecos);
    }
  }

  Future<void> abrirCadastroEndereco() async {
    final Endereco? enderecoNovo = await showDialog<Endereco>(
      context: context,
      builder: (context) => EnderecoCadastro(salvarNaApi: widget.salvarNaApi),
    );

    if (enderecoNovo != null) {
      if (widget.salvarNaApi) {
        await carregarEnderecos();
      } else {
        setState(() => _listaEnderecos.add(enderecoNovo));
      }
      
      if (mounted) {
        widget.onChanged(enderecoNovo);
      }
    }
  }

  List<DropdownMenuItem<dynamic>> _gerarItemsDropdown(List<Endereco> listaLimpa) {
    final List<DropdownMenuItem<dynamic>> items = [
      DropdownMenuItem<dynamic>(
        value: 'CADASTRAR',
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Cadastrar endereço',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
            Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
          ],
        ),
      ),
    ];

    for (var endereco in listaLimpa) {
      items.add(
        DropdownMenuItem<dynamic>(
          value: endereco,
          child: Text(
            '${endereco.logradouro}, ${endereco.numero}',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    // Remove duplicidades criando uma lista limpa por comparação de campos
    final List<Endereco> listaLimpa = [];
    for (var item in _listaEnderecos) {
      bool jaExiste = listaLimpa.any((e) => e == item);
      if (!jaExiste) {
        listaLimpa.add(item);
      }
    }

    // Garante que selectedValue seja a MESMA instância presente na listaLimpa
    Endereco? selectedValue;
    if (widget.enderecoSelecionado != null && listaLimpa.isNotEmpty) {
      try {
        selectedValue = listaLimpa.firstWhere(
          (e) => e == widget.enderecoSelecionado,
        );
      } catch (_) {
        // Se não achar exact match, adiciona a referência na lista limpa para não quebrar a assertion
        listaLimpa.add(widget.enderecoSelecionado!);
        selectedValue = widget.enderecoSelecionado;
      }
    }

    return DropdownButtonFormField<dynamic>(
      initialValue: selectedValue,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Endereço ${widget.label}',
        prefixIcon: widget.icon,
      ),
      hint: Text(
        'Cadastre um endereço',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      items: _gerarItemsDropdown(listaLimpa),
      onChanged: (dynamic novoValor) {
        if (novoValor == 'CADASTRAR') {
          abrirCadastroEndereco();
        } else if (novoValor is Endereco) {
          widget.onChanged(novoValor);
        }
      },
      validator: (value) {
        if (widget.enderecoSelecionado == null) {
          return 'Selecione ou cadastre um endereço';
        }
        return null;
      },
    );
  }
}