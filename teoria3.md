# Interfaz de Usuario (UI) en Business Central
## Pages - FactBoxes - Parts

---

## Índice

- [1. Que es una Page en AL](#1-que-es-una-page-en-al)
- [2. Estructura base de una Page](#2-estructura-base-de-una-page)
  - [Propiedades clave de la Page](#propiedades-clave-de-la-page)
  - [2.1 \[AMPLIACIÓN\] `pageextension` - Extender pages sin modificarlas](#21-ampliación-pageextension---extender-pages-sin-modificarlas)
  - [2.2 \[AMPLIACIÓN\] `SourceTableView` - Pre-filtrar la tabla desde la page](#22-ampliación-sourcetableview---pre-filtrar-la-tabla-desde-la-page)
- [3. Tipos de Page](#3-tipos-de-page)
  - [3.1 Page Type: `List`](#31-page-type-list)
  - [3.2 Page Type: `Card`](#32-page-type-card)
  - [3.3 Page Type: `ListPlus`](#33-page-type-listplus)
  - [3.4 \[AMPLIACIÓN\] Pages de catálogo maestro](#34-ampliación-pages-de-catálogo-maestro)
  - [3.5 \[AMPLIACIÓN\] `SourceTableTemporary` - Pages sin datos reales](#35-ampliación-sourcetabletemporary---pages-sin-datos-reales)
- [4. Controles de grupo en el Layout](#4-controles-de-grupo-en-el-layout)
  - [4.1 \[AMPLIACIÓN\] `FreezeColumnID` - Columna fija en una lista](#41-ampliación-freezecolumnid---columna-fija-en-una-lista)
- [5. Controles de campo (field)](#5-controles-de-campo-field)
  - [Propiedades más usadas de un `field`](#propiedades-más-usadas-de-un-field)
- [6. FactBoxes - Los paneles informativos laterales](#6-factboxes---los-paneles-informativos-laterales)
- [7. Parts - Subpáginas embebidas](#7-parts---subpáginas-embebidas)
  - [7.1 CardPart (resumen estático)](#71-cardpart-resumen-estático)
  - [7.2 ListPart (historial o sublista)](#72-listpart-historial-o-sublista)
- [8. Conectar un Part con la página padre con `SubPageLink`](#8-conectar-un-part-con-la-página-padre-con-subpagelink)
- [9. \[AMPLIACIÓN\] Actions - Botones y menús de acción](#9-ampliación-actions---botones-y-menús-de-acción)
- [10. Triggers de Page](#10-triggers-de-page)
- [11. Resumen visual y comparativa](#11-resumen-visual-y-comparativa)
  - [Tabla comparativa de tipos de Page](#tabla-comparativa-de-tipos-de-page)
  - [Diagrama de relación entre los tipos](#diagrama-de-relación-entre-los-tipos)

---

## 1. Que es una Page en AL

Una **Page** es el objeto de Business Central que define cómo se *ve* e *interactúa* con los datos del sistema. Si las **Tablas** son el "almacén" de datos, las Pages son las "ventanas" a través de las cuales el usuario final lee, introduce y modifica esa información.

> **Analogía sencilla:** Imagina que la tabla `Socio` es una hoja de cálculo guardada en el servidor. La Page es el formulario en pantalla que le mostramos al bibliotecario para que trabaje cómodamente con esos datos, sin ver filas de base de datos.

Cada Page en AL:
- Está **numerada** (identificador único del objeto)
- Tiene un **nombre** descriptivo entre comillas
- Está vinculada a una **`SourceTable`** (la tabla de datos que muestra)
- Tiene un **`PageType`** que determina su apariencia

---

## 2. Estructura base de una Page

Todo objeto Page sigue esta estructura general:

```bash
page <Id> "<NombreDeLaPage>"
{
    //  Zona de propiedades 
    PageType   = <TipoDePage>;
    ApplicationArea = All;
    UsageCategory   = <Categoría>;
    SourceTable     = "<NombreTabla>";

    //  Zona de layout (salida por pantalla) 
    layout
    {
        area(Content)
        {
            // controles de grupo y de campo
        }
        area(FactBoxes)
        {
            // paneles informativos laterales
        }
    }

    //  Zona de acciones (menús y botones) 
    actions
    {
        area(Processing)
        {
            action(NombreAccion)
            {
                trigger OnAction()
                begin
                    // lógica del botón
                end;
            }
        }
    }

    //  Triggers del objeto Page 
    trigger OnOpenPage()
    begin
        // se ejecuta al abrir la página
    end;
}
```

### Propiedades clave de la Page

| Propiedad           | Descripción                                       | Ejemplo                       |
| ------------------- | ------------------------------------------------- | ----------------------------- |
| `PageType`          | Define la apariencia y comportamiento de la page  | `List`, `Card`, `ListPart`... |
| `SourceTable`       | Tabla de datos que alimenta la page               | `"Socio"`                     |
| `ApplicationArea`   | Controla qué áreas funcionales pueden ver la page | `All`                         |
| `UsageCategory`     | Categoría al buscar con la lupa en BC             | `Lists`, `Administration`     |
| `CardPageId`        | En un List, indica qué Card se abre al hacer clic | `"Socio Card"`                |
| `Editable`          | Si es `false`, los campos no se pueden modificar  | `false`                       |
| `Caption`           | Título visible en la interfaz de BC               | `'Gestión de Socios'`         |
| `RefreshOnActivate` | Recarga datos al volver a la página               | `true`                        |

### 2.1 [AMPLIACIÓN] `pageextension` - Extender pages sin modificarlas

En Business Central, las pages estándar del sistema (como la ficha de cliente o la lista de artículos) **no se pueden modificar directamente**. Para añadirles campos, grupos o acciones personalizadas se usa el objeto `pageextension`.

**¿Por qué es importante?** Porque en un proyecto real casi nunca partes de cero: extiende las pages existentes de BC en lugar de reemplazarlas.

**Sintaxis:**

```bash
pageextension <Id> "<NombreExtension>" extends "<NombrePageOriginal>"
{
    layout
    {
        addafter(<NombreCampoExistente>)  // dónde insertar los nuevos campos
        {
            field("<NuevoCampo>"; Rec."<NuevoCampo>") { }
        }
    }
    actions
    {
        addlast(Processing)
        {
            action(NuevaAccion) { ... }
        }
    }
}
```

**Ejemplo  Añadir el código de socio de biblioteca a la ficha de cliente estándar de BC:**

```bash
// No modificamos la page original de BC, la EXTENDEMOS
pageextension 50300 "Customer Card Biblioteca" extends "Customer Card"
{
    layout
    {
        addafter(Name)   // se inserta justo después del campo 'Name'
        {
            field("No. Socio Biblioteca"; Rec."No. Socio Biblioteca")
            {
                ApplicationArea = All;
                Caption         = 'Número de Socio';
            }
        }
    }
}
```

**Verbos disponibles para modificar el layout existente:**

| Verbo                      | Efecto                                         |
| -------------------------- | ---------------------------------------------- |
| `addafter(campo)`          | Inserta justo después del campo/grupo indicado |
| `addbefore(campo)`         | Inserta justo antes                            |
| `addfirst(grupo)`          | Inserta al inicio del grupo                    |
| `addlast(grupo)`           | Inserta al final del grupo                     |
| `modify(campo)`            | Modifica propiedades de un campo ya existente  |
| `movebefore` / `moveafter` | Recoloca un campo existente                    |

---

### 2.2 [AMPLIACIÓN] `SourceTableView` - Pre-filtrar la tabla desde la page

Normalmente una page muestra **todos** los registros de su `SourceTable`. Con `SourceTableView` podemos aplicar un **filtro permanente** desde la definición de la page, de modo que el usuario sólo vea un subconjunto concreto de datos.

**Ejemplo  Una list que sólo muestra los préstamos NO devueltos:**

```bash
page 50340 "Prestamos Pendientes List"
{
    PageType      = List;
    ApplicationArea = All;
    UsageCategory   = Lists;
    SourceTable     = "Prestamo";
    // Filtro fijo: sólo registros donde Devuelto = false
    SourceTableView = where(Devuelto = const(false));
    Editable        = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("No.";               Rec."No.") { }
                field("No. Socio";        Rec."No. Socio") { }
                field("No. Libro";        Rec."No. Libro") { }
                field("Fecha Préstamo";   Rec."Fecha Préstamo") { }
                field("Fecha Devolución"; Rec."Fecha Devolución") { }
            }
        }
    }
}
```

Este filtro es **transparente para el usuario**: la barra de filtro de BC no lo mostrará, simplemente nunca verá los registros que no cumplen la condición.

**Otros operadores para `SourceTableView`:**

```bash
// Filtro con rango
SourceTableView = where("Fecha Préstamo" = filter('>01/01/2025'));

// Orden predeterminado además del filtro
SourceTableView = sorting("Fecha Préstamo") order(descending)
                  where(Devuelto = const(false));
```



---

## 3. Tipos de Page

Business Central ofrece varios tipos de page. En este proyecto trabajamos principalmente con tres:

### 3.1 Page Type: `List`

Una **List** muestra **varios registros a la vez** en forma de tabla (filas y columnas), igual que una hoja de cálculo. Es el punto de entrada habitual para navegar por los datos.

**Características:**
- Usa un control `repeater` en el layout (repite las filas)
- Suele tener `Editable = false` para evitar ediciones accidentales
- Enlaza a la Card correspondiente mediante `CardPageId`
- Al hacer doble click en una fila, abre la Card de ese registro

**Ejemplo  Lista de Socios:**

```bash
page 50300 "Socio List"
{
    PageType        = List;
    ApplicationArea = All;
    UsageCategory   = Lists;          // aparece en la búsqueda como "Lista"
    SourceTable     = "Socio";
    CardPageId      = "Socio Card";   // al hacer clic abre este formulario
    Editable        = false;          // sólo lectura desde la lista

    layout
    {
        area(Content)
        {
            repeater(GroupName)       // repite una fila por cada registro
            {
                field("No."; Rec."No.") { }
                field(Nombre; Rec.Nombre) { }
                field(Email; Rec.Email) { }
                field("Fecha Alta"; Rec."Fecha Alta") { }
                field("Total Préstamos"; Rec."Total Préstamos") { }  // FlowField
            }
        }
        area(FactBoxes)
        {
            part(HistorialPrestamos; "Prestamo ListPart")
            {
                SubPageLink = "No. Socio" = field("No.");
            }
        }
    }
}
```

>  El campo `Total Préstamos` es un **FlowField** calculado dinámicamente. Aquí simplemente lo mostramos como un campo más.

---

### 3.2 Page Type: `Card`

Una **Card** muestra **un único registro completo** con todos sus fields organizados en grupos desplegables. Es el formulario de detalle donde el usuario puede crear, editar y ver toda la información de un registro.

**Características:**
- Usa controles `group` para organizar los campos en secciones
- Vinculada desde la List mediante `CardPageId`
- `UsageCategory = Administration` por convención

**Ejemplo  Ficha de Socio:**

```bash
page 50301 "Socio Card"
{
    PageType        = Card;
    ApplicationArea = All;
    UsageCategory   = Administration;
    SourceTable     = "Socio";

    layout
    {
        area(Content)
        {
            group(General)                        // sección "General" (desplegable)
            {
                field("No."; Rec."No.")
                {
                    Importance = Promoted;        // aparece destacado aunque el grupo esté cerrado
                }
                field(Nombre; Rec.Nombre)
                {
                    Importance = Promoted;
                }
                field(Email; Rec.Email) { }
                field("Fecha Alta"; Rec."Fecha Alta") { }
            }
            group(Direccion)                      // segunda sección "Dirección"
            {
                field(Calle; Rec.Calle) { }
                field("Código Postal"; Rec."Código Postal") { }
                field(Ciudad; Rec.Ciudad) { }
            }
            group(Estadisticas)                   // tercera sección "Estadísticas"
            {
                field("Total Préstamos"; Rec."Total Préstamos")
                {
                    Importance = Promoted;
                    Editable   = false;           // es un FlowField, no se edita manualmente
                }
                field("Días Totales Préstamo"; Rec."Días Totales Préstamo")
                {
                    Importance = Additional;      // se muestra al desplegar más el grupo
                }
            }
        }
        area(FactBoxes)
        {
            part(HistorialPrestamos; "Prestamo ListPart")
            {
                SubPageLink = "No. Socio" = field("No.");
            }
        }
    }
}
```

---

### 3.3 Page Type: `ListPlus`

Un tipo intermedio: muestra una **lista de registros** pero también tiene espacio para mostrar información adicional debajo de la lista (a diferencia de `List` que es puramente tabular). Se usa, por ejemplo, para documentos con cabecera y líneas.

```bash
page 50350 "Prestamo Document List"
{
    PageType        = ListPlus;
    ApplicationArea = All;
    UsageCategory   = Lists;
    SourceTable     = "Prestamo Header";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("No."; Rec."No.") { }
                field("No. Socio"; Rec."No. Socio") { }
                field("Fecha Préstamo"; Rec."Fecha Préstamo") { }
                field("Fecha Devolución"; Rec."Fecha Devolución") { }
            }
        }
    }
}
```

### 3.4 [AMPLIACIÓN] Pages de catálogo maestro

No todas las tablas necesitan una **Card** dedicada. Las **tablas de maestros simples** (catálogos de referencia con sólo dos o tres campos, como tipos, categorías o géneros) suelen exponerse mediante una **única page de tipo `List`** que actúa a la vez como lista y como editor inline.

**¿Cuándo aplica este patrón?**
- La tabla tiene muy pocos campos (código + descripción)
- No hay lógica compleja en la creación/edición de registros
- El usuario edita directamente en la propia fila de la lista

**Aplicado a nuestra Biblioteca Municipal:**

```bash
// Categorías de libro: Novela, Ensayo, Infantil, Técnico...
page 50320 "Categoria Libro List"
{
    PageType        = List;
    ApplicationArea = All;
    UsageCategory   = Lists;
    SourceTable     = "Categoria Libro";  // tabla previamente definida

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Codigo; Rec.Codigo) { }
                field(Descripcion; Rec.Descripcion) { }
            }
        }
    }
    // Sin CardPageId: el usuario edita categorías directamente en la fila
}
```

>  **Clave:** Sin `CardPageId`, al hacer doble clic en una fila el usuario simplemente activa la edición inline. No se abre ninguna ventana nueva.

---


---

### 3.5 [AMPLIACIÓN] `SourceTableTemporary` - Pages sin datos reales

Normalmente una page muestra los registros **guardados en la base de datos**. Pero a veces queremos mostrar información **calculada o agrupada** que no existe como tal en ninguna tabla. Para eso existe `SourceTableTemporary`.

**¿Qué significa `SourceTableTemporary = true`?**

La page usa la estructura de una tabla existente, pero los datos que aparece **son temporales, generados en memoria** durante la sesión del usuario. La tabla real no se toca: sólo se usa como "molde" (definición de columnas).

**Flujo de funcionamiento:**

```
1. El usuario abre la page
        
2. Se dispara el trigger OnOpenPage()
        
3. La page lanza una Query para obtener datos agrupados/calculados
        
4. Los resultados se insertan en Rec (tabla temporal en memoria)
        
5. La page muestra esos datos como si fueran filas normales
        (pero desaparecen al cerrar la page)
```

**Ejemplo - Resumen de Préstamos Activos:**

```bash
// "¿Cuántos días lleva prestado cada libro actualmente?"
// No existe una tabla con ese cálculo  usamos tabla temporal
page 50330 "Resumen Prestamos Activos"
{
    PageType             = List;
    ApplicationArea      = All;
    UsageCategory        = Lists;
    SourceTable          = "Prestamo";  // tabla molde (sin tocar la BD real)
    SourceTableTemporary = true;
    Editable             = false;       // es sólo informativo

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("No. Libro";    Rec."No. Libro") { }
                field("No. Socio";   Rec."No. Socio") { }
                field("Días Activo"; Rec."Dias Activo") { }
            }
        }
    }

    trigger OnOpenPage()
    var
        qPrestamos : Query "Prestamos Activos Agrupados";  // Query de Daniel
        Counter    : Integer;
    begin
        qPrestamos.Open();
        while qPrestamos.Read() do begin
            Counter += 1;
            Rec.Init();
            Rec."Entry No."  := Counter;
            Rec."No. Libro" := qPrestamos.No_Libro;
            Rec."No. Socio" := qPrestamos.No_Socio;
            Rec."Dias Activo" := qPrestamos.Sum_Dias;
            Rec.Insert();
        end;
    end;
}
```

>  Este patrón es muy potente para **pantallas de análisis y resumen** sin necesidad de crear tablas intermedias en la BD.

---

## 4. Controles de grupo en el Layout

Dentro del `area(Content)`, los campos deben estar contenidos en un **control de grupo**. El tipo de control de grupo se elige según el tipo de página:

| Control       | Se usa en...                      | Función                                                 |
| ------------- | --------------------------------- | ------------------------------------------------------- |
| `repeater`    | Page tipo **List** / **ListPlus** | Repite una fila de campos por cada registro de la tabla |
| `group`       | Page tipo **Card**                | Agrupa campos en secciones desplegables con título      |
| `cuegroup`    | Page tipo **RoleCenter**          | Muestra actividades como baldosas o "cues"              |
| `fixedLayout` | Bajo la lista en un **List**      | Zona fija debajo de la lista para información extra     |


### 4.1 [AMPLIACIÓN] `FreezeColumnID` - Columna fija en una lista

En una `List` con muchas columnas, al hacer scroll horizontal el usuario puede perder de vista el identificador del registro. `FreezeColumnID` **inmoviliza una columna** para que siempre permanezca visible.

```bash
repeater(GroupName)
{
    FreezeColumnID = "No.";   // el campo "No." siempre visible al hacer scroll

    field("No.";               Rec."No.") { }
    field("No. Socio";        Rec."No. Socio") { }
    field("No. Libro";        Rec."No. Libro") { }
    field("Fecha Préstamo";   Rec."Fecha Préstamo") { }
    field("Fecha Devolución"; Rec."Fecha Devolución") { }
    field(Devuelto;           Rec.Devuelto) { }
    field("Días Vencido";     Rec."Días Vencido") { }  // FlowField
    // ... más columnas que requieren scroll
}
```



---


```bash
group(NombreGrupo)
{
    Caption  = 'Título visible en pantalla';
    Visible  = true;    // muestra / oculta el grupo completo
    Enabled  = true;    // activa / desactiva la interacción
    Editable = true;    // si los campos dentro se pueden editar
    // ...campos dentro del grupo
}
```

---

## 5. Controles de campo (field)

Los controles de campo conectan cada columna o etiqueta de la interfaz con un campo de la tabla origen.

**Sintaxis:**
```bash
field(<NombreControl>; Rec."<NombreCampoTabla>")
{
    // propiedades del control de campo
}
```

### Propiedades más usadas de un `field`

| Propiedad         | Valores                              | Descripción                                                 |
| ----------------- | ------------------------------------ | ----------------------------------------------------------- |
| `Importance`      | `Standard`, `Promoted`, `Additional` | Controla visibilidad cuando el grupo está contraído         |
| `Caption`         | texto                                | Etiqueta visible en pantalla (distinta al nombre del campo) |
| `Visible`         | `true` / `false`                     | Muestra u oculta el campo                                   |
| `Editable`        | `true` / `false`                     | Permite o bloquea la edición                                |
| `Enabled`         | `true` / `false`                     | Activa o desactiva el control                               |
| `ShowMandatory`   | `true` / `false`                     | Muestra un asterisco `*` si el campo es obligatorio         |
| `QuickEntry`      | `true` / `false`                     | Permite que el campo reciba el foco con Tab                 |
| `Multiline`       | `true` / `false`                     | Permite saltos de línea en campos de texto                  |
| `Width`           | número                               | Ancho visual del control en la cuadrícula                   |
| `ApplicationArea` | texto                                | Área funcional a la que pertenece este control              |

**Ejemplo con distintos niveles de `Importance`:**

```bash
group(General)
{
    field("No."; Rec."No.")
    {
        Importance = Promoted;    // siempre visible, aunque el grupo esté plegado
    }
    field(Nombre; Rec.Nombre)
    {
        Importance = Promoted;
    }
    field(Email; Rec.Email)
    {
        // Importance = Standard  (es el valor por defecto)
    }
    field(Observaciones; Rec.Observaciones)
    {
        Importance  = Additional; // sólo visible al expandir más el grupo
        Multiline   = true;
    }
}
```

> **Cómo funciona `Importance` visualmente:**
> - **`Promoted`**  aparece a la derecha del título del grupo aunque esté plegado (en un recuadrito azul)
> - **`Standard`**  aparece al desplegar el grupo normalmente
> - **`Additional`**  aparece al hacer clic en "Mostrar más" dentro del grupo ya desplegado

---

## 6. FactBoxes - Los paneles informativos laterales

Las **FactBoxes** son **paneles que aparecen en la columna derecha** de la pantalla cuando el usuario navega por una List o una Card. Su función es mostrar **información adicional y contextual** del registro seleccionado sin necesidad de abrir otra ventana.

> **Analogía:** Imagina que estás viendo la ficha de un socio. En el panel lateral derecho aparece automáticamente un resumen de todos sus préstamos activos. No has abierto nada nuevo; la información "acompaña" al registro.

**Características de las FactBoxes:**
- Se definen en el `area(FactBoxes)` de la page padre
- Cada FactBox es un objeto `part` que apunta a otra página
- Se filtran automáticamente al registro seleccionado mediante `SubPageLink`
- Pueden ser de tipo `CardPart` o `ListPart` (ver siguiente sección)

**Dónde se declaran:**

```bash
layout
{
    area(Content)
    {
        // ... campos principales
    }
    area(FactBoxes)                              // zona de paneles laterales
    {
        part(<NombreLocal>; "<NombreDeLaPage>")  // parte que se muestra
        {
            SubPageLink = "<CampoFiltro>" = field("<CampoOrigen>");
        }
    }
}
```

**Ejemplo completo  FactBox de préstamos en la ficha de un libro:**

```bash
// En la page "Libro Card":
area(FactBoxes)
{
    part(PrestamosLibro; "Prestamo ListPart")
    {
        // Cada vez que el usuario cambia de libro, el panel se actualiza
        // mostrando solo los préstamos de ESE libro
        SubPageLink = "No. Libro" = field("No.");
    }
}
```

---

## 7. Parts - Subpáginas embebidas

Un **Part** es una **página dentro de otra página**. Es el objeto que se usa como contenido de las FactBoxes (y también puede aparecer embebido en el área de contenido principal).

Existen dos tipos principales:

### 7.1 CardPart (resumen estático)

Un `CardPart` muestra información de **un único registro** en formato de ficha. Se usa para resúmenes fijos, por ejemplo: mostrar los datos de contacto del socio en la ficha de un préstamo.

```bash
page 50310 "Socio Info FactBox"           // el nombre es libre, pero suele indicar que es una FactBox
{
    PageType        = CardPart;           //  tipo CardPart
    ApplicationArea = All;
    SourceTable     = "Socio";

    layout
    {
        area(Content)
        {
            field("No."; Rec."No.") { }
            field(Nombre; Rec.Nombre) { }
            field(Email; Rec.Email) { }
            field("Total Préstamos"; Rec."Total Préstamos")
            {
                Editable = false;         // FlowField  sólo lectura
            }
        }
    }
}
```

**¿Cuándo usar CardPart?**
- Para mostrar un resumen de **un único registro relacionado** (sin lista)
- Para datos de referencia que acompañan al registro principal
- Cuando el contenido es **estático** (sin filas repetidas)

---

### 7.2 ListPart (historial o sublista)

Un `ListPart` muestra **varios registros** (una lista) dentro del panel lateral. Sin un control `repeater`. Se usa para historiales, líneas de documento, o cualquier relación de uno-a-muchos.

```bash
page 50311 "Prestamo ListPart"            // nombre descriptivo indicando que es una subpage
{
    PageType        = ListPart;           //  tipo ListPart
    ApplicationArea = All;
    SourceTable     = "Prestamo";         // apunta a la tabla de préstamos

    layout
    {
        area(Content)
        {
            // En un ListPart NO se usa repeater  los campos ya se listan automáticamente
            field("No."; Rec."No.") { }
            field("No. Libro"; Rec."No. Libro") { }
            field("Fecha Préstamo"; Rec."Fecha Préstamo") { }
            field("Fecha Devolución"; Rec."Fecha Devolución") { }
            field(Devuelto; Rec.Devuelto) { }
        }
    }
}
```

>  **Diferencia importante con una List normal:** En un `ListPart` el área de contenido NO lleva `repeater`. Los registros se muestran como lista automáticamente porque el propio `PageType = ListPart` lo implica. En cambio, en una page de tipo `List` el `repeater` es obligatorio.

**¿Cuándo usar ListPart?**
- Para mostrar el **historial de préstamos** de un socio o de un libro
- Para las **líneas de un pedido** dentro de la cabecera
- Cualquier relación **uno (padre)  muchos (hijos)**

---

## 8. Conectar un Part con la página padre con `SubPageLink`

La propiedad `SubPageLink` es la **clave** que hace que la FactBox muestre sólo los datos del registro seleccionado. Sin ella, el panel mostraría TODOS los registros de la tabla.

**Sintaxis:**
```bash
part(NombreLocal; "NombreDeLaPagePart")
{
    SubPageLink = "<CampoEnTablaHija>" = field("<CampoEnTablaPadre>");
}
```

**Ejemplo del proyecto  Préstamos de un Socio:**

```bash
// En "Socio Card" (tabla padre: Socio, campo: "No.")
area(FactBoxes)
{
    part(MisPrestamos; "Prestamo ListPart")
    {
        // "No. Socio" es el campo en la tabla Prestamo (hija)
        // "No." es el campo clave en la tabla Socio (padre)  lo que tiene el usuario seleccionado
        SubPageLink = "No. Socio" = field("No.");
    }
}
```

La relación encaja así:

```
Tabla "Socio"            Tabla "Prestamo"
            
"No."  "No. Socio"  (TableRelation)
                          "No. Libro"
                          "Fecha Préstamo"
                          "Fecha Devolución"
  
   SubPageLink hace que la FactBox filtre
      automáticamente por este valor
```

**Múltiples SubPageLinks:** Si la relación involucra varios campos (clave compuesta), se pueden encadenar:

```bash
SubPageLink = "No. Socio" = field("No."),
              "Ejercicio"  = field("Ejercicio Fiscal");
```

---


## 9. [AMPLIACIÓN] Actions - Botones y menús de acción

Las **actions** son los botones y opciones del menú superior de una page. Permiten ejecutar lógica de negocio.

```bash
actions
{
    area(Processing)                    // zona de acciones de proceso
    {
        action(RegistrarDevolucion)
        {
            Caption     = 'Registrar Devolución';
            ApplicationArea = All;
            Image       = Return;       // icono del botón

            trigger OnAction()          // trigger que se dispara al pulsar el botón
            begin
                // aquí iría el código AL de la lógica de devolución
                Message('Devolución registrada correctamente.');
            end;
        }
    }

    area(Navigation)                    // zona de navegación a otras pages
    {
        action(VerPrestamos)
        {
            Caption     = 'Ver Préstamos';
            ApplicationArea = All;
            RunObject   = Page "Prestamo List";  // navega a otra page sin código
        }
    }
}
```

---

## 10. Triggers de Page

Las Pages también tienen **triggers** (eventos) que se ejecutan en momentos concretos de la interacción del usuario. Son similares a los triggers de tabla pero aplicados al objeto page.

| Trigger              | Cuándo se ejecuta                                              |
| -------------------- | -------------------------------------------------------------- |
| `OnOpenPage()`       | Al abrir la page por primera vez                               |
| `OnClosePage()`      | Al cerrar la page                                              |
| `OnAfterGetRecord()` | Después de cargar cada registro (util para cálculos visuales)  |
| `OnNewRecord()`      | Al crear un nuevo registro desde la page                       |
| `OnQueryClosePage()` | Antes de cerrar, permite preguntar al usuario si desea guardar |

**Ejemplo - Mostrar un aviso si el socio tiene préstamos sin devolver:**

```bash
trigger OnAfterGetRecord()
begin
    if Rec."Prestamos Activos" > 0 then
        CurrPage.Caption := Rec.Nombre + '  Préstamos pendientes'
    else
        CurrPage.Caption := Rec.Nombre;
end;
```

---

## 11. Resumen visual y comparativa

### Tabla comparativa de tipos de Page

|                           | **List**                   | **Card**                 | **ListPart**                             | **CardPart**                        |
| ------------------------- | -------------------------- | ------------------------ | ---------------------------------------- | ----------------------------------- |
| **¿Qué muestra?**         | Varios registros en tabla  | Un registro completo     | Varios registros (para FactBox/embebido) | Un registro (para FactBox/embebido) |
| **Control de grupo**      | `repeater`                 | `group`                  | sin repeater                             | sin group obligatorio               |
| **Uso habitual**          | Navegar y buscar registros | Crear / editar registros | Historial, sublistas                     | Resumen de entidad relacionada      |
| **`CardPageId`**          | Recomendado                | No aplica                | No aplica                                | No aplica                           |
| **Puede tener FactBoxes** | Si                         | Si                       | No                                       | No                                  |
| **`UsageCategory`**       | `Lists`                    | `Administration`         | Sin categoria                            | Sin categoria                       |

### Diagrama de relación entre los tipos

```
 
             Socio List  (PageType = List)     
         
    No.  Nombre     Email  Total Préstamos  Panel lateral (FactBoxes)    
    S001 Ana García ...    3                                                 
    S002 Juan Pérez ...    1                    Prestamo ListPart            
                
                    doble click                    No.   Libro  Fecha Dev.   
      P001  L003   15/03/2025   
                                                     P002  L007   22/03/2025   
                                                    
 
           Socio Card  (PageType = Card)       
    General     
    No.: S001      Nombre: Ana García           Panel lateral (FactBoxes)    
    Email: ana@... Fecha Alta: 01/01/2024                                    
        Prestamo ListPart            
    Direccion     (filtrado por SubPageLink)   
    Calle: ... C.P: ...  Ciudad: ...            P001  L003  15/03/2025    
        P002  L007  22/03/2025    
    Estadisticas    
    Total Préstamos: 3    [Mostrar más ]    
     
 
```

```

```

