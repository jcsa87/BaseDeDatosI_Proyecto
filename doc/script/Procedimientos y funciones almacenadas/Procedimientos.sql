USE servicio_tecnico_informatico;
GO

/* ============================================================
   PROCEDIMIENTO 1:
   RegistrarIngresoEquipo
   ------------------------------------------------------------
   Crea automáticamente un nuevo ingreso de equipo para un cliente.
   Calcula el próximo ID correlativo por cliente/equipo.
   ============================================================ */

CREATE OR ALTER PROCEDURE RegistrarIngresoEquipo
(
    @id_cliente INT,
    @id_equipo INT,
    @falla VARCHAR(255)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @nuevoID INT;

    SELECT @nuevoID = ISNULL(MAX(id_ingreso_equipo), 0) + 1
    FROM ingreso_equipo
    WHERE id_cliente = @id_cliente
      AND id_equipo = @id_equipo;

    INSERT INTO ingreso_equipo (id_ingreso_equipo, falla, id_cliente, id_equipo)
    VALUES (@nuevoID, @falla, @id_cliente, @id_equipo);

    SELECT 'Ingreso registrado correctamente.' AS mensaje, @nuevoID AS id_ingreso_creado;
END;
GO


/* ============================================================
   PROCEDIMIENTO 2:
   FinalizarReparacion
   ------------------------------------------------------------
   Actualiza reparación, genera factura y registra pago.
   Incluye control transaccional y manejo de errores.
   ============================================================ */

CREATE OR ALTER PROCEDURE FinalizarReparacion
(
    @id_reparacion INT,
    @monto DECIMAL(10,2),
    @medio_pago INT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Actualizar estado y monto
        UPDATE reparacion
        SET fecha_resolucion = GETDATE(),
            monto_total = @monto,
            id_estado_reparacion = 3
        WHERE id_reparacion = @id_reparacion;

        -- 2. Obtener id_cliente asociado a la reparación
        DECLARE @cliente INT;

        SELECT @cliente = c.id_cliente
        FROM reparacion r
        JOIN diagnostico d ON r.id_diagnostico = d.id_diagnostico
        JOIN equipo e ON d.id_equipo = e.id_equipo
        JOIN cliente c ON e.id_cliente = c.id_cliente
        WHERE r.id_reparacion = @id_reparacion;

        -- 3. Crear factura
        INSERT INTO factura (id_cliente) VALUES (@cliente);
        DECLARE @id_factura INT = SCOPE_IDENTITY();

        -- 4. Registrar pago
        INSERT INTO pago (id_medio_de_pago, id_factura, monto, id_reparacion)
        VALUES (@medio_pago, @id_factura, @monto, @id_reparacion);

        COMMIT;

        SELECT 'Reparación finalizada correctamente.' AS mensaje,
               @id_factura AS factura_generada;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH;
END;
GO


/* ============================================================
   PROCEDIMIENTO 3:
   DescontarStockRepuesto
   ------------------------------------------------------------
   Reduce el stock de un repuesto cuando es utilizado.
   ============================================================ */

CREATE OR ALTER PROCEDURE DescontarStockRepuesto
(
    @id_repuesto INT,
    @cantidad INT
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE repuesto
    SET stock = stock - @cantidad
    WHERE id_repuesto = @id_repuesto;

    SELECT 'Stock descontado correctamente.' AS mensaje;
END;
GO
