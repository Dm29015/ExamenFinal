import 'package:flutter/material.dart';
import 'package:peaje_flutter/Controller/peajeController.dart';
import 'package:peaje_flutter/Models/peajeModel.dart';
import 'package:peaje_flutter/Pages/peajeCreate.dart';
import '../Widgets/cardListarPeaje.dart';
import '../Widgets/infoPeaje.dart';
import 'peajeEdit.dart';

class PeajePage extends StatefulWidget {
  const PeajePage({super.key});

  @override
  State<PeajePage> createState() => _PeajeState();
}

class _PeajeState extends State<PeajePage> {
  late Future<List<Peaje>> _futurePeajes;

  @override
  void initState() {
    super.initState();
    _refreshRegistrosPeajes();
  }

  void _refreshRegistrosPeajes() {
    setState(() {
      _futurePeajes = fetchRegistrosPeajes();
    });
  }

  void editar(Peaje peaje) async {
    final route =
        MaterialPageRoute(builder: (context) => EditarPeaje(peaje: peaje));
    await Navigator.push(context, route);
    _refreshRegistrosPeajes();
  }

  void eliminar(Peaje peaje) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmación"),
          content: const Text("¿Está seguro que desea eliminar este peaje?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Eliminar"),
              onPressed: () async {
                try {
                  await eliminarPeaje(peaje.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Peaje eliminado con éxito.'),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.of(context).pop();
                  _refreshRegistrosPeajes(); // Aquí vuelves a cargar la lista después de eliminar
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error al eliminar el peaje.'),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.red,
                    ),
                  );
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void showPeajeDetailModal(Peaje peaje) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text(peaje.placa, style: const TextStyle(color: Colors.white))),
          backgroundColor: const Color.fromRGBO(26, 46, 79, 1),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                InfoRow(campo: 'PEAJE', valor: peaje.nombrePeaje),
                InfoRow(campo: 'TIPO TARIFA', valor: peaje.idCategoriaTarifa),
                InfoRow(campo: 'FECHA', valor: peaje.fechaRegistro),
                InfoRow(campo: 'VALOR', valor: peaje.valor.toString())
              ],
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton(
                child: const Text("Cerrar", style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(26, 46, 79, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(26, 46, 79, 1),
        iconTheme:
            const IconThemeData(color: Color.fromARGB(255, 206, 215, 250)),
        title: const Text(
          'Peajes',
          style: TextStyle(
            color: Color.fromARGB(255, 206, 215, 250),
          ),
        ),
      ),
      body: FutureBuilder<List<Peaje>>(
        future: _futurePeajes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Registros no encontrados'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var peaje = snapshot.data![index];
                return GestureDetector(
                  onTap: () {
                    showPeajeDetailModal(peaje);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    child: CardWidget(
                      colorIcon: const Color.fromARGB(255, 206, 215, 250),
                      placa: peaje.placa,
                      peaje: peaje.nombrePeaje,
                      onEditPressed: () {
                        editar(peaje);
                        _refreshRegistrosPeajes();
                      },
                      onDeletePressed: () {
                        eliminar(peaje);
                        _refreshRegistrosPeajes();
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final route =
              MaterialPageRoute(builder: (context) => const RegistrarPeaje());
          await Navigator.push(context, route);
          _refreshRegistrosPeajes();
        },
        backgroundColor: const Color.fromARGB(255, 206, 215, 250),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
