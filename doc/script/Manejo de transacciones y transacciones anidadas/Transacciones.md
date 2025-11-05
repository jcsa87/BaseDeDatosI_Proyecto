## Manejo de Transacciones (ACID)

Una transacción es un conjunto de una o más operaciones SQL (como
INSERT, UPDATE o DELETE) que se ejecutan como una ÚNICA unidad
de trabajo.

El principio fundamental de una transacción es la **Atomicidad** (la 'A' de ACID):
"O se hace todo, o no se hace nada".

Si todas las operaciones tienen éxito, la transacción se "confirma"
con `COMMIT` y los cambios se vuelven permanentes. Si alguna operación falla,
la transacción entera se "revierte" con `ROLLBACK`
y la base de datos vuelve al estado exacto en el que estaba antes
de que comenzara la transacción.
