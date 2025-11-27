# Investigación: Manejo de Transacciones y Anidamiento en T-SQL

**Proyecto**: Sistema de Gestión para Servicio Técnico Informático 
**Materia**: Base de Datos I

---

## 1. La Transacción y las Propiedades ACID

Una **transacción** es una secuencia de operaciones T-SQL que se ejecutan como una única unidad de trabajo lógica. Su objetivo es garantizar que los datos permanezcan correctos, coherentes y seguros ante fallos lógicos o técnicos. Se define como una unidad lógica de trabajo compuesta por una o más operaciones de manipulación de datos (**INSERT**, **UPDATE**, **DELETE**).

El objetivo fundamental de las transacciones es asegurar la integridad de la base de datos frente a errores del sistema, fallos de hardware o interrupciones en la lógica de negocio. Una transacción asegura que un proceso complejo (como una reparación que consume stock y genera facturación) no quede en un estado intermedio o inconsistente.

Para que un SGBD (Sistema Gestor de Base de Datos) sea considerado confiable, debe garantizar las propiedades **ACID**:

### • [A] Atomicidad

La transacción es indivisible: o se ejecutan todas sus operaciones o no se ejecuta ninguna.  
Si un paso falla, todo el conjunto debe revertirse.

### • [C] Consistencia

La transacción lleva a la base de datos de un estado válido a otro válido, preservando reglas de integridad (PK, FK, UNIQUE, CHECK).

### • [I] Aislamiento

Los efectos intermedios de una transacción no deben ser visibles para otras hasta que se confirme con `COMMIT`.
 Determina cómo las transacciones concurrentes (usuarios simultáneos) ven los cambios de los demás.

### • [D] Durabilidad

Una vez hecha la confirmación (`COMMIT`), los cambios quedan guardados incluso ante fallas del sistema.  
Esto lo garantiza el **Transaction Log**. Los cambios son permanentes y persistirán incluso ante una falla 
catastrófica (como un corte de luz).

---

## 2. Manejo de Errores con TRY...CATCH

En T-SQL, la forma más robusta de manejar errores dentro de una transacción es mediante bloques `TRY...CATCH`.
 Esto permite capturar errores en tiempo de ejecución y tomar decisiones lógicas (como revertir cambios) sin detener abruptamente la aplicación.

**Estructura Recomendada**
```sql
BEGIN TRY
    BEGIN TRANSACTION;

    -- Instrucciones DML
    INSERT INTO tabla (col) VALUES ('Dato');

    COMMIT TRANSACTION;   -- Se confirman los cambios
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;  -- Se revierte todo

    -- Manejo del error
    SELECT ERROR_MESSAGE() AS Error;
END CATCH;
```

**➡️ (Ver demostración en script: EJEMPLO 1 y EJEMPLO 2)**


---

## 3. SAVEPOINT: Reversión Parcial dentro de una Transacción

Las transacciones no siempre necesitan revertirse por completo.
En procesos reales, solo una parte puede fallar, mientras el resto sigue siendo válido.

Para esto existe el comando `SAVE TRAN` (SAVEPOINT):

```sql
BEGIN TRAN;
-- Paso 1 (válido)
SAVE TRAN SP1;

-- Paso 2
-- Si este falla:
ROLLBACK TRAN SP1;   -- Vuelve al punto SP1 sin perder Paso 1

COMMIT TRAN;
```

Esto es útil, por ejemplo, cuando un diagnóstico es correcto, pero la reparación asociada es inválida.
Queremos conservar el diagnóstico, pero revertir la reparación.

**➡️ EJEMPLO 3 – Uso de SAVEPOINT**

---

### 4. “Transacciones Anidadas” en SQL Server

SQL Server _no soporta transacciones anidadas reales_.
Cada `BEGIN TRAN` incrementa un contador (`@@TRANCOUNT`), pero solo el último `COMMIT` hace persistir los cambios.

Sin embargo, es posible simular anidamiento lógico usando múltiples SAVEPOINT:

```sql
BEGIN TRAN Principal;

-- Nivel 1
SAVE TRAN SP_Nivel1;

-- Nivel 2
SAVE TRAN SP_Nivel2;

-- Si ocurre un error en nivel 2:
ROLLBACK TRAN SP_Nivel2;   -- Vuelve al inicio del nivel 2

COMMIT TRAN Principal;
```

Esto permite modelar procesos compuestos por varios pasos:

1. Alta de cliente

2. Alta de equipo

3. Diagnóstico

4. Reparación

5. Factura

6. Pago

Si el error ocurre en el pago, no es necesario revertir cliente, equipo, diagnóstico ni reparación.

**➡️ EJEMPLO 4 – Flujo completo con SAVEPOINT**
