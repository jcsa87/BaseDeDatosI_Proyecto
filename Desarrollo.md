# Desarrollo: Procedimientos y Funciones en SQL Server

## 🧠 Contexto General

Dentro del entorno de las bases de datos relacionales, **SQL Server** ofrece mecanismos avanzados para encapsular la lógica de negocio a través de **procedimientos almacenados** (*stored procedures*) y **funciones definidas por el usuario** (*user-defined functions*).  
Ambos son componentes esenciales para la **modularización, reutilización y optimización** del código SQL, permitiendo que las aplicaciones deleguen el procesamiento de datos directamente al servidor, reduciendo la carga del cliente y mejorando la eficiencia global del sistema.

Los procedimientos y funciones no solo promueven una arquitectura más limpia, sino que también forman parte de las **mejores prácticas de diseño de bases de datos empresariales**, facilitando la seguridad, la consistencia y la trazabilidad del acceso a los datos.

---

## ⚙️ Procedimientos Almacenados (Stored Procedures)

Un **procedimiento almacenado** es un conjunto precompilado de instrucciones SQL que se almacena en la base de datos y puede ejecutarse bajo demanda.  
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

### 🔸 Ejemplo Práctico: Control de Transacciones

```sql
CREATE PROCEDURE TransferirFondos
    @CuentaOrigen INT,
    @CuentaDestino INT,
    @Monto DECIMAL(10,2)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Cuentas SET Saldo = Saldo - @Monto WHERE ID = @CuentaOrigen;
        UPDATE Cuentas SET Saldo = Saldo + @Monto WHERE ID = @CuentaDestino;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
```

Este procedimiento garantiza la **atomicidad de la transacción**: si una operación falla, se revierten todas las modificaciones.

---

## 🧩 Funciones Definidas por el Usuario (User-Defined Functions, UDF)

Las **funciones** en SQL Server son bloques de código que reciben parámetros, realizan cálculos o consultas, y **devuelven un valor** (escalar o conjunto de resultados).  
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

2. **Funciones con valor de tabla en línea (Inline Table-Valued Functions):** devuelven una tabla derivada.
   ```sql
   CREATE FUNCTION dbo.fn_ClientesActivos()
   RETURNS TABLE
   AS
   RETURN (SELECT * FROM Clientes WHERE Activo = 1);
   ```

3. **Funciones con valor de tabla múltiples instrucciones (Multi-Statement Table-Valued Functions):**  
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

---

## 🔍 Comparativa Práctica: Procedimientos vs. Funciones

| Aspecto | Procedimientos Almacenados | Funciones |
|----------|----------------------------|------------|
| **Compilación** | Precompilados, almacenados como objetos en la base. | También precompiladas, pero más restringidas. |
| **Uso en Consultas** | No se pueden usar dentro de `SELECT`. | Se pueden usar en cualquier expresión SQL. |
| **Operaciones DML** | Permiten `INSERT`, `UPDATE`, `DELETE`. | Solo lectura (salvo excepciones). |
| **Errores y Excepciones** | Soportan `TRY...CATCH`. | No soportan `TRY...CATCH`. |
| **Retorno de Valores** | Devuelven 0, 1 o varios resultados. | Devuelven exactamente un valor (o tabla). |

---

## 💡 Casos de Uso Reales

1. **Auditoría y control de acceso:** procedimientos que registran cada operación en un log de auditoría.  
2. **Reportes automatizados:** funciones que calculan totales o promedios dinámicos para dashboards.  
3. **ETL (Extract, Transform, Load):** procedimientos que extraen datos, los limpian y los cargan en un almacén de datos.  
4. **Mantenimiento de datos:** ejecución programada de procedimientos de limpieza o archivado.  
5. **Validación de integridad:** funciones que validan reglas de negocio antes de las inserciones.

---

## ⚙️ Integración con Aplicaciones

Tanto las funciones como los procedimientos pueden ser invocados desde **lenguajes de programación** (C#, Python, PHP, Java, etc.) mediante **llamadas parametrizadas**.  
Esto permite separar la **lógica de negocio del código de aplicación**, centralizando el control en la base de datos y aumentando la seguridad.

Ejemplo en C#:

```csharp
using (SqlCommand cmd = new SqlCommand("GetUserData", connection))
{
    cmd.CommandType = CommandType.StoredProcedure;
    cmd.Parameters.AddWithValue("@UserID", 1);
    SqlDataReader reader = cmd.ExecuteReader();
}
```

---

## 🧱 Buenas Prácticas de Implementación

- Utilizar **nombres significativos** y convenciones estandarizadas (`sp_`, `fn_`, `udf_`, etc.).  
- Documentar los procedimientos con **comentarios** de propósito, parámetros y autor.  
- Evitar el uso de **cursores** y preferir operaciones basadas en conjuntos.  
- Asegurar que las **funciones sean deterministas** para optimizar su rendimiento.  
- Validar parámetros de entrada para prevenir errores y ataques SQL Injection.  

---

## 📊 Desempeño y Optimización

- **Plan de ejecución:** ambos objetos generan planes reutilizables que se almacenan en caché.  
- **Parámetros de sniffing:** en procedimientos complejos, el optimizador puede reutilizar planes de forma ineficiente; se puede mitigar con `OPTION (RECOMPILE)`.  
- **Índices y estadísticas actualizadas:** las funciones con operaciones de lectura dependen de índices eficientes.  
- **Escalabilidad:** es recomendable mantener las funciones pequeñas y puras; los procedimientos deben agrupar operaciones coherentes.

---

## 🧩 Integración con Seguridad

Los procedimientos y funciones permiten encapsular acceso a datos confidenciales, asignando permisos sobre el **objeto** en lugar de sobre las **tablas**.  
Esto facilita una administración más granular de usuarios y roles.

```sql
GRANT EXECUTE ON OBJECT::GetAccountBalance TO AnalistaFinanciero;
```

De esta forma, el analista puede ejecutar el procedimiento sin tener acceso directo a la tabla `Cuentas`.

---

## 🧾 Conclusión Preliminar

Los procedimientos y funciones son herramientas complementarias que, utilizadas correctamente, **incrementan la eficiencia, la seguridad y la organización** de cualquier sistema de base de datos.  
En sistemas empresariales, constituyen la base para implementar **reglas de negocio centralizadas** y **procesos automatizados**.  
En el siguiente capítulo se abordará una conclusión integradora sobre su papel en la arquitectura de software moderna.

---

<p align="center">
  <a href="Introduccion.md" style="text-decoration:none; margin-right:20px;">
    <img src="https://img.shields.io/badge/Capítulo%20Anterior-Introducción-666666?style=for-the-badge" alt="Anterior">
  </a>
  <a href="Conclusion.md" style="text-decoration:none;">
    <img src="https://img.shields.io/badge/Siguiente%20Capítulo-Conclusion-0088cc?style=for-the-badge" alt="Siguiente">
  </a>
</p>

---

### 📚 Referencias

- Microsoft Learn. [CREATE PROCEDURE (Transact‑SQL)](https://learn.microsoft.com/es-es/sql/t-sql/statements/create-procedure-transact-sql)  
- Microsoft Learn. [CREATE FUNCTION (Transact‑SQL)](https://learn.microsoft.com/es-es/sql/t-sql/statements/create-function-transact-sql)  
- Calbimonte, D. *Funciones frente a los procedimientos almacenados en SQL Server*, SQLShack (2019).  
- Ramakrishnan, R. & Gehrke, J. *Database Management Systems*, McGraw-Hill, 2010.  
- Elmasri, R. & Navathe, S. *Fundamentals of Database Systems*, Pearson, 2017.  
- Coronel, C. *Database Systems: Design, Implementation, and Management*, Cengage, 2020.  
