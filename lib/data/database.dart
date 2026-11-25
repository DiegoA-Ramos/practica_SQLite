import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'validacion.dart';

part 'database.g.dart';

class Tareas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get titulo => text()();
  BoolColumn get completada => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Tareas])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _abrir());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _abrir() => driftDatabase(
        name: 'gestor_tareas',
        web: DriftWebOptions(
          sqlite3Wasm: Uri.parse('sqlite3.wasm'),
          driftWorker: Uri.parse('drift_worker.js'),
        ),
      );

  String _validar(String titulo) {
    final error = validarTitulo(titulo);
    if (error != null) throw FormatException(error);
    return titulo.trim();
  }

  // SELECT
  Future<List<Tarea>> listar() =>
      (select(tareas)..orderBy([(t) => OrderingTerm.desc(t.id)])).get();

  // INSERT
  Future<int> agregar(String titulo) =>
      into(tareas).insert(TareasCompanion.insert(titulo: _validar(titulo)));

  // UPDATE título
  Future<bool> editarTitulo(int id, String titulo) async {
    final filas = await (update(tareas)..where((t) => t.id.equals(id)))
        .write(TareasCompanion(titulo: Value(_validar(titulo))));
    return filas > 0;
  }

  // UPDATE estado
  Future<void> cambiarEstado(int id, bool completada) =>
      (update(tareas)..where((t) => t.id.equals(id)))
          .write(TareasCompanion(completada: Value(completada)));

  // DELETE
  Future<int> eliminar(int id) =>
      (delete(tareas)..where((t) => t.id.equals(id))).go();
}