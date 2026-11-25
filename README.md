# Gestor de tareas local (Flutter + SQLite)

Práctica de Programación de Dispositivos Móviles, 7.º semestre, UAA.
Autor: Ramos Vazquez Diego Alejandro

App en Flutter para agregar, listar, editar, completar y eliminar tareas, guardadas en SQLite local (sin servidor ni internet).

## Estado

| Etapa | Descripción | Estado |
|---|---|---|
| 1 | Preparación y diseño de la tabla | Hecha |
| 2 | Crear y consultar con persistencia real | Hecha |
| 3 | Editar, cambiar estado, eliminar y validar | Pendiente |
| 4 | Web, pruebas y documentación | Pendiente |

## Persistencia: Drift + drift_flutter

Uso Drift sobre SQLite porque con un solo código abre la base en móvil, escritorio y web (en web usa SQLite compilado a WebAssembly). La alternativa más conocida, `sqflite`, no cubre escritorio ni web de forma oficial. Drift genera el código de las consultas con `build_runner` y permite probar con una base en memoria.

## Tabla `tareas`

| Columna | Tipo | Notas |
|---|---|---|
| `id` | INTEGER | Clave primaria autoincremental |
| `titulo` | TEXT | Obligatorio, no vacío ni solo espacios |
| `completada` | INTEGER (0/1) | Por defecto `false` (SQLite no tiene booleano) |

Cada tarea se identifica por su `id`. Editar, completar y eliminar usan ese `id` en el `WHERE`, así que solo afectan a una tarea aunque haya títulos repetidos.

## Estructura

```
lib/
├── main.dart
├── data/
│   ├── database.dart      # tabla, apertura de la base y CRUD
│   ├── database.g.dart    # generado por build_runner
│   └── validacion.dart    # validación del título
└── screens/tareas_page.dart
test/
├── widget_test.dart
└── tareas_test.dart
web/                       # sqlite3.wasm y drift_worker.dart.js
```

## Cómo ejecutar

```bash
git clone https://github.com/DiegoA-Ramos/practica_SQLite.git
cd practica_SQLite
flutter pub get
flutter analyze
flutter test
```

```bash
flutter run -d windows                    # escritorio (o linux / macos)
flutter run -d <id del emulador>          # móvil, ver flutter devices
flutter run -d edge --web-port=8080       # web
```

En web los datos dependen del origen (`localhost:8080`): si cambia el puerto parece que se pierden, y en modo incógnito no persisten.

## Plataformas probadas

| Entorno | Plataforma | Resultado |
|---|---|---|
| Móvil | pendiente | pendiente |
| Escritorio | Windows 11 | Funciona, los datos persisten al cerrar y abrir |
| Web | pendiente | pendiente |

Lo que no pruebe lo marcaré como "solo previsto".

## Pruebas manuales

| ID | Acción | Esperado | Obtenido |
|---|---|---|---|
| P1 | Agregar 3 tareas, cerrar la app y abrirla | Permanecen las 3 | Permanecen las 3 (Windows) |
| P2 | Completar una y reiniciar | Se conserva el estado | pendiente |
| P3 | Cambiar un título y reiniciar | Aparece el nuevo | pendiente |
| P4 | Eliminar una y reiniciar | No reaparece | pendiente |
| P5 | Agregar título vacío | No se registra | pendiente |
| P6 | Web: recargar y cerrar/abrir pestaña | Los datos permanecen | pendiente |

## Decisiones

- Las consultas están en `lib/data/`; `build()` solo muestra la lista ya cargada.
- Quito `lib/models/tarea.dart` porque Drift genera su propia clase `Tarea` y chocarían.
- Uso `Future` y recargo la lista después de cada escritura, por simplicidad.

## Fuentes

- Drift: https://drift.simonbinder.eu/
- Drift en web: https://drift.simonbinder.eu/platforms/web/
- drift_flutter: https://pub.dev/packages/drift_flutter
- Flutter y SQLite: https://docs.flutter.dev/cookbook/persistence/sqlite
- Pruebas en Flutter: https://docs.flutter.dev/testing/overview