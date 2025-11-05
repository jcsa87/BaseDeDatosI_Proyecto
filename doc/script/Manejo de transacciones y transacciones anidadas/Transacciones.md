# Investigación: Manejo de Transacciones en SQL y Transacciones anidadas

## 1. Definición de transacción

En SQL, una transacción es un conjunto de una o más operaciones (como `INSERT`, `UPDATE` o `DELETE`) que se ejecutan como una **única unidad de trabajo**.

El principio fundamental es la **Atomicidad**:

Si todas las operaciones tienen éxito, la transacción se "confirma" con `COMMIT` y los cambios se vuelven permanentes. Si _alguna_ operación falla, la transacción entera se "revierte" con `ROLLBACK` y la base de datos vuelve al estado exacto en el que estaba antes de que comenzara.

### Las Propiedades ACID

Las transacciones son la garantía de que una base de datos cumple con las propiedades **ACID**:

- **[A] Atomicidad:** La transacción es una unidad indivisible. Una transacción
  completa debe ejecutarse exitosamente o ninguna de sus partes deben aplicarse.
- **[C] Consistencia:** La base de datos siempre pasa de un estado válido a otro estado válido, respetando todas las reglas (claves foráneas, `CHECK`, etc.).
- **[I] Aislamiento (Isolation):** Las transacciones concurrentes (que ocurren al mismo tiempo) no interfieren entre sí.
- **[D] Durabilidad:** Una vez que un `COMMIT` es exitoso, los cambios son permanentes y sobreviven a fallas del sistema (ej: un corte de luz).

### El Manejo de Errores: TRY, CATCH

En SQL Server, la forma moderna y robusta de manejar transacciones es con un bloque `TRY...CATCH`.

```sql
BEGIN TRY
    BEGIN TRANSACTION;
    -- 1. Operación SQL
    -- 2. Operación SQL
    -- ...
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    -- Si algo falla en el TRY, salta aquí
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    -- (Manejar o registrar el error)
END CATCH

Vea el EJEMPLO 1 en el archivo .sql para una simulación de este ROLLBACK automático.
```
