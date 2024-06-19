import 'package:flutter/material.dart';
import 'package:peaje_app/models/peaje.dart';
import 'package:peaje_app/models/peaje_api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class PeajeScreen extends StatefulWidget {
  const PeajeScreen({super.key});

  @override
  _PeajeScreenState createState() => _PeajeScreenState();
}

class _PeajeScreenState extends State<PeajeScreen> {
  final PeajeApi api = PeajeApi(baseUrl: 'TU_BASE_URL');
  late Future<List<Peaje>> futurePeajes;

  @override
  void initState() {
    super.initState();
    futurePeajes = api.getPeajes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Peajes'),
      ),
      body: FutureBuilder<List<Peaje>>(
        future: futurePeajes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final peajes = snapshot.data ?? [];

          return ListView.builder(
            itemCount: peajes.length,
            itemBuilder: (context, index) {
              final peaje = peajes[index];

              return ListTile(
                title: Text(peaje.peaje),
                subtitle: Text('${peaje.placa} - ${peaje.tarifa} - ${peaje.fecha} - ${peaje.precio}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => PeajeForm(
                            peaje: peaje,
                            onSave: (updatedPeaje) {
                              setState(() {
                                futurePeajes = api.getPeajes();
                              });
                            },
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        bool confirm = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmar eliminación'),
                            content: const Text('¿Estás seguro de eliminar este registro?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        );

                        if (confirm) {
                          await api.deletePeaje(peaje.id);
                          setState(() {
                            futurePeajes = api.getPeajes();
                          });
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => PeajeForm(
              onSave: (newPeaje) {
                setState(() {
                  futurePeajes = api.getPeajes();
                });
              },
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PeajeForm extends StatefulWidget {
  final Peaje? peaje;
  final Function(Peaje) onSave;

  const PeajeForm({super.key, this.peaje, required this.onSave});

  @override
  _PeajeFormState createState() => _PeajeFormState();
}

class _PeajeFormState extends State<PeajeForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _placaController;
  late TextEditingController _valorController;
  String? _selectedPeaje;
  String? _selectedTarifa;
  DateTime? _selectedDate;
  final PeajeApi api = PeajeApi(baseUrl: 'TU_BASE_URL');

  @override
  void initState() {
    super.initState();

    _placaController = TextEditingController(text: widget.peaje?.placa ?? '');
    _valorController = TextEditingController(text: widget.peaje?.precio.toString() ?? '');
    _selectedPeaje = widget.peaje?.peaje;
    _selectedTarifa = widget.peaje?.tarifa;
    _selectedDate = widget.peaje != null ? DateTime.parse(widget.peaje!.fecha) : null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.peaje == null ? 'Nuevo Peaje' : 'Editar Peaje'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _placaController,
                decoration: const InputDecoration(labelText: 'Placa'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obligatorio';
                  }
                  final regExp = RegExp(r'^[A-Z]{3}\d{3}$');
                  if (!regExp.hasMatch(value)) {
                    return 'Formato inválido';
                  }
                  return null;
                },
              ),
              FutureBuilder<List<dynamic>>(
                future: fetchPeajesExternos(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  final peajesExternos = snapshot.data ?? [];

                  return DropdownButtonFormField<String>(
                    value: _selectedPeaje,
                    decoration: const InputDecoration(labelText: 'Nombre del Peaje'),
                    items: peajesExternos.map((peaje) {
                      return DropdownMenuItem<String>(
                        value: peaje['nombre_peaje'],
                        child: Text(peaje['nombre_peaje']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPeaje = value;
                        if (_selectedTarifa != null) {
                          _valorController.text = getPeajeValue(peajesExternos, value, _selectedTarifa!).toString();
                        }
                      });
                    },
                    validator: (value) => value == null ? 'Campo obligatorio' : null,
                  );
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedTarifa,
                decoration: const InputDecoration(labelText: 'Categoría de Tarifa'),
                items: ['I', 'II', 'III', 'IV', 'V'].map((tarifa) {
                  return DropdownMenuItem<String>(
                    value: tarifa,
                    child: Text(tarifa),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTarifa = value;
                    if (_selectedPeaje != null) {
                      _valorController.text = getPeajeValue(peajesExternos, value, _selectedPeaje!).toString();
                    }
                  });
                },
                validator: (value) => value == null ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: _valorController,
                decoration: const InputDecoration(labelText: 'Valor'),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obligatorio';
                  }
                  if (double.tryParse(value) == null || double.parse(value) < 0) {
                    return 'Valor inválido';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Fecha de Registro'),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );

                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                    });
                  }
                },
                readOnly: true,
                controller: TextEditingController(
                  text: _selectedDate != null ? _selectedDate!.toLocal().toString().split(' ')[0] : '',
                ),
                validator: (value) => value == null || value.isEmpty ? 'Campo obligatorio' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final newPeaje = Peaje(
                id: widget.peaje?.id ?? 0,
                peaje: _selectedPeaje!,
                placa: _placaController.text,
                tarifa: _selectedTarifa!,
                fecha: _selectedDate!.toLocal().toString().split(' ')[0],
                precio: double.parse(_valorController.text),
              );

              if (widget.peaje == null) {
                await api.createPeaje(newPeaje);
              } else {
                await api.updatePeaje(newPeaje);
              }

              widget.onSave(newPeaje);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  Future<List<dynamic>> fetchPeajesExternos() async {
    final response = await http.get(Uri.parse('https://www.datos.gov.co/resource/7gj8-j6i3.json'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load peajes externos');
    }
  }

  double 
  getPeajeValue(List peajesExternos, String? peaje, String tarifa) {
    for (var p in peajesExternos) {
      if (p['nombre_peaje'] == peaje && p['categoria'] == tarifa) {
        return double.parse(p['valor']);
      }
    }
    return 0;
  }
}
