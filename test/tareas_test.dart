import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_tareas_local/data/database.dart';
import 'package:gestor_tareas_local/data/validacion.dart';

void main() {
  group('validación', () {
    test('rechaza vacío y solo espacios', () {
      expect(validarTitulo(''), isNotNull);
      expect(validarTitulo('   '), isNotNull);
      expect(validarTitulo(null), isNotNull);
    });
    test('acepta un título normal', () {
      expect(validarTitulo('Estudiar Drift'), isNull);
    });
  });

  group('almacenamiento', () {
    late AppDatabase db;
    setUp(() => db = AppDatabase(NativeDatabase.memory()));
    tearDown(() => db.close());

    test('agregar y listar', () async {
      await db.agregar('  Tarea 1  ');
      final lista = await db.listar();
      expect(lista.single.titulo, 'Tarea 1');
      expect(lista.single.completada, isFalse);
    });

    test('no guarda títulos vacíos', () async {
      expect(() => db.agregar('   '), throwsFormatException);
      expect(await db.listar(), isEmpty);
    });

    test('editar, cambiar estado y eliminar', () async {
      final id = await db.agregar('A');
      await db.editarTitulo(id, 'B');
      await db.cambiarEstado(id, true);
      final t = (await db.listar()).single;
      expect([t.titulo, t.completada], ['B', true]);
      await db.eliminar(id);
      expect(await db.listar(), isEmpty);
    });
  });

  test('los datos sobreviven al cerrar y reabrir el archivo', () async {
    final dir = await Directory.systemTemp.createTemp('tareas_test');
    final archivo = File('${dir.path}/t.sqlite');
    var db = AppDatabase(NativeDatabase(archivo));
    await db.agregar('Persistente');
    await db.close();
    db = AppDatabase(NativeDatabase(archivo));
    expect((await db.listar()).single.titulo, 'Persistente');
    await db.close();
    await dir.delete(recursive: true);
  });
}