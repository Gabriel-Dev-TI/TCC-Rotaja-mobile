import 'package:flutter/material.dart';
import 'package:rotaja/views/widgets/card_button.dart';

class Painel extends StatelessWidget {
  const Painel({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    
    return SingleChildScrollView( 
      child: Padding(
        padding: const EdgeInsets.all(20.0), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            Text('Olá, Empresa! 👋', style: tema.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'O que você precisa entregar hoje?',
              style: tema.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            CardButton(
              funcao: () => Navigator.pushNamed(context, "/entregaCadastro"),
              titulo: 'Nova Entrega',
              subtitulo: 'Solicitar um entregador',
              icone: Icon(Icons.add_location_alt_outlined), 
            ),

            const SizedBox(height: 32),

            Text(
              'Entregas recentes',
              style: tema.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: tema.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: tema.colorScheme.outline.withOpacity(0.2)),
              ),
              child: Center(
                child: Text(
                  'Nenhuma entrega recente',
                  style: tema.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}  