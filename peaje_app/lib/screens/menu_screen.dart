import 'package:flutter/material.dart';
import 'package:peaje_app/screens/peaje_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú Principal'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.network('URL_DE_LA_IMAGEN_ALUSIVA'), // Coloca una URL válida
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PeajeScreen()),
                );
              },
              child: const Text('Gestionar Peajes'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomAppBar(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Nombre Completo - Número de Celular', textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
