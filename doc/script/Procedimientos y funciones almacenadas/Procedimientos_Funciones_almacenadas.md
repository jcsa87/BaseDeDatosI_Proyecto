## CAPÍTULO I: INTRODUCCIÓN
a. Tema

Este trabajo tiene como tema central el estudio de los procedimientos almacenados y las funciones definidas por el usuario en SQL Server, herramientas esenciales para la automatización, seguridad y eficiencia en el manejo de datos.

b. Definición o planteamiento del problema

Los sistemas modernos requieren consistencia, integridad y velocidad en sus operaciones.
Un Servicio Técnico Informático ejecuta tareas repetitivas como:

Registrar ingresos de equipos.

Crear diagnósticos y reparaciones.

Asociar repuestos.

Emitir facturas.

Registrar pagos.

Sin procedimientos y funciones, estas operaciones se realizan de forma manual, duplicando código y dificultando el mantenimiento del sistema.

Esto lleva a los interrogantes centrales:

¿Qué diferencias existen entre un procedimiento y una función?

¿Qué aporta cada uno al sistema?

¿Cómo se aplican al Servicio Técnico?

c. Objetivo del Trabajo Práctico

Analizar el uso de procedimientos y funciones en SQL Server, aplicándolos a tareas reales del sistema de Servicio Técnico Informático.

i. Objetivo General

Comprender cómo procedimientos y funciones almacenadas optimizan la lógica operativa del sistema de Servicio Técnico Informático.

ii. Objetivos Específicos

Describir qué es un procedimiento almacenado y cómo se implementa.

Identificar los tipos de funciones existentes en SQL Server.

Comparar técnicamente procedimientos y funciones.

Aplicarlos en ejemplos reales del Servicio Técnico.

Diseñar procedimientos para automatizar procesos operativos.

Crear funciones para cálculos frecuentes.

Evaluar su impacto en seguridad, rendimiento y mantenibilidad.

## CAPÍTULO II: MARCO CONCEPTUAL O REFERENCIAL

Los procedimientos almacenados y las funciones son componentes programables en SQL Server que permiten encapsular lógica de negocio y mejorar la eficiencia del sistema.

Procedimientos Almacenados

Un procedimiento almacenado es un conjunto precompilado de instrucciones SQL que:

Ejecuta operaciones DML.

Maneja transacciones.

Permite validaciones y control de flujo.

Encapsula tareas complejas.

Aplicaciones en el Servicio Técnico

Registrar ingreso de un equipo.

Finalizar reparación.

Actualizar stock.

Generar factura.

Registrar pagos.

Funciones Definidas por el Usuario (UDF)

Una función devuelve un valor o una tabla.
No modifica datos y puede usarse en:

SELECT

WHERE

JOIN

Aplicaciones en el Servicio Técnico

Total gastado por cliente.

Costo total de una reparación.

Repuestos utilizados.

Reparaciones por estado.

Diferencias Principales
Característica	Procedimiento	Función
Retorno	Múltiples valores	Un valor o tabla
Uso en SELECT	❌ No	✔️ Sí
Modificación de datos	✔️ Sí	❌ No
Transacciones	✔️ Sí	❌ No
Manejo de errores	✔️ Sí	❌ No
## CAPÍTULO III: METODOLOGÍA SEGUIDA
a. Descripción del proceso

El trabajo se desarrolló mediante:

Estudio de documentación oficial de Microsoft Learn.

Análisis del sistema real de Servicio Técnico Informático.

Pruebas con T-SQL en SQL Server.

Diseño de ejemplos aplicados al negocio.

Redacción formal siguiendo los lineamientos de la cátedra.

b. Herramientas utilizadas

SQL Server Management Studio (SSMS)

Microsoft Docs

Libros de bases de datos

Base de datos del Servicio Técnico Informático

## CAPÍTULO IV: DESARROLLO DEL TEMA / PRESENTACIÓN DE RESULTADOS

A continuación se presentan los resultados obtenidos mediante la aplicación de procedimientos y funciones al sistema de Servicio Técnico, mostrando su utilidad y aplicación real.

# 🔧 PROCEDIMIENTOS APLICADOS AL SISTEMA
### 1. Registrar Ingreso de Equipo
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

    SELECT 'Ingreso registrado correctamente' AS Resultado;
END;
GO

### 2. Finalizar Reparación, Generar Factura y Registrar Pago
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

        SELECT 'Reparación finalizada y factura generada' AS Resultado;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END;
GO

# 📘 FUNCIONES APLICADAS AL SISTEMA
### 1. Total Gastado por Cliente
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

### 2. Reparaciones por Estado
CREATE FUNCTION fn_ReparacionesPorEstado(@id_estado INT)
RETURNS TABLE
AS
RETURN
(
    SELECT r.id_reparacion, r.fecha_resolucion, r.monto_total
    FROM reparacion r
    WHERE r.id_estado_reparacion = @id_estado
);
GO

## CAPÍTULO V: CONCLUSIONES

Los procedimientos y funciones demostraron ser esenciales para organizar, automatizar y optimizar las tareas del Servicio Técnico Informático. Los procedimientos permitieron ejecutar operaciones complejas de forma segura mediante transacciones, mientras que las funciones ofrecieron cálculos reutilizables e integrables en consultas SQL.

En conjunto, fortalecen la arquitectura del sistema, mejoran el rendimiento y reducen errores humanos, ofreciendo un entorno más confiable y profesional.

## CAPÍTULO VI: BIBLIOGRAFÍA

Microsoft Docs – CREATE PROCEDURE (Transact-SQL)

Microsoft Docs – CREATE FUNCTION (Transact-SQL)

SQLShack – Calbimonte, D. (2019)

Elmasri & Navathe – Fundamentals of Database Systems

Coronel, C. – Database Systems
