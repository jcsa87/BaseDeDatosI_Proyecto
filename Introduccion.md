# Introducción a las Funciones y Procedimientos Almacenados en SQL

## 📘 Introducción

Los **procedimientos almacenados** y las **funciones** en SQL Server son bloques de código **T‑SQL precompilados** que se guardan directamente dentro de la base de datos. Estos permiten encapsular **lógica de negocio**, realizar **operaciones de datos** repetitivas y mejorar el **rendimiento, la seguridad y la reutilización del código**.  
Aunque ambos comparten características similares, existen **diferencias clave** en su propósito y forma de uso.

---

## ⚙️ Diferencias Clave entre Procedimientos y Funciones

| Característica | Procedimientos Almacenados (Stored Procedures) | Funciones (Functions) |
|----------------|-----------------------------------------------|------------------------|
| **Valor de Retorno** | Pueden devolver cero, uno o múltiples valores (por parámetros o conjuntos de resultados). No es obligatorio. | Deben devolver un único valor (escalar o tabla). |
| **Uso en Consultas** | No pueden usarse directamente en `SELECT`, `WHERE` o `JOIN`; se ejecutan con `EXEC` o `EXECUTE`. | Pueden usarse directamente en consultas SQL. |
| **Modificación de Datos (DML)** | Pueden realizar `INSERT`, `UPDATE`, `DELETE` y manejar transacciones. | No pueden modificar datos, salvo funciones con valor de tabla en línea. |
| **Manejo de Errores** | Permiten `TRY...CATCH` y `RAISEERROR`. | No admiten bloques de manejo de errores. |
| **Parámetros de Salida** | Admiten parámetros de entrada y salida (`OUTPUT`). | Solo parámetros de entrada. |
| **Flexibilidad** | Alta: se usan para lógica compleja o tareas transaccionales. | Más rígidas, ideales para cálculos deterministas. |

---

## 🧠 Conceptos Fundamentales

Un **procedimiento almacenado** es un conjunto de sentencias SQL que se **almacenan** y **ejecutan bajo demanda** dentro de una base de datos.  
Por ejemplo, un procedimiento puede realizar la inserción, validación y actualización de registros en una sola ejecución, reduciendo la redundancia y centralizando la lógica.

En cambio, una **función** devuelve un **resultado inmediato** a partir de parámetros de entrada y puede integrarse en otras consultas SQL.  
Las funciones son útiles para realizar cálculos o devolver subconjuntos de datos, como conversiones, totales o promedios.

---

## 💾 Ejemplo de Procedimiento Almacenado

```sql
CREATE PROCEDURE GetUserData 
    @UserID INT
AS
BEGIN
    SELECT * FROM Users WHERE UserID = @UserID;
END;

-- Ejecución
EXEC GetUserData @UserID = 1;
```

Este procedimiento devuelve la información del usuario cuyo `UserID` se pasa como parámetro.

---

## 🧮 Ejemplo de Función Escalar

```sql
CREATE FUNCTION dbo.f_CelsiusToFahrenheit(@celsius FLOAT)
RETURNS FLOAT
AS
BEGIN
    RETURN (@celsius * 1.8 + 32);
END;

-- Uso
SELECT dbo.f_CelsiusToFahrenheit(0) AS Fahrenheit;
```

Esta función devuelve el resultado de una conversión de temperatura directamente en una consulta.

---

## 🧩 Procedimientos Almacenados vs. Funciones: Comparativa Práctica

1. **Llamada e invocación**
   - Procedimiento: `EXEC NombreProcedimiento`
   - Función: puede llamarse dentro de `SELECT` o expresiones SQL.

2. **Reusabilidad**
   - Las funciones se integran fácilmente en expresiones o cálculos.
   - Los procedimientos permiten un control más avanzado del flujo (condiciones, errores, transacciones).

3. **Anidamiento**
   - Una función **no puede invocar procedimientos**, pero un procedimiento **sí puede llamar funciones** o incluso otros procedimientos.

4. **Ejemplo comparativo "Hello World"**

```sql
-- Procedimiento
CREATE PROCEDURE HelloWorldProc AS PRINT 'Hello World';
EXEC HelloWorldProc;

-- Función
CREATE FUNCTION HelloWorldFunc() RETURNS VARCHAR(20) AS
BEGIN
    RETURN 'Hello World';
END;
SELECT dbo.HelloWorldFunc();
```

---

## 🔐 Ventajas del Uso de Procedimientos y Funciones

- **Reutilización del código:** Evita escribir múltiples veces las mismas consultas.
- **Optimización del rendimiento:** Código precompilado y ejecutado en el servidor.
- **Seguridad:** Controla el acceso a los datos a través de roles y permisos de ejecución.
- **Mantenibilidad:** Centraliza la lógica de negocio en la base de datos.
- **Escalabilidad:** Facilita actualizaciones sin modificar las aplicaciones cliente.

---

## 🧱 Buenas Prácticas

1. **Usar nombres descriptivos**: evita prefijos reservados como `sp_` en SQL Server.
2. **Controlar errores** con `TRY...CATCH` dentro de los procedimientos.
3. **Evitar cursores** y preferir operaciones basadas en conjuntos.
4. **Optimizar índices** en columnas de búsqueda o unión.
5. **Parametrizar consultas** para prevenir inyección SQL y mejorar el rendimiento.

---

## 🧾 Conclusión

Los **procedimientos almacenados** y **funciones** son herramientas esenciales en la administración moderna de bases de datos.  
Mientras los procedimientos almacenados ofrecen **flexibilidad y control transaccional**, las funciones destacan por su **facilidad de integración y eficiencia en cálculos**.  
La elección entre ambos depende del objetivo: automatización de procesos complejos o generación de resultados deterministas.

Ambos, correctamente implementados, fortalecen la arquitectura de datos y promueven la **consistencia, rendimiento y seguridad** del sistema.

---

📚 **Referencias**  
- Microsoft Docs: [CREATE PROCEDURE (Transact‑SQL)](https://learn.microsoft.com/es-es/sql/t-sql/statements/create-procedure-transact-sql)  
- Microsoft Docs: [CREATE FUNCTION (Transact‑SQL)](https://learn.microsoft.com/es-es/sql/t-sql/statements/create-function-transact-sql)  
- Calbimonte, D. *Funciones frente a los procedimientos almacenados en SQL Server*, SQLShack (2019)
