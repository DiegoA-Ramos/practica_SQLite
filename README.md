# Gestor de tareas local (Flutter + SQLite)

Práctica de Programación de Dispositivos Móviles, 7.º semestre, Ingeniería en Sistemas Computacionales, UAA.

Aplicación Flutter para administrar tareas (agregar, consultar, editar el título, marcar como completada y eliminar) con **persistencia local en SQLite**, sin servidor, sin MySQL y sin conexión a internet.

**Autor:** Ramos Vazquez Diego Alejandro

## Estado del proyecto

| Etapa | Descripción | Estado |
|---|---|---|
| 1 | Preparación y diseño de la tabla |  Hecha |
| 2 | Persistencia real: crear y consultar |  Pendiente |
| 3 | Editar, cambiar estado, eliminar y validar |  Pendiente |
| 4 | Web, pruebas automatizadas y documentación |  Pendiente |

> Este README se irá actualizando con cada etapa.

## Tecnología de persistencia elegida

**Drift + drift_flutter** (sobre SQLite).

### Por qué Drift

- **Una sola base de código para todas las plataformas.** `drift_flutter` abre la base correcta según el entorno: SQLite nativo en Android, iOS, Windows, Linux y macOS, y SQLite compilado a WebAssembly en el navegador.
- **Es SQLite real.** Cumple el requisito de la práctica: no es una lista en memoria, ni JSON en `shared_preferences`, ni una API REST.
- **Tablas definidas en Dart.** Drift genera con `build_runner` el código de las consultas y la clase de datos, lo que reduce errores por escribir SQL a mano.
- **Consultas asíncronas** (`Future`), que no bloquean la interfaz.
- **Se puede probar con una base en memoria**, lo que facilita las pruebas automatizadas.

### Alternativa descartada

`sqflite` es la opción clásica de la documentación de Flutter, pero no cubre escritorio ni web de forma oficial. Para usar un mismo proyecto en los tres entornos pedidos (móvil, escritorio y web) es más adecuado Drift.

## Diseño de la tabla

Tabla `tareas`:

| Columna | Tipo en Dart (Drift) | Tipo en SQLite | Restricciones |
|---|---|---|---|
| `id` | `integer()` | `INTEGER` | Clave primaria, autoincremental |
| `titulo` | `text()` | `TEXT` | Obligatorio; se rechaza vacío o solo espacios |
| `completada` | `boolean()` | `INTEGER` (0 o 1) | Valor por defecto `false` |

SQLite no tiene un tipo booleano propio: Drift guarda `false` como `0` y `true` como `1`.

### Cómo se identifica cada registro

Cada tarea se identifica por su **`id`**: un entero único que SQLite asigna automáticamente al insertar. Las operaciones de edición, cambio de estado y eliminación usan ese `id` en la cláusula `WHERE`, de modo que afectan solo a una tarea aunque haya títulos repetidos.

### Correspondencia con SQL

| Operación | SQL | Pantalla |
|---|---|---|
| Alta | `INSERT` | Botón "Agregar tarea" |
| Consulta | `SELECT` | Lista "Mis tareas" |
| Edición y estado | `UPDATE` | Ícono de editar y casilla |
| Eliminación | `DELETE` | Ícono de eliminar |

## Estructura prevista

```
lib/
├── main.dart               # Arranque de la app y tema
├── data/
│   ├── database.dart       # Tabla, apertura de la base y operaciones CRUD (Drift)
│   ├── database.g.dart     # Código generado por build_runner
│   └── validacion.dart     # Reglas de validación del título
└── screens/
    └── tareas_page.dart    # Interfaz; no contiene consultas dentro de build()
test/
├── widget_test.dart        # La pantalla inicial se muestra sin errores
└── tareas_test.dart        # Validación y operaciones de almacenamiento
web/
├── sqlite3.wasm            # Motor SQLite para el navegador
└── drift_worker.dart.js    # Worker de Drift para la web
```

## Requisitos

- [Flutter](https://docs.flutter.dev/get-started/install) instalado y verificado con `flutter doctor -v`.
- Para ejecutar en una plataforma nativa: Android Studio o emulador (Android), Windows, Linux o macOS con su toolchain correspondiente. iOS y macOS solo se compilan en macOS con Xcode.
- Navegador Chrome para la versión web.

## Cómo ejecutar el proyecto

```bash
git clone ------url
cd gestor_tareas_local
flutter pub get
flutter analyze
flutter test
```

Ejecución según el entorno (los identificadores salen de `flutter devices`):

```bash
# Escritorio
flutter run -d windows     # o linux / macos

# Móvil
flutter run -d <id-del-emulador-o-dispositivo>

# Web (usar siempre el mismo puerto para conservar los datos)
flutter run -d chrome --web-port=8080
```

> **Nota sobre web:** el almacenamiento del navegador depende del origen (`localhost:8080`). Si cambia el puerto, parecerá que los datos desaparecieron. Tampoco persisten en modo incógnito.

## Plataformas

El código está diseñado para los tres entornos que pide la práctica: **móvil, escritorio y web**.

| Entorno | Plataforma probada | Resultado |
|---|---|---|
| Móvil | pendiente | pendiente|
| Escritorio | pendiente | pendiente |
| Web | pendiente | pendiente |

Las plataformas que no se prueben se indicarán aquí como "solo previstas".

## Pruebas manuales (P1 a P6)

| ID | Acción | Resultado esperado | Resultado obtenido |
|---|---|---|---|
| P1 | Agregar tres tareas, cerrar la app por completo y abrirla | Permanecen las tres | pendiente |
| P2 | Marcar una como completada y reiniciar | Se conserva el estado | pendiente |
| P3 | Cambiar el título de una tarea y reiniciar | Aparece el nuevo título | pendiente |
| P4 | Eliminar una tarea y reiniciar | No reaparece | pendiente |
| P5 | Intentar agregar un título vacío | No se registra | pendiente |
| P6 | En el navegador, recargar y cerrar/abrir la pestaña | Los datos permanecen | pendiente |

## Decisiones de diseño

- **Capa de datos separada de la interfaz.** Las consultas viven en `lib/data/`; `build()` solo lee el estado ya cargado.
- **Se elimina `lib/models/tarea.dart`.** Drift genera su propia clase `Tarea` a partir de la tabla, y mantener las dos provocaría un conflicto de nombres.
- **Consultas con `Future`** y recarga de la lista después de cada escritura, por simplicidad.
- **Validación centralizada** en un solo archivo, usada por la capa de datos y probada de forma automática.

## Fuentes consultadas

- Documentación de Drift: https://drift.simonbinder.eu/
- Drift en web: https://drift.simonbinder.eu/platforms/web/
- Paquete drift_flutter: https://pub.dev/packages/drift_flutter
- Flutter, almacenamiento local con SQLite: https://docs.flutter.dev/cookbook/persistence/sqlite
- Flutter, pruebas: https://docs.flutter.dev/testing/overview