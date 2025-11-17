📘 Introducción

Los procedimientos almacenados y las funciones definidas por el usuario (UDF) en SQL Server son bloques de código T-SQL precompilados que viven dentro de la base de datos. A través de ellos es posible:

- encapsular lógica de negocio

- automatizar tareas repetitivas

- reducir errores

- mejorar rendimiento

- reforzar la seguridad

- organizar procesos complejos

En sistemas como un Servicio Técnico Informático, donde continuamente se registran ingresos de equipos, diagnósticos, reparaciones, repuestos y pagos, estas herramientas se vuelven esenciales para estandarizar procesos y mantener la consistencia.

⚙️ ¿Por qué son importantes?

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

🧠 Conceptos Fundamentales
Procedimientos Almacenados (Stored Procedures)

Un procedimiento almacenado es un bloque de instrucciones SQL que se guarda dentro del servidor y se ejecuta mediante:

EXEC NombreProcedimiento

⭐ Características principales

- Código precompilado (más rápido)

- Manejo de transacciones: BEGIN TRAN

- Manejo de errores: TRY...CATCH

- Permiten modificar datos

- Parámetros de entrada y salida

- Permiten múltiples operaciones en cadena

⭐ Ventajas

- Estandarizan procesos críticos

- Evitan duplicación de código

- Mejoran la seguridad

- Reducen tráfico cliente-servidor

- Facilitan trazabilidad y auditoría

  Funciones (User Defined Functions)

Una función devuelve siempre un valor: escalar o tabla. Se utiliza dentro de una sentencia SQL como:

SELECT dbo.MiFuncion(…)

⭐ Tipos de funciones

- Escalares → devuelven un valor simple

- Inline Table-Valued → devuelven una tabla derivada

- Multi-Statement TVF → permiten lógica más compleja interna

⭐ Características

- No pueden modificar datos

- No permiten TRY/CATCH

- Son deterministas

Ideales para cálculos repetitivos o filtros reutilizables

⚙️ Diferencias Clave entre Procedimientos y Funciones
Característica	Procedimiento	Función
Retorno	Opcional	Obligatorio
Uso en SELECT	❌ No	✔️ Sí
Modificación de datos	✔️ Sí	❌ No
Manejo de errores	✔️ TRY/CATCH	❌ No
Transacciones	✔️ Sí	❌ No
Uso ideal	Procesos complejos	Cálculos y filtros
🔎 Preguntas que guían la investigación

Para comprender el impacto real de estas herramientas, surgen preguntas fundamentales:

❓ ¿Cómo afectan al rendimiento cuando los datos crecen?
❓ ¿Qué rol cumplen en la seguridad del sistema?
❓ ¿Cuándo conviene usar un procedimiento y cuándo una función?
❓ ¿Qué riesgos existen si se abusa de lógica almacenada?
❓ ¿Cómo mantenerlos eficientes a largo plazo?
🔧 Aplicación al Sistema de Servicio Técnico Informático

A continuación se muestran ejemplos reales basados en tu base de datos.

🔧 Procedimientos Almacenados — Ejemplos Reales
📌 Registrar Ingreso de Equipo

(Automatiza la creación del registro de ingreso, evitando duplicación de lógica)

CREATE PROCEDURE RegistrarIngresoEquipo
    @id_cliente INT,
    @id_equipo INT,
    @falla VARCHAR(255)
AS
BEGIN
    DECLARE @nuevoIngresoID INT;

    SELECT @nuevoIngresoID = ISNULL(MAX(id_ingreso_equipo), 0) + 1
    FROM ingreso_equipo
    WHERE id_cliente = @id_cliente 
      AND id_equipo = @id_equipo;

    INSERT INTO ingreso_equipo (id_ingreso_equipo, falla, id_cliente, id_equipo)
    VALUES (@nuevoIngresoID, @falla, @id_cliente, @id_equipo);
END;
GO

📌 Finalizar Reparación (actualiza estado + factura + pago)

(Control transaccional completo: si algo falla, se revierte todo)

CREATE PROCEDURE FinalizarReparacion
    @id_reparacion INT,
    @monto DECIMAL(10,2),
    @id_medio_pago INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE reparacion
        SET fecha_resolucion = GETDATE(),
            monto_total = @monto,
            id_estado_reparacion = 3
        WHERE id_reparacion = @id_reparacion;

        DECLARE @cliente INT;

        SELECT @cliente = c.id_cliente
        FROM reparacion r
        JOIN diagnostico d ON r.id_diagnostico = d.id_diagnostico
        JOIN equipo e ON d.id_equipo = e.id_equipo
        JOIN cliente c ON c.id_cliente = e.id_cliente
        WHERE r.id_reparacion = @id_reparacion;

        INSERT INTO factura (id_cliente) VALUES (@cliente);
        DECLARE @facturaID INT = SCOPE_IDENTITY();

        INSERT INTO pago (id_medio_de_pago, id_factura, monto, id_reparacion)
        VALUES (@id_medio_pago, @facturaID, @monto, @id_reparacion);

        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END;
GO

📘 Funciones — Ejemplos Reales
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

🔐 Buenas Prácticas

- Usar nombres descriptivos:
sp_RegistrarIngreso, fn_TotalReparaciones

- Validar parámetros de entrada

- Evitar lógica innecesaria en funciones

- Manejar transacciones en procedimientos críticos

- Documentar cada procedimiento/función

🧾 Conclusión

Los procedimientos y funciones almacenadas son herramientas esenciales para construir sistemas robustos. Dentro del Servicio Técnico Informático permiten:

- automatizar tareas clave

- reducir errores

- organizar la lógica del negocio

- reforzar la seguridad

- mejorar la eficiencia

- facilitar la escalabilidad

Su correcta implementación garantiza un sistema profesional, mantenible y eficiente.

📚 Referencias

Microsoft Docs – CREATE PROCEDURE

Microsoft Docs – CREATE FUNCTION

SQLShack – Calbimonte

Elmasri & Navathe – Database Systems

Coronel – Database Design and Implementation
