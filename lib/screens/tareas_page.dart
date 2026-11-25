import 'package:flutter/material.dart';
import '../data/database.dart';

class TareasPage extends StatefulWidget {
  const TareasPage({super.key, required this.db});

  final AppDatabase db;

  @override
  State<TareasPage> createState() => _TareasPageState();
}

class _TareasPageState extends State<TareasPage> {
  final TextEditingController _tituloController = TextEditingController();

  List<Tarea> _tareas = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final lista = await widget.db.listar();
      if (!mounted) return;
      setState(() => _tareas = lista);
    } catch (e) {
      _pendiente('No se pudieron cargar las tareas: $e');
    }
  }

  // Ejecuta una escritura, recarga la lista y muestra errores comprensibles
  Future<void> _ejecutar(Future<void> Function() accion) async {
    try {
      await accion();
      await _cargar();
    } on FormatException catch (e) {
      _pendiente(e.message);
    } catch (e) {
      _pendiente('Error de almacenamiento: $e');
    }
  }

  void _agregarTarea() => _ejecutar(() async {
        await widget.db.agregar(_tituloController.text);
        _tituloController.clear();
      });

  void _alternarCompletada(Tarea tarea, bool completada) =>
      _ejecutar(() => widget.db.cambiarEstado(tarea.id, completada));

  Future<void> _editarTarea(Tarea tarea) async {
    var texto = tarea.titulo;
    final nuevo = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar título'),
        content: TextFormField(
          initialValue: tarea.titulo,
          autofocus: true,
          onChanged: (v) => texto = v,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, texto),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (nuevo != null) {
      await _ejecutar(() => widget.db.editarTitulo(tarea.id, nuevo));
    }
  }

  void _eliminarTarea(Tarea tarea) =>
      _ejecutar(() => widget.db.eliminar(tarea.id));

  void _pendiente(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestor de tareas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Nueva tarea',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _agregarTarea,
              icon: const Icon(Icons.add),
              label: const Text('Agregar tarea'),
            ),
            const SizedBox(height: 12),
            const Text('Mis tareas', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Expanded(
              child: _tareas.isEmpty
                  ? const Center(child: Text('Todavía no hay tareas guardadas'))
                  : ListView.builder(
                      itemCount: _tareas.length,
                      itemBuilder: (context, index) {
                        final tarea = _tareas[index];
                        return Card(
                          child: ListTile(
                            leading: Checkbox(
                              value: tarea.completada,
                              onChanged: (valor) {
                                if (valor != null) {
                                  _alternarCompletada(tarea, valor);
                                }
                              },
                            ),
                            title: Text(tarea.titulo),
                            subtitle: Text('ID: ${tarea.id}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Editar',
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editarTarea(tarea),
                                ),
                                IconButton(
                                  tooltip: 'Eliminar',
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _eliminarTarea(tarea),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}