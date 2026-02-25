# Plan de Acción: Unificación de Documentación "BC Guide"

Este plan detalla los pasos para fusionar los cuatro archivos de documentación técnica en un único archivo maestro (`guia_bc.md`), garantizando la preservación total del contenido y la limpieza de formato solicitada.

## 1. Fase de Preparación y Estructura
- **Creación del archivo maestro**: Se inicializará `guia_bc.md` con un encabezado principal y un **Índice Global**.
- **Mapeo de Secciones**: Cada archivo original se asignará a una sección principal del documento:
    1. `tablas_enums_tiposDato.md` -> Sección 1: Estructura de Datos (Ángel).
    2. `apuntes_bc.md` -> Sección 2: Lógica de Datos (Carlos).
    3. `laura_issue3_pages_factboxes.md` -> Sección 3: Interfaz de Usuario (Laura).
    4. `Alejo-Análisis e Informes Queries y Reports.md` -> Sección 4: Análisis e Informes (Alejo/Daniel).
    5. Contenido adicional de Alejandro (Entorno y Defensa) -> Sección 5.

## 2. Fase de Procesamiento de Contenido (Por cada archivo)
Para garantizar el cumplimiento de las reglas del usuario, se aplicará el siguiente proceso a cada bloque de texto:
- **Preservación Íntegra**: Se mantendrá cada línea de texto, respetando tablas, párrafos y listas.
- **Limpieza de Emojis**: Se eliminarán todos los caracteres de tipo emoji para mantener un tono profesional.
- **Estandarización de Código**: Todos los bloques de código (AL, bash u otros) se unificarán bajo la etiqueta ` ```bash `.
- **Ajuste de Referencias**: Los índices internos de cada archivo se ajustarán para que las anclas funcionen dentro del documento unificado.

## 3. Ejecución por Fases (Control de Tamaño)
Debido a que el volumen total supera las 2000 líneas, la escritura se realizará en pasos para evitar límites de la herramienta:
1. **Paso 1**: Crear `guia_bc.md` con el índice y el contenido de Ángel.
2. **Paso 2**: Insertar el contenido de Carlos tras la sección 1.
3. **Paso 3**: Insertar el contenido de Laura (el más extenso) tras la sección 2.
4. **Paso 4**: Insertar el contenido de Alejo/Daniel tras la sección 3.
5. **Paso 5**: Revisión final de anclas y formato.

## 4. Verificación de Criterios de Aceptación
- [ ] ¿Están todas las líneas de los 4 archivos originales?
- [ ] ¿Se han eliminado todos los emojis?
- [ ] ¿Todos los bloques de código tienen el formato `.bash`?
- [ ] ¿El índice es funcional?
- [ ] ¿Se mantiene el diseño unificado?
