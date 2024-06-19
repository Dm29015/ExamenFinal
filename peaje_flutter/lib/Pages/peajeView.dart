import 'package:flutter/material.dart';
import 'package:peaje_flutter/Controller/peajeController.dart';
import 'package:peaje_flutter/Models/peajeModel.dart';
import 'package:peaje_flutter/Pages/peajeCreate.dart';
import '../Widgets/cardListarPeaje.dart';
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

  void showPeajeDetailModal(Peaje peaje) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(peaje.nombrePeaje),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("Placa: ${peaje.placa}"),
              Text("Categoría: ${peaje.idCategoriaTarifa}"),
              Text("Fecha: ${peaje.fechaRegistro}"),
               Text("Valor: ${peaje.valor.toStringAsFixed(2)}"),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cerrar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void editar(Peaje peaje) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditarPeaje(peaje: peaje)),
    );
    if (result == true) {
      _refreshRegistrosPeajes();
    }
  }
  
   void eliminar(Peaje peaje) {
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
                Navigator.of(context).pop();
                try {
                  await eliminarPeaje(peaje.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Peaje eliminado con éxito.'),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _refreshRegistrosPeajes();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error al eliminar el peaje.'),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
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
                      colorIcon: const Color.fromARGB(255, 252, 232, 54),
                      placa: peaje.placa,
                      peaje: peaje.nombrePeaje,
                       onEditPressed: () {
                        editar(peaje);
                      },
                      onDeletePressed: () {
                        eliminar(peaje);
                      }
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
          final route = MaterialPageRoute(builder: (context) => const RegistrarPeaje());
          bool result = await Navigator.push(context, route);
          if (result == true) {
            _refreshRegistrosPeajes();
          }
        },
        backgroundColor:const Color.fromARGB(255, 206, 215, 250),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );

  }
}

