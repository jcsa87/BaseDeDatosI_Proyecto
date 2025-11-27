## Procedimientos y Funciones almacenadas

Los **procedimientos almacenados** y las **funciones** en SQL Server son bloques de código **T‑SQL precompilados** que se guardan directamente dentro de la base de datos. Estos permiten encapsular **lógica de negocio**, realizar **operaciones de datos** repetitivas y mejorar el **rendimiento, la seguridad y la reutilización del código**.
Aunque ambos comparten características similares, existen **diferencias clave** en su propósito y forma de uso.
Por ejemplo, un procedimiento puede realizar la inserción, validación y actualización de registros en una sola ejecución, reduciendo la redundancia y centralizando la lógica.
En cambio, una **función** devuelve un **resultado inmediato** a partir de parámetros de entrada y puede integrarse en otras consultas SQL.
Las funciones son útiles para realizar cálculos o devolver subconjuntos de datos, como conversiones, totales o promedios.


### ¿Por qué son importantes?

Una base de datos profesional no solo almacena información: también debe procesarla, validarla y mantenerla coherente. Aquí es donde procedimientos y funciones marcan una diferencia real.

📌 Los procedimientos permiten realizar operaciones como:

- registrar el ingreso de un equipo
- finalizar una reparación
- generar una factura
- aplicar un pago
- descontar stock de repuestos
- registrar auditorías

📌 Las funciones permiten:

- calcular valores
- aplicar filtros avanzados
- generar tablas derivadas
- unificar lógica repetitiva

Ambas herramientas forman un puente entre los datos crudos y la lógica del negocio.


## Procedimientos Almacenados (Stored Procedures)

Su propósito es **automatizar operaciones complejas** o de uso frecuente, como validaciones, transacciones o generación de reportes.

### 🔸 Ventajas Principales

- **Rendimiento optimizado:** al estar precompilados, su ejecución es más rápida.
- **Menor tráfico de red:** se ejecutan directamente en el servidor.
- **Seguridad y control:** los usuarios pueden tener permiso de ejecución sin acceder a las tablas subyacentes.
- **Reutilización del código:** se pueden invocar desde múltiples aplicaciones o procesos.

### 🔸 Estructura General

```sql
CREATE PROCEDURE NombreProcedimiento
    @Parametro1 INT,
    @Parametro2 VARCHAR(50)
AS
BEGIN
    -- Bloque de instrucciones SQL
    SELECT * FROM Tabla WHERE Columna1 = @Parametro1;
END

```

## Funciones Definidas por el Usuario (User-Defined Functions, UDF)

Son útiles para tareas deterministas o reutilizables dentro de otras consultas.

### 🔸 Tipos de Funciones

1. **Funciones escalares:** devuelven un único valor.
    
    ```sql
    CREATE FUNCTION dbo.fn_Sumar(@a INT, @b INT)
    RETURNS INT
    AS
    BEGIN
        RETURN (@a + @b);
    END;
    
    ```
    
2. **Funciones con valor de tabla en línea:**  devuelven una tabla derivada.
    
    ```sql
    CREATE FUNCTION dbo.fn_ClientesActivos()
    RETURNS TABLE
    AS
    RETURN (SELECT * FROM Clientes WHERE Activo = 1);
    
    ```
    
3. **Funciones con valor de tabla múltiples instrucciones:**
    
    permiten construir tablas temporales antes de devolver los resultados.
    
    ```sql
    CREATE FUNCTION dbo.fn_ProductosPorCategoria(@CategoriaID INT)
    RETURNS @TablaResultado TABLE (Nombre NVARCHAR(50), Precio DECIMAL(10,2))
    AS
    BEGIN
        INSERT INTO @TablaResultado
        SELECT Nombre, Precio FROM Productos WHERE CategoriaID = @CategoriaID;
        RETURN;
    END;
    
    ```
    

### 🔸 Características Esenciales

- Se pueden usar directamente en consultas (`SELECT`, `WHERE`, `JOIN`).
- No permiten modificar datos permanentemente dentro de su cuerpo.
- Son ideales para cálculos repetitivos o filtros lógicos comunes.


## Casos de Uso

1. **Auditoría y control de acceso:** procedimientos que registran cada operación en un log de auditoría.
2. **Reportes automatizados:** funciones que calculan totales o promedios dinámicos para dashboards.
3. **ETL (Extract, Transform, Load):** procedimientos que extraen datos, los limpian y los cargan en un almacén de datos.
4. **Mantenimiento de datos:** ejecución programada de procedimientos de limpieza o archivado.
5. **Validación de integridad:** funciones que validan reglas de negocio antes de las inserciones.


## Ejemplo de uso - Servicio técnico Informático

### Procedimientos Almacenados

📌 Registrar Ingreso de Equipo

(Automatiza la creación del registro de ingreso, evitando duplicación de lógica)

CREATE PROCEDURE RegistrarIngresoEquipo
@id_cliente INT,
@id_equipo INT,
@falla VARCHAR(255)
AS
BEGIN
DECLARE @nuevoIngresoID INT;

```
SELECT @nuevoIngresoID = ISNULL(MAX(id_ingreso_equipo), 0) + 1
FROM ingreso_equipo
WHERE id_cliente = @id_cliente
  AND id_equipo = @id_equipo;

INSERT INTO ingreso_equipo (id_ingreso_equipo, falla, id_cliente, id_equipo)
VALUES (@nuevoIngresoID, @falla, @id_cliente, @id_equipo);

```

END;
GO

### Funciones

📌 Total gastado por cliente

(Ideal para reportes y cálculos en dashboards o listados)

CREATE FUNCTION fn_TotalGastadoCliente(@id_cliente INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
RETURN (
SELECT ISNULL(SUM(p.monto),0)
FROM pago p
JOIN factura f ON f.id_factura = p.id_factura
WHERE f.id_cliente = @id_cliente
);
END;
GO

📌 Lista de reparaciones por estado

(Útil para tableros de gestión o reportes internos)

CREATE FUNCTION fn_ReparacionesPorEstado(@estado INT)
RETURNS TABLE
AS
RETURN (
SELECT *
FROM reparacion
WHERE id_estado_reparacion = @estado
);


## Conclusión

Los **procedimientos almacenados** y **funciones** son herramientas esenciales en la administración moderna de bases de datos. Mientras los procedimientos almacenados ofrecen **flexibilidad y control transaccional**, las funciones destacan por su **facilidad de integración y eficiencia en cálculos**.

Ambos, correctamente implementados, fortalecen la arquitectura de datos y promueven la **consistencia, rendimiento y seguridad** del sistema.
