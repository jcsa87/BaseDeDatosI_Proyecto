# Optimización de Consultas a través de Índices

## Objetivos
* Conocer los diferentes tipos de índices y sus aplicaciones.
* Evaluar el impacto de los índices en el rendimiento de las consultas.
* Medir correctamente los tiempos de respuesta y costos de E/S (Entrada/Salida) antes y después de aplicar índices.
* Documentar y analizar los planes de ejecución generados por el motor de SQL Server.

---

## ¿Qué es un Índice?
Un índice en una base de datos es una estructura de datos, similar al índice de un libro. En lugar de tener que leer cada página del libro (un Table Scan) para encontrar un tema, puedes ir al índice, encontrar la página exacta e ir directamente a ella (un Index Seek).

En SQL Server, esta estructura suele ser un Árbol B (B-Tree), que permite al motor de base de datos encontrar datos de manera muy eficiente, reduciendo el costo de la consulta en gran medida.

### Tipos de Estructuras Relevantes
Para este experimento, nos centramos en dos estados de una tabla:
* **Tabla HEAP (Prueba 1):** Es una tabla que no tiene un índice agrupado. Los datos no tienen un orden físico específico; simplemente se almacenan donde haya espacio.
* **Índice Agrupado (Prueba 2 y 3):** Esta es la tabla misma, ordenada físicamente. El índice *es* la tabla. Solo puede existir un índice agrupado por tabla.

---

## Metodología de Prueba
Para evaluar el impacto de los índices, se siguió un proceso controlado:
* **Base de Datos:** Se utilizó la base de datos de nuestro Servicio Técnico Informático.
* **Tabla:** `factura`, modificada para ser una tabla HEAP (sin índice agrupado inicial).
* **Carga de Datos:** Se realizó una carga masiva de 1,000,001 registros en la tabla factura, con fechas de emisión (fecha_emision) aleatorias.

### Consulta de Prueba
Se ejecutó la misma consulta en todos los escenarios, buscando un rango de fechas.

SELECT id_factura, id_cliente, fecha_emision
FROM factura
WHERE fecha_emision BETWEEN '2024-01-01' AND '2024-01-31';

### Estadísticas
Se registraron las siguientes estadísticas en cada prueba, limpiando el caché (DBCC DROPCLEANBUFFERS) antes de cada ejecución:
* **Plan de Ejecución:** La estrategia visual (el "cómo") que usó el motor.
* **Lecturas Lógicas:** El costo real (E/S). Mide cuántas páginas de 8KB se leyeron de la memoria. **Esta es la métrica más importante.**
* **Tiempos (CPU y Transcurrido):** La velocidad percibida.

---

## Resultados
La siguiente tabla compara los resultados de las tres pruebas ejecutadas.

| Prueba | Plan de Ejecución | Lecturas Lógicas | Tiempo CPU | Tiempo Transcurrido |
| :--- | :--- | :--- | :--- | :--- |
| **1. Sin Índice (HEAP)** | `Table Scan` | 3,248 | 78 ms | 190 ms |
| **2. Índice Agrupado Simple** | `Clustered Index Seek` | 55 | 0 ms | 144 ms |
| **3. Índice Agrupado Compuesto** | `Clustered Index Seek` | 55 | 0 ms | 148 ms |

---

## Análisis de Resultados y Conclusiones

### Prueba 1: Sin Índice
* **Plan:** Examen de tabla.
* **Análisis:** Al no tener un índice que la guíe, en la consulta se leyó la tabla entera (el 1,000,001 de filas) para encontrar las 16,505 que cumplían la condición. Esto se refleja en un costo de 3,248 lecturas lógicas y un tiempo de CPU de 78 ms. Fue un proceso ineficiente y costoso.

### Prueba 2: Con Índice Agrupado Simple
* **Plan:** Búsqueda en índice clúster.
* **Análisis:** Al crear un índice agrupado en la columna fecha_emision, la tabla se ordenó físicamente por fecha. El motor pudo "saltar" directamente al inicio del rango '2024-01-01' y leer solo hasta el final '2024-01-31'.
* **Impacto:** El costo de E/S colapsó. Pasamos de 3,248 lecturas lógicas a 55. Esto significa una reducción del 98.3% en el trabajo de E/S. El tiempo de CPU bajó a 0 ms.

### Prueba 3: Con Índice Agrupado Compuesto (La Optimización)
* **Plan:** `Clustered Index Seek` (Búsqueda en índice clúster).
* **Análisis:** Se creó un índice sobre las columnas fecha_emision, id_cliente, id_factura. Los resultados fueron casi idénticos a la Prueba 2 (55 lecturas lógicas).
* **Conclusión:** Para esta consulta específica, la ganancia de rendimiento ya se había obtenido en la Prueba 2, porque la cláusula WHERE solo usaba la primera columna del índice (fecha_emision).

---

## Conclusión Final
El experimento demuestra el impacto de una correcta indexación. El simple hecho de definir un índice agrupado en la columna de filtrado (el WHERE) redujo el costo de la consulta en más de un 98%.

El análisis de los planes de ejecución confirmó la diferencia en la estrategia: se pasó de un costoso Table Scan (leer todo) a un eficiente Index Seek (ir al grano). Esto demuestra que la optimización de consultas a través de índices es una de las técnicas más importantes para garantizar el rendimiento de una base de datos.
