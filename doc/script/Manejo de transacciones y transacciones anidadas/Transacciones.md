# Investigación: Manejo de Transacciones y Anidamiento en T-SQL

## 1. La Transacción y las Propiedades ACID

Una **transacción** es una secuencia de operaciones T-SQL (Transact-SQL) que se ejecutan como una única unidad de trabajo lógica y atómica. Para que un SGBD (sistema gestor de bases de datos) sea considerado fiable, debe garantizar las propiedades **ACID** para cada transacción.

* **[A] Atomicidad:** La transacción es una unidad indivisible. O se ejecutan *todas* sus operaciones con éxito, o no se ejecuta *ninguna*. Si una parte falla, el sistema debe revertir todos los cambios hechos hasta ese punto.
* **[C] Consistencia:** La transacción debe llevar a la base de datos de un estado válido a otro estado válido. Debe preservar todas las reglas de integridad definidas (Claves Foráneas, Restricciones `CHECK`, `UNIQUE`, etc.).
* **[I] Aislamiento (Isolation):** Las transacciones que se ejecutan de forma concurrente deben estar aisladas entre sí. Los resultados de una transacción intermedia no deben ser visibles para otras transacciones hasta que la primera haya hecho `COMMIT`.
* **[D] Durabilidad:** Una vez que una transacción ha sido confirmada (`COMMIT`), sus cambios son permanentes y deben sobrevivir a cualquier falla del sistema (ej. reinicio), usualmente garantizado por el **Log de Transacciones** (Transaction Log).

En T-SQL, el manejo de errores se implementa de forma robusta usando bloques `TRY...CATCH`.

```sql
BEGIN TRY
    BEGIN TRANSACTION;  -- Marca el inicio de la unidad de trabajo
    -- ... Operaciones DML (INSERT, UPDATE, DELETE) ...
    COMMIT TRANSACTION; -- Confirma los cambios si todo es exitoso
END TRY
BEGIN CATCH
    -- Si ocurre un error en el bloque TRY, el control salta aquí
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION; -- Revierte todos los cambios
    -- (Lógica de manejo de errores, ej: RAISERROR)
END CATCH

➡️ Demostración de un ROLLBACK automático en el archivo .sql (EJEMPLO 1)