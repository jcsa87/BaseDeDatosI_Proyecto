USE servicio_tecnico_informatico;
GO

/* ============================================================
   FUNCIÓN 1:
   fn_TotalGastadoCliente
   ------------------------------------------------------------
   Devuelve el total gastado por un cliente en reparaciones.
   ============================================================ */

CREATE OR ALTER FUNCTION fn_TotalGastadoCliente
(
    @id_cliente INT
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @total DECIMAL(10,2);

    SELECT @total = ISNULL(SUM(p.monto), 0)
    FROM pago p
    JOIN factura f ON p.id_factura = f.id_factura
    WHERE f.id_cliente = @id_cliente;

    RETURN @total;
END;
GO


/* ============================================================
   FUNCIÓN 2:
   fn_ReparacionesPorEstado
   ------------------------------------------------------------
   Devuelve todas las reparaciones filtradas por estado.
   ============================================================ */

CREATE OR ALTER FUNCTION fn_ReparacionesPorEstado
(
    @estado INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT *
    FROM reparacion
    WHERE id_estado_reparacion = @estado
);
GO


/* ============================================================
   FUNCIÓN 3:
   fn_EquiposPorCliente
   ------------------------------------------------------------
   Devuelve la lista de equipos asociados a un cliente.
   ============================================================ */

CREATE OR ALTER FUNCTION fn_EquiposPorCliente
(
    @id_cliente INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT e.id_equipo, m.nombre AS modelo, t.nombre AS tipo
    FROM equipo e
    JOIN modelo m ON e.id_modelo = m.id_modelo
    JOIN tipo_equipo t ON e.id_tipo = t.id_tipo
    WHERE e.id_cliente = @id_cliente
);
GO
