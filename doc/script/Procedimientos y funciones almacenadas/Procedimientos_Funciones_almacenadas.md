## 📑 Índice

CAPÍTULO I: INTRODUCCIÓN

CAPÍTULO II: MARCO CONCEPTUAL

CAPÍTULO III: METODOLOGÍA

CAPÍTULO IV: DESARROLLO

Procedimientos aplicados al sistema

Funciones aplicadas al sistema

CAPÍTULO V: CONCLUSIONES

CAPÍTULO VI: BIBLIOGRAFÍA

# CAPÍTULO I: INTRODUCCIÓN
a. Tema

El presente trabajo aborda el estudio de los procedimientos almacenados y las funciones definidas por el usuario en SQL Server. Ambos constituyen herramientas esenciales para la automatización, seguridad y eficiencia en la gestión de datos dentro de sistemas informáticos.

b. Definición o planteamiento del problema

Los sistemas informáticos requieren procesos eficientes, confiables y seguros para el manejo de la información.
En un Servicio Técnico Informático, donde numerosas operaciones se realizan diariamente, la ausencia de procedimientos y funciones genera:

procesos manuales repetitivos

mayor probabilidad de errores

pérdida de tiempo

lógica de negocio dispersa

consultas duplicadas

dificultades de mantenimiento

El sistema debe ejecutar tareas como:

registrar ingresos de equipos

crear diagnósticos

gestionar reparaciones

asociar repuestos

emitir facturas

registrar pagos

Esto conduce a varias preguntas fundamentales:

Interrogantes centrales

¿Qué diferencias existen entre un procedimiento y una función dentro de SQL Server?

¿De qué manera contribuyen a mejorar la eficiencia y consistencia del sistema?

¿Cómo afectan al rendimiento cuando la cantidad de datos crece significativamente?

¿Qué impacto tienen en la seguridad y el control de accesos?

¿Qué riesgos existen al depender excesivamente de lógica almacenada en la base de datos?

¿Qué prácticas garantizan su eficiencia a largo plazo?

c. Objetivos
Objetivo General

Analizar el uso, beneficios y limitaciones de los procedimientos y funciones almacenadas en SQL Server, aplicados al sistema de Servicio Técnico Informático.

Objetivos Específicos

Comprender las características principales de procedimientos y funciones.

Analizar sus diferencias y usos recomendados.

Aplicarlos al caso del Servicio Técnico Informático.

Diseñar procedimientos para automatizar procesos concretos.

Implementar funciones para cálculos y filtros reutilizables.

Evaluar su impacto en rendimiento, seguridad y mantenibilidad.

Identificar riesgos y buenas prácticas asociadas a su uso.

# CAPÍTULO II: MARCO CONCEPTUAL

Los procedimientos almacenados y las funciones definidas por el usuario son componentes programables del motor SQL que permiten encapsular lógica dentro de la base de datos, optimizando su uso y organización.

## 1. Procedimientos Almacenados (Stored Procedures)

Un procedimiento almacenado es un conjunto de instrucciones T-SQL precompiladas, guardadas en el servidor, diseñadas para automatizar tareas y ejecutar procesos complejos.

1.1. Características

Plan de ejecución precompilado y cacheado

Encapsulamiento de lógica empresarial

Permiten transacciones completas (BEGIN TRAN / COMMIT / ROLLBACK)

Manejo de errores con TRY/CATCH

Pueden modificar datos: INSERT, UPDATE, DELETE

Permiten parámetros de entrada y salida

Pueden retornar uno o varios conjuntos de resultados

1.2. Ventajas

Mejoran el rendimiento en sistemas con alto volumen de consultas

Reducen tráfico de red

Centralizan la lógica del negocio

Mejoran la seguridad al evitar acceso directo a las tablas

Facilitan el mantenimiento del sistema

Permiten modularidad y reutilización

1.3. Limitaciones

No pueden integrarse directamente en una consulta SELECT

Excesiva lógica en la base puede dificultar el versionado

Un mal diseño puede causar problemas de rendimiento (parameter sniffing)

## 2. Funciones Definidas por el Usuario (User-Defined Functions, UDF)

Una función es una rutina T-SQL que recibe parámetros y devuelve un valor escalar o una tabla.

2.1. Características

Uso dentro de SELECT, WHERE, JOIN, ORDER BY

No pueden modificar datos permanentemente

No permiten TRY/CATCH

Lógicas deterministas y reutilizables

Ideales para cálculos y filtros repetitivos

2.2. Tipos de funciones

Escalares → devuelven un solo valor

Inline Table-Valued (iTVF) → más eficientes, tratadas como vistas parametrizadas

Multi-Statement Table-Valued (mTVF) → permiten múltiples pasos internos

2.3. Ventajas

Facilitan la estandarización de cálculos

Mejoran la legibilidad de consultas complejas

Reducen duplicación de lógica

Se integran fácilmente en cualquier consulta SQL

2.4. Limitaciones

No pueden usar transacciones

No pueden ejecutar operaciones DML permanentes

Las mTVF pueden afectar el rendimiento

## 3. Comparación ampliada
Aspecto	Procedimiento	Función
Manejo de errores	✔️ TRY/CATCH	❌ No
Transacciones	✔️ Sí	❌ No
Modificación de datos	✔️ Sí	❌ No
Uso en SELECT	❌ No	✔️ Sí
Retorno	Opcional	Obligatorio
Seguridad	Alta (control granular)	Media
Escenarios ideales	Procesos complejos	Cálculos y filtros
## 4. Importancia práctica

Procedimientos y funciones son esenciales para:

Automatizar tareas recurrentes

Garantizar integridad y consistencia

Aumentar seguridad

Reducir tiempos de respuesta

Evitar duplicación de código

Facilitar escalabilidad

Asegurar mantenibilidad a largo plazo

En sistemas reales como el Servicio Técnico Informático cumplen un rol crítico al organizar procesos como ingresos, reparaciones, pagos y reportes internos.

# CAPÍTULO III: METODOLOGÍA
a. Descripción del proceso

La investigación se desarrolló mediante:

revisión bibliográfica

análisis de la base de datos del Servicio Técnico

diseño de ejemplos reales

ejecución de pruebas en SQL Server

comparación entre consultas tradicionales vs. procedimientos/funciones

evaluación de rendimiento

b. Herramientas utilizadas

SQL Server Management Studio

Documentación oficial de Microsoft

Libros académicos de bases de datos

Diagramas y scripts del Servicio Técnico

# CAPÍTULO IV: DESARROLLO

A continuación se presentan ejemplos prácticos aplicados al sistema.

## Procedimientos aplicados al sistema
### 🔧 1. Registrar Ingreso de Equipo
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

### 🔧 2. Finalizar Reparación y Registrar Pago
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

## Funciones aplicadas al sistema
### 📘 1. Total gastado por cliente
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

### 📘 2. Reparaciones por estado
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

# CAPÍTULO V: CONCLUSIONES

Los procedimientos y funciones almacenadas cumplen un papel fundamental dentro del diseño de bases de datos modernas, especialmente en sistemas con alta carga operativa como un Servicio Técnico Informático.

Su uso permite:

automatizar procesos críticos

mejorar el rendimiento

reforzar la seguridad

reducir errores humanos

centralizar lógica

facilitar la escalabilidad del sistema

La evidencia muestra que integrar estas herramientas desde el inicio favorece un desarrollo más sólido, sustentable y profesional.

# CAPÍTULO VI: BIBLIOGRAFÍA

Microsoft Docs — CREATE PROCEDURE (Transact-SQL)

Microsoft Docs — CREATE FUNCTION (Transact-SQL)

SQLShack — Calbimonte, D.

Elmasri & Navathe — Fundamentals of Database Systems

Coronel — Database Systems
