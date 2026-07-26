import 'package:flutter/material.dart';
import 'package:rotaja/controller/enderecoController.dart';
import 'package:rotaja/model/endereco.dart';
import 'package:rotaja/views/cadastros/enderecoCadastro.dart';

class DropDownEndereco extends StatefulWidget {
  final Endereco? enderecoSelecionado;
  final String label;
  final Widget icon;
  final ValueChanged<Endereco?> onChanged; // Callback para enviar o endereço selecionado para o pai

  const DropDownEndereco({
    super.key,
    required this.enderecoSelecionado,
    required this.label,
    required this.icon,
    required this.onChanged,
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
      builder: (context) => const EnderecoCadastro(),
    );

    if (enderecoNovo != null) {
      await carregarEnderecos();

      if (mounted) {
        widget.onChanged(enderecoNovo); // Notifica a tela pai
      }
    }
  }

  String enderecoToString(Endereco e) {
    return '${e.logradouro}_${e.numero}_${e.bairro}_${e.cep}';
  }

  List<DropdownMenuItem<String?>> listaDropdownItems() {
    final List<DropdownMenuItem<String?>> lista = [
      DropdownMenuItem<String?>(
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

    for (var endereco in _listaEnderecos) {
      lista.add(
        DropdownMenuItem<String?>(
          value: enderecoToString(endereco),
          child: Text(
            '${endereco.logradouro}, ${endereco.numero}',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return lista;
  }

  @override
  Widget build(BuildContext context) {
    final selectedValue = widget.enderecoSelecionado != null
        ? enderecoToString(widget.enderecoSelecionado!)
        : null;

    return DropdownButtonFormField<String?>(
      key: ValueKey(selectedValue ?? 'sem_endereco'),
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
      items: listaDropdownItems(),
      onChanged: (String? novoValor) {
        if (novoValor == 'CADASTRAR') {
          abrirCadastroEndereco();
        } else if (novoValor != null) {
          final enderecoEncontrado = _listaEnderecos.firstWhere(
            (e) => enderecoToString(e) == novoValor,
          );
          widget.onChanged(enderecoEncontrado); // Notifica a tela pai com o objeto selecionado
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