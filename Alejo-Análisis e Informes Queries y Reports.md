## 1. Queries

### 1.1 ¿Qué es un Query?

Imagina que en Business Central tienes una lista de socios abierta en pantalla. Puedes usar los filtros para ver solo los que quieras, e incluso añadir columnas con totales usando FlowFields. Eso está bien para el día a día.

Pero ahora imagina que necesitas saber: **¿cuántos días en total lleva prestando libros cada socio?** Para responder a eso, tendrías que mirar cada préstamo de cada socio, sumar los días uno a uno, y apuntarlo en algún sitio. Si tienes 500 socios y 3.000 préstamos, eso es inviable a mano.

Un **Query** es exactamente la herramienta que hace ese trabajo por ti: recorre los datos, los agrupa y calcula los totales de forma automática y muy eficiente. Y todo desde código AL, sin pantallas, sin botones, sin que el usuario tenga que hacer nada.

```al
// Un Query se declara así en AL.
// Fíjate que tiene su propia numeración de objeto, como una Tabla o una Página.

query 50100 "Mi Primera Query"
{
    Caption = 'Mi Primera Query';
    QueryType = Normal;

    elements
    {
        dataitem(Socio; Socio)  // "Lee la tabla Socio"
        {
            column(Num_Socio; "No.")    // "Quiero ver el campo No."
            {
                Caption = 'Número de Socio';
            }
            column(Nombre; Nombre)      // "Quiero ver el campo Nombre"
            {
                Caption = 'Nombre';
            }
        }
    }
}
```

> **En resumen:** un Query es como pedirle a Business Central que revise una o varias tablas y te traiga exactamente la información que necesitas, ya resumida y calculada.

---

### 1.2 ¿Por qué usar un Query en lugar de una Page?

Una **Page** está pensada para que el usuario interactúe: ver, editar, crear o borrar registros. Cuando una Page carga, trae los datos poco a poco según el usuario hace scroll, y cada vez que actualiza un campo hace una petición al servidor.

Un **Query** no tiene pantalla ni botones. Solo lee datos. Y precisamente porque no tiene que preocuparse de nada más, lo hace de golpe, en una sola operación, de forma mucho más rápida.

| Situación | Usa esto |
|---|---|
| El usuario necesita ver y editar registros | `Page` |
| Necesitas calcular totales o agrupar datos | `Query` |
| Quieres datos para un proceso en segundo plano | `Query` |
| Necesitas mostrar un listado con filtros al usuario | `Page` |
| Quieres saber cuántos préstamos tiene cada socio | `Query` |

Piénsalo así: una **Page** es como una ventanilla de atención al cliente. Un **Query** es como el empleado del almacén que va, cuenta todo el stock y te trae el número exacto sin interrupciones.

---

### 1.3 Calcular totales y agrupaciones con un Query

La clave de un Query está en una propiedad llamada **`Method`**. Cuando la pones en una columna numérica, le estás diciendo a BC: *"no me traigas cada valor por separado, súmalos todos y dame solo el total"*.

Los métodos disponibles son:

| Method | Qué hace |
|---|---|
| `Method = Sum` | Suma todos los valores de esa columna |
| `Method = Count` | Cuenta cuántas filas hay |
| `Method = Average` | Calcula la media de los valores |
| `Method = Min` | Devuelve el valor más pequeño |
| `Method = Max` | Devuelve el valor más grande |

Cuando usas `Method` en una columna, el Query agrupa automáticamente el resultado por todas las demás columnas. Es decir: si tienes `Nombre del Socio` y `Total Días`, el resultado será una fila por socio con sus días sumados. BC hace todo eso solo.

---

### 1.4 Ejemplo completo: sumar los días totales de préstamo por socio

```al
query 50101 "Dias Totales Prestamo por Socio"
{
    Caption = 'Días Totales de Préstamo por Socio';
    QueryType = Normal;

    elements
    {
        dataitem(Socio; Socio)
        {
            // Estas dos columnas "Sin Method" son las claves de agrupación.
            // BC agrupará los resultados por Nº Socio y Nombre.
            column(Num_Socio; "No.")
            {
                Caption = 'Nº Socio';
            }
            column(Nombre_Socio; Nombre)
            {
                Caption = 'Nombre';
            }

            dataitem(LineaPrestamo; "Linea Prestamo")
            {
                // Aquí le decimos: "enlaza cada línea con su socio correspondiente"
                DataItemLink = "No. Socio" = Socio."No.";

                // LeftOuterJoin significa: "inclúyeme también los socios
                // que no tienen ningún préstamo (aparecerán con 0 días)"
                SqlJoinType = LeftOuterJoin;

                column(Total_Dias; "Dias Prestamo")
                {
                    Caption = 'Total Días';
                    Method = Sum;   // ← BC suma automáticamente todos los días
                                    //   de préstamo de cada socio
                }
                column(Num_Prestamos; "No. Prestamo")
                {
                    Caption = 'Número de Préstamos';
                    Method = Count; // ← BC cuenta cuántos préstamos tiene cada socio
                }
            }
        }
    }
}
```

---

### 1.5 Cómo usar un Query desde código AL

Una vez tienes el Query definido, lo utilizas desde un Codeunit de esta forma:

```al
codeunit 50100 "Gestor Estadisticas Prestamos"
{
    procedure MostrarDiasPorSocio()
    var
        QDias: Query "Dias Totales Prestamo por Socio";
        Mensaje: Text;
    begin
        // Paso 1: Si quieres, aplica filtros antes de lanzar la consulta
        QDias.SetFilter(Num_Socio, 'S001..S050'); // Solo socios del S001 al S050

        // Paso 2: Abre la Query (BC va a buscar los datos en ese momento)
        QDias.Open();

        // Paso 3: Recorre los resultados fila a fila
        while QDias.Read() do begin
            Mensaje := StrSubstNo(
                'Socio: %1 | Nombre: %2 | Días: %3 | Préstamos: %4',
                QDias.Num_Socio,
                QDias.Nombre_Socio,
                QDias.Total_Dias,
                QDias.Num_Prestamos
            );
            Message(Mensaje);
        end;

        // Paso 4: Cierra la Query cuando termines (buena práctica siempre)
        QDias.Close();
    end;
}
```

> **Importante:** Los filtros con `SetFilter` se deben poner **antes** de `Open()`. Si los pones después, ya no tienen efecto porque BC ya ha traído los datos.

---

## 2. Reports y DataItems

### 2.1 ¿Qué es un Report?

Si un Query es la herramienta para consultar datos internamente, un **Report** es la herramienta para **presentar esos datos al usuario en un documento**: puede ser un PDF, un documento de Word, o un archivo que se imprime.

Piensa en los informes que ya conoces de BC: la ficha del cliente, el albarán de ventas, el extracto de movimientos contables. Todos ellos son Reports construidos exactamente igual que los que tú puedes crear en AL.

Un Report en AL tiene cuatro secciones principales: `dataset` (qué datos se leen y cómo), `requestpage` (pantalla previa de filtros), `layout` (el diseño visual del documento) y `triggers` (lógica que se ejecuta al inicio, durante o al final del proceso).

---

### 2.2 ¿Qué es un DataItem?

Dentro del `dataset` de un Report, la pieza fundamental es el **DataItem**. Un DataItem representa **una tabla de BC** desde la que vas a leer datos para el informe.

Lo más importante que tienes que entender es esto: **un DataItem funciona como un bucle automático**. BC recorre todos los registros de esa tabla (con los filtros que tú definas) y por cada registro ejecuta el bloque de contenido del informe una vez.

Imagina que tienes una tabla de socios con 200 registros. Si creas un DataItem sobre esa tabla, BC recorrerá cada uno de ellos automáticamente sin que tú tengas que escribir ningún bucle ni ningún contador.

```al
// Así se declara un DataItem dentro del dataset de un Report

dataset
{
    dataitem(Socio; Socio)  // NombreLogico ; NombreFisicoTabla
    {
        // Las columnas son los campos de la tabla que quieres
        // usar en el diseño del informe
        column(No_Socio; "No.")
        {
            Caption = 'Número de Socio';
        }
        column(Nombre_Socio; Nombre)
        {
            Caption = 'Nombre';
        }
        column(Email_Socio; Email)
        {
            Caption = 'Correo Electrónico';
        }
    }
}
```

#### Los triggers de un DataItem

Además de las columnas, cada DataItem tiene tres triggers donde puedes poner lógica propia:

| Trigger | Cuándo se ejecuta | Para qué sirve |
|---|---|---|
| `OnPreDataItem()` | Una sola vez, antes de empezar a leer | Establecer filtros, ordenar los datos |
| `OnAfterGetRecord()` | En cada registro leído | Calcular valores, transformar texto, acumular totales |
| `OnPostDataItem()` | Una sola vez, al terminar todos los registros | Mostrar subtotales, hacer limpieza de variables |

---

### 2.3 Ejemplo: informe de lista de socios

```al
report 50100 "Lista de Socios"
{
    Caption = 'Listado de Socios';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

    dataset
    {
        dataitem(Socio; Socio)
        {
            column(No_Socio; "No.")         { Caption = 'Número'; }
            column(Nombre_Socio; Nombre)    { Caption = 'Nombre'; }
            column(Email_Socio; Email)      { Caption = 'Email'; }
            column(Telefono_Socio; Telefono){ Caption = 'Teléfono'; }
            column(Fecha_Alta; "Fecha Alta"){ Caption = 'Fecha de Alta'; }

            // Columna calculada: no viene de un campo directo de la tabla
            // sino de una variable que rellenamos nosotros en OnAfterGetRecord
            column(Dias_Como_Socio; DiasComoSocio)
            {
                Caption = 'Días como socio';
            }

            trigger OnPreDataItem()
            begin
                // Antes de leer los registros, los ordenamos por nombre
                SetCurrentKey(Nombre);
            end;

            trigger OnAfterGetRecord()
            begin
                // Esto se ejecuta por cada socio.
                // Calculamos cuántos días lleva siendo socio.
                DiasComoSocio := Today() - "Fecha Alta";

                // Si no tiene teléfono, ponemos un texto amable
                if Telefono = '' then
                    Telefono := 'No registrado';
            end;
        }
    }

    var
        DiasComoSocio: Integer; // Variable global del Report

    rendering
    {
        layout(RDLCLayout)
        {
            Type = RDLC;
            LayoutFile = 'src/layouts/ListaSocios.rdlc';
        }
    }
}
```

> **Nota:** La propiedad `rendering` le dice al informe qué archivo de diseño usar. El archivo `.rdlc` es donde diseñas visualmente cómo queda el documento (con Visual Studio o el editor de BC). En esta guía nos centramos en la parte AL, no en el diseño visual.

---

## 3. Jerarquía en Reports

### 3.1 El problema que resuelve la jerarquía

Un informe de una sola tabla está bien para listados simples. Pero en la realidad casi siempre quieres mostrar **datos relacionados**: un socio y todos sus préstamos, o una factura con todas sus líneas.

Para eso, en AL puedes **anidar DataItems**: poner un DataItem dentro de otro. El DataItem interior (el hijo) se repetirá automáticamente dentro del contexto del exterior (el padre).

BC sabe qué préstamos pertenecen a qué socio porque tú le indicas el **campo de enlace** con `DataItemLink`. Para cada socio que esté procesando, el DataItem hijo solo leerá los préstamos cuyo campo `No. Socio` coincida con el `No.` del socio actual. El mismo principio se aplica a cualquier nivel adicional de anidación.

---

### 3.2 Cómo se escribe la anidación

```al
dataitem(Socio; Socio)          // NIVEL 1 - Padre
{
    column(Socio_No; "No.") { }
    column(Socio_Nombre; Nombre) { }

    dataitem(Prestamo; Prestamo) // NIVEL 2 - Hijo (va DENTRO del padre)
    {
        // Este es el enlace clave:
        // "Para cada socio, solo lee los préstamos donde
        //  el campo 'No. Socio' coincida con el 'No.' del socio actual"
        DataItemLink = "No. Socio" = FIELD("No.");

        column(Prestamo_No; "No.") { }
        column(Prestamo_Dias; "Dias Prestamo") { }

        dataitem(Linea; "Linea Prestamo") // NIVEL 3 - Nieto
        {
            DataItemLink = "No. Prestamo" = FIELD("No.");

            column(Linea_Libro; "Titulo Libro") { }
            column(Linea_Devuelto; Devuelto) { }
        }
    }
}
```

---

### 3.3 Ejemplo completo: socios con sus préstamos y totales

Este es un informe real que muestra cada socio, sus préstamos y al final de cada socio acumula el total de días:

```al
report 50101 "Socios con Prestamos"
{
    Caption = 'Socios y sus Préstamos';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

    dataset
    {
        // ══════════════════════════════════════════════
        // NIVEL 1: SOCIO
        // BC leerá todos los socios uno a uno
        // ══════════════════════════════════════════════
        dataitem(Socio; Socio)
        {
            column(Socio_No; "No.")             { Caption = 'Nº Socio'; }
            column(Socio_Nombre; Nombre)         { Caption = 'Nombre'; }
            column(Socio_Email; Email)           { Caption = 'Email'; }

            // Estas columnas las rellenamos nosotros con variables
            column(Socio_TotalDias; TotalDiasSocio)
            {
                Caption = 'Total Días Préstamo';
            }
            column(Socio_NumPrestamos; NumPrestamosSocio)
            {
                Caption = 'Nº Préstamos';
            }

            trigger OnPreDataItem()
            begin
                // Los socios aparecerán ordenados por nombre
                SetCurrentKey(Nombre);
            end;

            trigger OnAfterGetRecord()
            begin
                // Cada vez que pasamos a un socio nuevo,
                // reiniciamos los contadores a cero
                TotalDiasSocio := 0;
                NumPrestamosSocio := 0;
            end;


            // ══════════════════════════════════════════════
            // NIVEL 2: PRÉSTAMO (va anidado dentro de Socio)
            // BC leerá automáticamente solo los préstamos
            // del socio que está procesando en ese momento
            // ══════════════════════════════════════════════
            dataitem(Prestamo; Prestamo)
            {
                DataItemLink = "No. Socio" = FIELD("No.");

                // Solo incluimos préstamos que estén Activos o En Devolución.
                // Los préstamos Devueltos no aparecerán en el informe.
                DataItemTableFilter = Estado = FILTER(Activo | "En Devolucion");

                column(Prestamo_No; "No.")               { Caption = 'Nº Préstamo'; }
                column(Prestamo_FechaInicio; "Fecha Inicio") { Caption = 'Inicio'; }
                column(Prestamo_FechaFin; "Fecha Fin")   { Caption = 'Fin Previsto'; }
                column(Prestamo_Dias; "Dias Prestamo")   { Caption = 'Días'; }
                column(Prestamo_Estado; Estado)          { Caption = 'Estado'; }


                // ══════════════════════════════════════════════
                // NIVEL 3: LÍNEA DE PRÉSTAMO (anidado en Préstamo)
                // Cada préstamo puede tener varios libros
                // ══════════════════════════════════════════════
                dataitem(LineaPrestamo; "Linea Prestamo")
                {
                    DataItemLink = "No. Prestamo" = FIELD("No.");

                    column(Linea_No; "No. Linea")       { Caption = 'Línea'; }
                    column(Linea_Libro; "Titulo Libro") { Caption = 'Libro'; }
                    column(Linea_ISBN; ISBN)            { Caption = 'ISBN'; }
                    column(Linea_Devuelto; Devuelto)    { Caption = 'Devuelto'; }
                }

                trigger OnAfterGetRecord()
                begin
                    // Por cada préstamo, vamos sumando al total del socio
                    TotalDiasSocio += "Dias Prestamo";
                    NumPrestamosSocio += 1;
                end;
            }
        }
    }

    var
        TotalDiasSocio: Integer;
        NumPrestamosSocio: Integer;

    rendering
    {
        layout(RDLCLayout)
        {
            Type = RDLC;
            LayoutFile = 'src/layouts/SociosPrestamos.rdlc';
        }
    }
}
```

---

### 3.4 Ordenar los datos en cada nivel

Puedes controlar el orden en que aparecen los datos en cada nivel del informe usando `SetCurrentKey` dentro del trigger `OnPreDataItem()`:

```al
dataitem(Socio; Socio)
{
    trigger OnPreDataItem()
    begin
        SetCurrentKey(Nombre); // Socios ordenados de la A a la Z
    end;

    dataitem(Prestamo; Prestamo)
    {
        DataItemLink = "No. Socio" = FIELD("No.");

        trigger OnPreDataItem()
        begin
            // Dentro de cada socio, los préstamos más recientes primero
            SetCurrentKey("Fecha Inicio");
            SetAscending("Fecha Inicio", false); // false = descendente
        end;

        dataitem(LineaPrestamo; "Linea Prestamo")
        {
            DataItemLink = "No. Prestamo" = FIELD("No.");

            trigger OnPreDataItem()
            begin
                SetCurrentKey("No. Linea"); // Líneas en orden numérico
            end;
        }
    }
}
```

> **Tip:** `SetAscending(campo, true)` ordena de menor a mayor (A→Z, fechas antiguas primero). `SetAscending(campo, false)` ordena de mayor a menor (Z→A, fechas recientes primero).

---

## 4. RequestPage

### 4.1 ¿Qué es la RequestPage?

Cuando ejecutas un informe en Business Central, antes de que aparezca el documento, BC te muestra una **pantalla de opciones**. A esa pantalla se le llama **RequestPage** (página de solicitud).

Es el momento en que el usuario puede decirle al informe: *"oye, solo quiero ver los datos de enero"* o *"muéstrame solo los préstamos activos"*. Sin esa pantalla, el informe siempre sacaría todos los datos, sin excepción.

Los filtros estándar de los DataItems (Socio, Préstamo...) aparecen en la RequestPage de forma automática. Tú solo tienes que definir las **opciones adicionales** que quieras añadir, como casillas de verificación o campos de fecha personalizados.

---

### 4.2 Cómo se define la RequestPage en AL

La sección `requestpage` va dentro del Report, al mismo nivel que `dataset`:

```al
requestpage
{
    // SaveValues = true hace que BC recuerde la última configuración
    // que usó el usuario. Muy cómodo para informes que se lanzan a diario.
    SaveValues = true;

    layout
    {
        area(Content)
        {
            group(Opciones)
            {
                Caption = 'Opciones del Informe';

                // Un campo booleano (casilla de verificación)
                field(IncluirDevueltos; IncluirDevueltos)
                {
                    ApplicationArea = All;
                    Caption = 'Incluir préstamos ya devueltos';
                    ToolTip = 'Marca esta casilla para ver también los préstamos que ya han sido devueltos.';
                }
            }
            group(FiltroPorFechas)
            {
                Caption = 'Filtrar por Fecha';

                field(FechaDesde; FechaFiltroDesde)
                {
                    ApplicationArea = All;
                    Caption = 'Fecha inicio: Desde';
                    ToolTip = 'Solo se mostrarán préstamos que empezaron a partir de esta fecha.';
                }
                field(FechaHasta; FechaFiltroHasta)
                {
                    ApplicationArea = All;
                    Caption = 'Fecha inicio: Hasta';
                    ToolTip = 'Solo se mostrarán préstamos que empezaron antes de esta fecha.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        // Este trigger se ejecuta cuando se abre la pantalla RequestPage.
        // Es el lugar perfecto para poner valores por defecto.

        // Por defecto, mostramos el año en curso completo
        FechaFiltroDesde := DMY2Date(1, 1, Date2DMY(Today(), 3)); // 1 de enero del año actual
        FechaFiltroHasta := Today();
        IncluirDevueltos := false; // Por defecto, ocultamos los devueltos
    end;
}
```

---

### 4.3 Cómo usar las opciones de la RequestPage en los DataItems

Las variables que defines en la RequestPage son variables globales del Report. Eso significa que puedes usarlas en cualquier trigger de cualquier DataItem:

```al
dataitem(Prestamo; Prestamo)
{
    DataItemLink = "No. Socio" = FIELD("No.");

    trigger OnPreDataItem()
    begin
        // Aplicamos los filtros de fecha que el usuario eligió en la RequestPage
        if FechaFiltroDesde <> 0D then
            SetFilter("Fecha Inicio", '>=%1', FechaFiltroDesde);
        if FechaFiltroHasta <> 0D then
            SetFilter("Fecha Inicio", '<=%1', FechaFiltroHasta);

        // Si el usuario NO marcó "Incluir devueltos", ocultamos los Devueltos
        if not IncluirDevueltos then
            SetFilter(Estado, '<>%1', Estado::Devuelto);
    end;
}
```

> **¿Por qué en `OnPreDataItem` y no en `OnAfterGetRecord`?** Porque los filtros en `OnPreDataItem` se aplican antes de que BC lea los datos: solo trae los registros que cumplen la condición. Si filtraras en `OnAfterGetRecord`, BC primero traería todos los registros y luego los descartaría uno a uno, lo cual es mucho menos eficiente.

---

### 4.4 Informe completo con RequestPage integrada

Este es el informe final, con todo integrado: jerarquía, ordenación, opciones de usuario y validación:

```al
report 50102 "Informe Completo Prestamos"
{
    Caption = 'Informe Completo de Préstamos';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

    dataset
    {
        dataitem(Socio; Socio)
        {
            column(Socio_No; "No.")             { Caption = 'Nº Socio'; }
            column(Socio_Nombre; Nombre)         { Caption = 'Nombre'; }
            column(Socio_Email; Email)           { Caption = 'Email'; }
            column(Socio_TotalDias; TotalDiasSocio) { Caption = 'Total Días'; }

            trigger OnPreDataItem()
            begin
                SetCurrentKey(Nombre); // Orden alfabético por nombre
            end;

            trigger OnAfterGetRecord()
            begin
                TotalDiasSocio := 0; // Reinicio del contador al cambiar de socio
            end;

            dataitem(Prestamo; Prestamo)
            {
                DataItemLink = "No. Socio" = FIELD("No.");

                column(Prestamo_No; "No.")               { Caption = 'Nº Préstamo'; }
                column(Prestamo_FechaInicio; "Fecha Inicio") { Caption = 'Fecha Inicio'; }
                column(Prestamo_FechaFin; "Fecha Fin")   { Caption = 'Fecha Fin'; }
                column(Prestamo_Dias; "Dias Prestamo")   { Caption = 'Días'; }
                column(Prestamo_Estado; Estado)          { Caption = 'Estado'; }

                trigger OnPreDataItem()
                begin
                    // Filtros dinámicos basados en lo que eligió el usuario
                    if FechaFiltroDesde <> 0D then
                        SetFilter("Fecha Inicio", '>=%1', FechaFiltroDesde);
                    if FechaFiltroHasta <> 0D then
                        SetFilter("Fecha Inicio", '<=%1', FechaFiltroHasta);

                    if not IncluirDevueltos then
                        SetFilter(Estado, '<>%1', Estado::Devuelto);

                    // Los préstamos más recientes primero
                    SetCurrentKey("Fecha Inicio");
                    SetAscending("Fecha Inicio", false);
                end;

                trigger OnAfterGetRecord()
                begin
                    TotalDiasSocio += "Dias Prestamo";
                end;
            }
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(Content)
            {
                group(Opciones)
                {
                    Caption = 'Opciones';
                    field(IncluirDevueltos; IncluirDevueltos)
                    {
                        ApplicationArea = All;
                        Caption = 'Incluir préstamos devueltos';
                        ToolTip = 'Activa para ver también los préstamos ya devueltos.';
                    }
                }
                group(Fechas)
                {
                    Caption = 'Rango de fechas';
                    field(FechaDesde; FechaFiltroDesde)
                    {
                        ApplicationArea = All;
                        Caption = 'Fecha inicio: Desde';
                    }
                    field(FechaHasta; FechaFiltroHasta)
                    {
                        ApplicationArea = All;
                        Caption = 'Fecha inicio: Hasta';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            FechaFiltroDesde := DMY2Date(1, 1, Date2DMY(Today(), 3));
            FechaFiltroHasta := Today();
            IncluirDevueltos := false;
        end;
    }

    // Variables globales del Report (accesibles desde cualquier trigger y DataItem)
    var
        TotalDiasSocio: Integer;
        IncluirDevueltos: Boolean;
        FechaFiltroDesde: Date;
        FechaFiltroHasta: Date;

    rendering
    {
        layout(RDLCLayout)
        {
            Type = RDLC;
            LayoutFile = 'src/layouts/InformeCompletoPrestamos.rdlc';
        }
    }

    trigger OnPreReport()
    begin
        // Este trigger se ejecuta UNA VEZ antes de procesar cualquier dato.
        // Es el lugar adecuado para validar las opciones del usuario.
        if (FechaFiltroDesde <> 0D) and (FechaFiltroHasta <> 0D) then
            if FechaFiltroDesde > FechaFiltroHasta then
                Error('La fecha "Desde" no puede ser posterior a la fecha "Hasta".');
    end;

    trigger OnPostReport()
    begin
        // Este trigger se ejecuta UNA VEZ cuando el informe ha terminado.
        // Puedes usarlo para mostrar un mensaje de confirmación o registrar la ejecución.
        Message('Informe generado correctamente.');
    end;
}
```
