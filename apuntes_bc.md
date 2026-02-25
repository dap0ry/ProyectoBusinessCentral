## 1. FlowFields: El Motor de Cálculo en Tiempo Real

Los **FlowFields** son campos virtuales que representan una consulta configurada que se ejecuta bajo demanda. No ocupan espacio en la base de datos SQL y garantizan que la información esté siempre actualizada.

### 📑 Los "7 Fantásticos": Definición y Ejemplos
Para cada FlowField, la lógica se define en la propiedad `CalcFormula`.

1. **Sum (Suma)**:
   - **Definición**: Suma los valores de una columna numérica en una tabla relacionada.
   - **Ejemplo**: Saldo acumulado del cliente desde los movimientos detallados.
   ```al
   field(50100; "Balance (LCY)"; Decimal)
   {
       FieldClass = FlowField;
       CalcFormula = sum("Detailed Cust. Ledg. Entry"."Amount (LCY)" where ("Customer No." = field("No.")));
   }
   ```

2. **Average (Promedio)**:
   - **Definición**: Calcula la media aritmética de un conjunto de valores.
   - **Ejemplo**: Precio medio de compra de un producto.
   ```al
   field(50101; "Avg. Cost"; Decimal)
   {
       FieldClass = FlowField;
       CalcFormula = average("Item Ledger Entry"."Cost Amount (Actual)" where ("Item No." = field("No.")));
   }
   ```

3. **Exist (Existencia)**:
   - **Definición**: Devuelve un booleano (True/False) indicando si existen registros que cumplan el filtro.
   - **Ejemplo**: ¿Tiene el cliente movimientos registrados?
   ```al
   field(50102; "Has Entries"; Boolean)
   {
       FieldClass = FlowField;
       CalcFormula = exist("Item Ledger Entry" where ("Item No." = field("No.")));
   }
   ```

4. **Count (Contador)**:
   - **Definición**: Cuenta la cantidad exacta de registros que coinciden con la relación.
   - **Ejemplo**: Número de líneas de venta en un documento.
   ```al
   field(50103; "No. of Lines"; Integer)
   {
       FieldClass = FlowField;
       CalcFormula = count("Sales Line" where ("Document No." = field("No.")));
   }
   ```

5. **Min / Max (Extremos)**:
   - **Definición**: Localiza el valor más bajo o más alto (numérico o de fecha).
   - **Ejemplo**: Fecha de la primera contabilización en una cuenta contable.
   ```al
   field(50104; "First Posting Date"; Date)
   {
       FieldClass = FlowField;
       CalcFormula = min("G/L Entry"."Posting Date" where ("G/L Account No." = field("No.")));
   }
   ```

6. **Lookup (Búsqueda)**:
   - **Definición**: Recupera un valor (texto, código, etc.) de una tabla externa sin duplicar la información físicamente.
   - **Ejemplo**: Obtener el nombre del vendedor desde su tabla maestra.
   ```al
   field(50105; "Salesperson Name"; Text[100])
   {
       FieldClass = FlowField;
       CalcFormula = lookup(Salesperson.Name where (Code = field("Salesperson Code")));
   }
   ```

## 2. FlowFilters: Criterios Dinámicos de Filtrado

Los **FlowFilters** representan una de las características más potentes y singulares de AL. A diferencia de un campo normal que almacena valores en una base de datos, un FlowFilter es un campo "transitorio" cuya única función es capturar criterios de filtrado para inyectarlos en la lógica de cálculo de los FlowFields.

### 🧩 Naturaleza y Comportamiento Técnico
- **No persistencia**: Los valores que un usuario introduce en un FlowFilter no se guardan en el registro. Solo existen mientras dura la sesión o la vista actual.
- **Uso Estructural**: Se definen en la tabla con la propiedad `FieldClass = FlowFilter`, lo que permite que aparezcan en la interfaz de usuario (como filtros de página) y sean accesibles desde el código AL mediante `SetRange` o `SetFilter`.
- **Puente de Cálculo**: Actúan como un "cable de conexión" entre la interfaz y el motor de cálculo. Permiten que una misma fórmula (como un Saldo) devuelva resultados radicalmente distintos según el contexto de filtrado (ej. por almacén, por fecha o por proyecto).

### 📑 Tipos y Escenarios Comunes
- **Periodo (Date Filter)**: El uso más extendido. Permite análisis temporales sin duplicar datos.
- **Global Dimensions (Departamentos/Centros de Coste)**: Filtra resultados financieros por dimensiones específicas.
- **Ubicación (Location Filter)**: Filtra existencias de inventario por un almacén concreto.

### 📅 Desarrollo Técnico: Interacción con el Motor de Cálculo
Un FlowFilter solo cobra sentido cuando se menciona dentro de la propiedad `where` de un FlowField.

**1. Definición técnica en la Tabla:**
```al
// El campo no ocupa espacio en SQL, es solo una "ventana" de filtrado
field(100; "Date Filter"; Date) 
{ 
    FieldClass = FlowFilter; 
    Caption = 'Rango de Fecha de Análisis';
}
```

**2. Inyección en la Fórmula (FlowField):**
```al
// El FlowField de ventas usará el valor actual del "Date Filter"
field(101; "Ventas Netas"; Decimal)
{
    FieldClass = FlowField;
    CalcFormula = sum("Sales Invoice Line".Amount where ("Sell-to Customer No." = field("No."), 
                                                         "Posting Date" = field("Date Filter")));
}
```

**3. Aplicación desde el Código (Lógica Avanzada):**
```al
procedure ComparativaVentas(CustomerNo: Code[20])
var
    Cust: Record Customer;
    VentasEnero: Decimal;
    VentasFebrero: Decimal;
begin
    Cust.Get(CustomerNo);
    
    // Filtramos para Enero
    Cust.SetRange("Date Filter", 20240101D, 20240131D);
    Cust.CalcFields("Ventas Netas");
    VentasEnero := Cust."Ventas Netas";
    
    // Cambiamos el FlowFilter para Febrero
    Cust.SetRange("Date Filter", 20240201D, 20240229D);
    Cust.CalcFields("Ventas Netas");
    VentasFebrero := Cust."Ventas Netas";
    
    Message('Comparativa: Enero (%1) vs Febrero (%2)', VentasEnero, VentasFebrero);
end;
```

---

## 3. Triggers de Tabla: El Ciclo de Vida del Dato

Los triggers son eventos automáticos que se disparan ante acciones sobre los datos (CRUD).

### ⚡ Eventos Principales a Nivel de Tabla
A continuación, los 4 triggers estructurales con sus propósitos y ejemplos:

1. **OnInsert**: Se ejecuta antes de crear el registro.
   ```al
   trigger OnInsert()
   begin
       Rec."Created Date" := Today; // Asignación automática al crear
   end;
   ```

2. **OnModify**: Se dispara al registrar cambios en campos que no son clave.
   ```al
   trigger OnModify()
   begin
       Rec."Last Modified By" := UserId; // Auditoría de cambios
   end;
   ```

3. **OnDelete**: Se ejecuta antes del borrado físico.
   ```al
   trigger OnDelete()
   begin
       if Rec.Status = Rec.Status::Released then
           Error('No se puede borrar un registro lanzado.');
   end;
   ```

4. **OnRename**: Se activa al cambiar un campo de la Clave Primaria (PK).
   ```al
   trigger OnRename()
   begin
       Error('Los registros de esta tabla no pueden ser renombrados por integridad.');
   end;
   ```

### 🛠️ El Trigger OnValidate (Lógica de Negocio)
Es el disparador a nivel de campo. Se ejecuta cuando el usuario cambia un valor y este es validado.

**Ejemplo de Validación y Cálculo derivado:**
```al
field(50; "Discount %"; Decimal)
{
    trigger OnValidate()
    begin
        if (Rec."Discount %" > 50) then
            Error('Descuento máximo permitido: 50%.');
            
        // Se dispara validación en cascada para campos calculados
        Rec.Validate("Net Amount", Rec."Gross Amount" * (1 - (Rec."Discount %" / 100)));
    end;
}
```