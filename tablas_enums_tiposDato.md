# TABLAS
## Elementos fundamentales de las tablas
- Propiedades
- Campos
    - Propiedades
    - *Triggers*
- Claves primarias y secundarias
- *Triggers*

## Tipos de tabla
1. Campos y estructura modificables (tabla de datos maestros)(usan pages de tipo card).
2. Estructura bloqueada, pero campos modificables.
3. Tablas que no se puede modificar nada (solo de lectura).

Tablas de asientos contables (1, 2, 3, 4, 5, 6, 7) donde la 6 es gastos y 7 ingresos. (asiento contable = movimiento). Cada asiento es el conjunto de apuntes o líneas.

Tablas subsidiarias (tiene ID y otro campo, que acompañan a la información de otras tablas).

> Un registro de una tabla puede tener hasta 500 campos (8.000 bytes).

> Puede haber hasta 40 claves en una tabla.

> Business Central reserva los IDs del 0 al 49.999, del 50.000 al 99.999...

> El código contenido en cada *trigger* se ejecuta antes de ejecutar el evento correspondiente.

## Propiedades de la tabla
*NOTA: Las propiedades con asterisco (`*`) son las más habituales*.
| Propiedad | Significado |
| -- | -- |
| *`Caption` | título de la tabla en función del idioma seleccionado|
| *`CaptionML` | título de la tabla para un multilenguaje|
| *`Description` | descripción de la tabla |
| *`Permissions` | permite dotar de permisos al usuario para el `CRUD` de la tabla y de su estructura |
| *`LookupPageId` | página determinada para buscar datos de la tabla |
| *`DrillDownPageId` | página para ver detalles o resumen de datos de la tabla |
| *`DataCaptionFields` | permite definir los campos que se muestran como título |
| `PasteIsValid` | permite o no pegar datos en los campos |
| `LinkedObject` | permite que un objeto externo se conecte |
| `TableType` | captura datos de un objeto externo (*p.ej.* tabla de MongoDB) |
| `ObsoleteState` | indica que la tabla se eliminará en una versión futura |
| `ObsoleteReason` | se indica el motivo por el cual se elimina y/o se indica la versión por la cual se va a reemplazar |

# CLAVES PRIMARIAS Y SECUNDARIAS
Las claves primarias se utilizan para identificar registros en la tabla, por eso no puede haber repetidas; para acelerar la clasificación y filtrado.

Plantilla para una clave (donde pone `PK`, se escribe la clave primaria. Todo lo que vaya después, son secundarias). Puede haber varias claves primarias, pero, al menos, debe haber una.
``` al
keys
{
    key(PK; "<Campo1>", "<Campo2>", "<CampoN>") { }
    key(<TipoClave>; "<Campo>") { }
}
```
Poner `Clustered = true` entre los corchetes de la PK es insignificante porque es el valor por defecto.


Propiedades de las `key` (dentro de las llaves de `key`):
| Propiedad | Significado |
| -- | -- |
| `MaintainSiftIndex` | campos de índice suma (actualiza todos los saldos, índices, etc. en cada inserción), es decir, permiten mantener la tecnología `SUMINDEXFIELDS` |
| `MaintainSqlIndex` | determina si el índice se debe crear en la base de datos SQL (`true`) o si solo existe virtualmente en Business Central (`false`) para ahorrar recursos en escritura |
| `Autoincrement` | indica si el ID aumenta automáticamente con cada registro (`true` o `false`) |
| `Unique` | indica si la clave secundaria debe contener valores únicos |


# TIPOS DE DATO
| Tipo de dato | Ejemplo |
| -- | -- |
| Fundamental | Texto, fecha, número, horas, tablas, etc. (un único valor) |
| Complejo | Objetos, documentos, imágenes, etc. |

## Fundamentales
- ***Numéricos***
  - *Integer*: desde -2.147.483.648 hasta 2.147.483.647
  - *Decimal*: desde -999.999.999.999.999,99 ...
  - *Option*: desde 0 hasta 2.147.483.646
  - *OptionMembers*: conjunto de opciones enumeradas en una cadena separadas por comas (`,`)
  - *Boolean*: 0/1
  - *Biginteger*: entero de 8 bytes
  - *Char*: hexadecimal entre 0000 y FFFF
  - *Byte*: 8 bits entre 0 y 255
  - *Action*: 
  - *Executionmode*: debug/standard
- ***Cadena***
  - *Texto*: hasta 250 caracteres alfanuméricos.
  - *Code*: entre 1 y 250 caracteres. Las letras siempre se almacenan en mayúsculas y sin espacios.
  - *Textbuilder*: permite la manipulación de cadenas como `Append`, `Replace` y `Length`.
- ***Fecha y hora***
  - *Date*: contiene un número entero que se interpreta como una fecha (número de días desde el 01/01/1574 hasta la fecha máxima 31/12/9999).
    - Se puede escribir como `MMDDAAAA` (*p.ej.* 11182025) o como `MMDDAA` (*p.ej.* 111824D, donde `D` significa  fecha).
  - *Time*: contiene un número que representa un reloj de 24h en milisegundos (va desde `00:00:00:0000` hasta `23:59:59:9999`).
  - *DateTime*: representa el día y la hora combinadas en tiempo UTC (va desde `01/01/1574 00:00:00:0000` hasta `31/12/9999 23:59:59:9999`).
  - *Duration*: representa la diferencia entre dos `DateTime`.

## Complejos
- ***Objetos de BC***
  - `Page`.
  - `Report`.
  - `Codeunit`.
  - `XmlPort` (carga masiva de datos).
  - `TableExtension`.
- ***Entrada y salida***
  - `dialog`: ventana en la interfaz de usuario.
- ***Fórmulas de fecha***
  - *DateFormula*: sirve para calcular fechas sensibles al tiempo.
  - Admite:
    - Multiplicadores numéricos (1, 2, 3, etc.).
    - Unidades de tiempo
      - `D (day)` &rarr; día.
      - `W (week)` &rarr; semana.
      - `WD (week day)` &rarr; día de la semana en número, siendo lunes el 1 y domingo el 7 (cuenta en la próxima semana).
      - `M (month)` &rarr; mes del calendario.
      - `Y (year)` &rarr; año del calendario.
      - `CM (current month)` &rarr; mes actual (último día del mes actual).
      - `CY (current year)` &rarr; año actual.
      - `CW (current week)` &rarr; semana actual.
      - Símbolos matemáticos (*p.ej* `CM + 10D` &rarr; fin de mes actual + 10 días).
      - Notación posicional:
        - `D15` &rarr; día 15 del mes actual.
        - `15D` &rarr; 15 días para operar.

## Tipo `Blob`
| Propiedad | Definición |
| -- | -- |
| `Subtype` | `BitMap`, `Memo`, `Json` y `UserDefined` |
| `Compressed` | comprime el campo |

- `Compressed` no se puede comprimir si se va a acceder desde una app externa o fuera de BC, aunque por defecto está en `Compressed = true;`

## Tipo `Code` y `Text`
| Propiedad | Definición |
| -- | -- |
| `InitValue` | valor predeterminado o inicial |
| `CaptionClass` | título dinámico (el usuario puede modificarlo) |
| `Editable` | poder modificar el valor del campo |
| `NotBlank` | poder poner el valor del campo en blanco |
| `Numeric` | poder poner el valor del campo con valores numéricos |
| `CharAllowed` | poder poner el valor del campo con el rango de los caracteres indicado (*p.ej.* `AZ` coge el abecedario en mayúsculas, o `''` coge todo) |
| `DateFormula` | fórmula para fecha |
| `ValuesAllowed` | valores permitidos |
| `SQLDataType` | definir el tipo de campo con el que se guardará el campo en la base de datos |
| `TableRelation` | con qué tabla se relaciona el campo (se guarda la PK de la tabla relacionada) |
| `ValidateTableRelation` | confirmar que los datos existen en la otra tabla |
| `ExtendedDataType` | formatos y validaciones especiales (*p.ej.* correo electrónico, número de teléfono, URL, etc.) |

## Tipo `Integer` y `Decimal`
| Propiedad | Definición |
| -- | -- |
| `DecimalPlaces` | posiciones que admite en la parte decimal para guardado y visualización |
| `BlankNumbers` | mostrar o no los valores |
| `BlankZero` | mostrar o no los valores cero (`0`) |
| `SignDisplacement` | coloca el signo negativo antes o después del valor |
| `MaxValue` | valor máximo que permite el campo |
| `MinValue` | valor mínimo que permite el campo |
| `AutoIncrement` | incrementar automáticamente el valor del campo (no garantiza secuencia numérica contigua) |

## Tipo `Option`
| Propiedad | Definición |
| -- | -- |
| `OptionMembers` | valores del campo (las opciones se almacenan como números indicando la posición del valor) |
| `OptionCaption` | título del `Option` |
| `OptionCaptionML` | título del `Option` con idioma especificado |

``` bash
field(<id>; <"Nombre Campo">; Option)
{
    OptionMembers = <Option1>,<Option2>,<OptionN>;
}
```


## Tipo `Enum`
El tipo `Enum` mantiene la función del `Option`, pero aporta un mayor nivel de detalle y mejores capacidades de gestión.

El esqueleto del `enum` es:
``` bash
enum <id> "<nombre_enum>"
{
    value(<posicion>, "<valor>") { }
    value(<posicion>, "<valor>") { }
    value(<posicion>, "<valor>") { }
}
```

Para llevar el `enum` a un campo en una tabla, se pone el campo con el tipo de dato `Enum "<nombre_enum>"`


# RELACIÓN DE TABLAS (`TABLERELATION`)
Esta propiedad se define a nivel de **campo dentro de una tabla**. Su función es vincular el campo actual con otra tabla (integridad referencial), asegurando que el dato introducido exista realmente en la tabla de origen.

Al configurar esto, Business Central genera automáticamente el icono de "lupa" o desplegable en las páginas para seleccionar el registro.

``` bash
field(<idCampo>; "<NombreCampo>"; <TipoDato>)
{
TableRelation = "<NombreTablaOrigen>";
}
```

Puede tener una relación condicional:
``` bash
field(<idCampo>; "<NombreCampo>"; <TipoDato>)
{
    TableRelation = if ("<NombreCampo1>" = const(<opt1>)) <opt1>.<PK>
    else
    if ("<NombreCampo2>" = const(<opt2>)) <opt2>.<PK>
    else
    if ("<NombreCampo3>" = const(<optN>)) <optN>.<PK>;
}
```