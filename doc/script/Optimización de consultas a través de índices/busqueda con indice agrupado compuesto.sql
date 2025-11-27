-- Borrar el indice anterior para poder crear uno nuevo
DROP INDEX CX_factura_fecha_emision ON factura;
GO

-- Crear el indice agrupado compuesto
-- Incluye la columna del WHERE (fecha_emision)
-- y las columnas del SELECT (id_cliente, id_factura)
CREATE CLUSTERED INDEX CX_factura_fecha_cliente_id
ON factura (fecha_emision, id_cliente, id_factura);
GO

-- 1. Limpiar el cache de SQL Server
DBCC DROPCLEANBUFFERS;
GO

-- 2. Activar estadisticas
SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO

SELECT 
    id_factura, 
    id_cliente, 
    fecha_emision
FROM 
    factura
WHERE 
    fecha_emision BETWEEN '2024-01-01' AND '2024-01-31';
GO

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO