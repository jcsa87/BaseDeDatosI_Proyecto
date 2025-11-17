-- Crear el indice agrupado en la columna fecha
CREATE CLUSTERED INDEX CX_factura_fecha_emision 
ON factura (fecha_emision);
GO

-- 1. Limpiar el cache
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