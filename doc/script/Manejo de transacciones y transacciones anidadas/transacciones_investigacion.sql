USE servicio_tecnico_informatico;
GO

--                   DATOS AUXILIARES 
 -- Creamos rol de prueba
IF NOT EXISTS (SELECT 1 FROM rol WHERE id_rol = 999)
BEGIN
    INSERT INTO rol (id_rol, descripcion)
    VALUES (999, 'Técnico de prueba (transacciones)');
END;

-- Creamos estado de reparación de prueba
IF NOT EXISTS (SELECT 1 FROM estado_reparacion WHERE descripcion = 'En proceso (transacciones)')
BEGIN
    INSERT INTO estado_reparacion (descripcion)
    VALUES ('En proceso (transacciones)');
END;

-- Creamos medio de pago de prueba
IF NOT EXISTS (SELECT 1 FROM medio_de_pago WHERE descripcion = 'Efectivo (transacciones)')
BEGIN
    INSERT INTO medio_de_pago (descripcion)
    VALUES ('Efectivo (transacciones)');
END;

-- Creamos marca, modelo y tipo de equipo para las pruebas
IF NOT EXISTS (SELECT 1 FROM marca WHERE nombre = 'Marca Transacciones')
BEGIN
    INSERT INTO marca (nombre) VALUES ('Marca Transacciones');
END;

DECLARE @idMarca INT = (SELECT TOP 1 id_marca FROM marca WHERE nombre = 'Marca Transacciones');

IF NOT EXISTS (SELECT 1 FROM modelo WHERE nombre = 'Modelo Transacciones')
BEGIN
    INSERT INTO modelo (nombre, id_marca)
    VALUES ('Modelo Transacciones', @idMarca);
END;

IF NOT EXISTS (SELECT 1 FROM tipo_equipo WHERE nombre = 'Notebook (transacciones)')
BEGIN
    INSERT INTO tipo_equipo (nombre)
    VALUES ('Notebook (transacciones)');
END;

GO

/* 
                    EJEMPLO 1 – TRANSACCIÓN BÁSICA
                    Alta de cliente + equipo (COMMIT si todo sale bien)
*/

BEGIN TRY
    BEGIN TRAN Ejemplo1;   -- Inicio de transacción

    INSERT INTO cliente (nombre, apellido, dni, telefono, email)
    VALUES ('Transacciones', 'Cliente1', '90000001', '3794000001', 'cliente1_transac@example.com');
    -- Cliente creado

    DECLARE @idCliente1 INT = SCOPE_IDENTITY();  -- Obtener ID del cliente

    DECLARE @idTipo INT = (SELECT TOP 1 id_tipo FROM tipo_equipo WHERE nombre = 'Notebook (transacciones)');
    DECLARE @idModelo INT = (SELECT TOP 1 id_modelo FROM modelo WHERE nombre = 'Modelo Transacciones');

    INSERT INTO equipo (id_cliente, id_tipo, id_modelo)
    VALUES (@idCliente1, @idTipo, @idModelo);
    -- Equipo creado

    COMMIT TRAN Ejemplo1;   -- Confirmamos los cambios
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN Ejemplo1;   -- Revertimos si algo falla

    SELECT ERROR_MESSAGE() AS ErrorMsg;
END CATCH;
GO


/*
                    EJEMPLO 2 – TRANSACCIÓN CON ERROR
                    Alta de ingreso con FK inválidas → ROLLBACK seguro
*/

BEGIN TRY
    BEGIN TRAN Ejemplo2;  -- Inicio de transacción

    INSERT INTO ingreso_equipo (id_ingreso_equipo, falla, id_cliente, id_equipo)
    VALUES (1, 'No enciende (test)', 999999, 999999);
    -- Esto tiene que fallar, ya que las FK no existen

    COMMIT TRAN Ejemplo2;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN Ejemplo2;   -- Garantizar reversión

    SELECT ERROR_MESSAGE() AS ErrorMsg;
END CATCH;
GO


/* 
                    EJEMPLO 3 – SAVEPOINT
                    Mantener diagnóstico pero revertir reparación inválida
*/

DECLARE @idEstadoProceso INT =
(
    SELECT TOP 1 id_estado_reparacion
    FROM estado_reparacion
    WHERE descripcion = 'En proceso (transacciones)'
);

BEGIN TRY
    BEGIN TRAN Ejemplo3;  -- Inicio transacción

    -- Crear cliente de prueba
    INSERT INTO cliente (nombre, apellido, dni, telefono, email)
    VALUES ('Transacciones', 'Cliente2', '90000002', '3794000002', 'cliente2_transac@example.com');

    DECLARE @idCliente2 INT = SCOPE_IDENTITY();

    -- Crear equipo de prueba
    DECLARE @idTipo2 INT = (SELECT TOP 1 id_tipo FROM tipo_equipo WHERE nombre = 'Notebook (transacciones)');
    DECLARE @idModelo2 INT = (SELECT TOP 1 id_modelo FROM modelo WHERE nombre = 'Modelo Transacciones');

    INSERT INTO equipo (id_cliente, id_tipo, id_modelo)
    VALUES (@idCliente2, @idTipo2, @idModelo2);

    DECLARE @idEquipo2 INT = SCOPE_IDENTITY();

    -- Crear diagnóstico válido
    INSERT INTO diagnostico (motivo, fecha_diagnostico, costo_estimado, id_equipo)
    VALUES ('Diagnóstico de prueba', GETDATE(), 15000.00, @idEquipo2);

    DECLARE @idDiag2 INT = SCOPE_IDENTITY();

    SAVE TRAN SP_Reparacion;   -- Guardar punto seguro (el diagnóstico queda protegido)

    -- Reparación con monto inválido
    INSERT INTO reparacion (fecha_resolucion, id_diagnostico, id_estado_reparacion, monto_total)
    VALUES (GETDATE(), @idDiag2, @idEstadoProceso, 5000.00);
    -- Este valor está mal a propósito

    DECLARE @idRep2 INT = SCOPE_IDENTITY();

    -- Validación lógica
    IF (SELECT monto_total FROM reparacion WHERE id_reparacion = @idRep2) <
       (SELECT costo_estimado FROM diagnostico WHERE id_diagnostico = @idDiag2)
    BEGIN
        RAISERROR('Monto inválido: menor al costo estimado.', 16, 1); -- Fuerza error
    END;

    COMMIT TRAN Ejemplo3;
END TRY
BEGIN CATCH
    IF XACT_STATE() = 1
    BEGIN
        ROLLBACK TRAN SP_Reparacion;  -- Revertir solo reparación
        COMMIT TRAN Ejemplo3;         -- Mantener diagnóstico
    END
    ELSE
        ROLLBACK TRAN Ejemplo3;       -- Si está dañada, revertir todo

    SELECT ERROR_MESSAGE() AS ErrorMsg;
END CATCH;
GO


/* 
                    EJEMPLO 4 – FLUJO COMPLETO CON SAVEPOINT
                    Cliente → Equipo → Diagnóstico → Reparación → Factura → Pago
                    Reversión solo del último paso si falla
*/

DECLARE @idMedioPago INT =
(
    SELECT TOP 1 id_medioDePago
    FROM medio_de_pago
    WHERE descripcion = 'Efectivo (transacciones)'
);

DECLARE @idEstadoProceso4 INT =
(
    SELECT TOP 1 id_estado_reparacion
    FROM estado_reparacion
    WHERE descripcion = 'En proceso (transacciones)'
);

BEGIN TRY
    BEGIN TRAN FlujoCompleto;  -- Inicio del flujo grande

    -- Paso 1 – Cliente y equipo
    INSERT INTO cliente (nombre, apellido, dni, telefono, email)
    VALUES ('Transacciones', 'Cliente3', '90000003', '3794000003', 'cliente3_transac@example.com');
    -- Cliente creado

    DECLARE @idCliente3 INT = SCOPE_IDENTITY();

    DECLARE @idTipo3 INT = (SELECT TOP 1 id_tipo FROM tipo_equipo WHERE nombre = 'Notebook (transacciones)');
    DECLARE @idModelo3 INT = (SELECT TOP 1 id_modelo FROM modelo WHERE nombre = 'Modelo Transacciones');

    INSERT INTO equipo (id_cliente, id_tipo, id_modelo)
    VALUES (@idCliente3, @idTipo3, @idModelo3);
    -- Equipo creado

    DECLARE @idEquipo3 INT = SCOPE_IDENTITY();
    SAVE TRAN SP_Ingreso;  -- Punto seguro del ingreso


    /* Paso 2 – Diagnóstico */
    INSERT INTO diagnostico (motivo, fecha_diagnostico, costo_estimado, id_equipo)
    VALUES ('Diagnóstico flujo completo', GETDATE(), 25000.00, @idEquipo3);
    -- Diagnóstico creado

    DECLARE @idDiag3 INT = SCOPE_IDENTITY();
    SAVE TRAN SP_Diagnostico;


    /* Paso 3 – Reparación */
    INSERT INTO reparacion (fecha_resolucion, id_diagnostico, id_estado_reparacion, monto_total)
    VALUES (GETDATE(), @idDiag3, @idEstadoProceso4, 28000.00);
    -- Reparación válida

    DECLARE @idRep3 INT = SCOPE_IDENTITY();
    SAVE TRAN SP_Reparacion3;


    /* Paso 4 – Factura */
    INSERT INTO factura (id_cliente)
    VALUES (@idCliente3);
    -- Factura creada

    DECLARE @idFactura3 INT = SCOPE_IDENTITY();
    SAVE TRAN SP_Factura;


    /* Paso 5 – Pago (forzado a fallar) */
    INSERT INTO pago (id_medio_De_pago, id_factura, monto, id_reparacion)
    VALUES (@idMedioPago, @idFactura3, 27000.00, @idRep3);
    -- Pago incorrecto a propósito

    DECLARE @idPago3 INT = SCOPE_IDENTITY();

    -- Validación del pago
    IF (SELECT monto FROM pago WHERE id_pago = @idPago3) <>
       (SELECT monto_total FROM reparacion WHERE id_reparacion = @idRep3)
    BEGIN
        RAISERROR('Monto del pago no coincide con el total.', 16, 1);
    END;

    COMMIT TRAN FlujoCompleto;  -- Confirmar si todo OK
END TRY
BEGIN CATCH
    -- Revertir solo factura + pago
    IF XACT_STATE() = 1
    BEGIN
        ROLLBACK TRAN SP_Factura;  -- Vuelve antes del pago
        COMMIT TRAN FlujoCompleto; -- Mantiene todo lo anterior
    END
    ELSE
        ROLLBACK TRAN FlujoCompleto; -- Si está dañada, revertir todo

    SELECT ERROR_MESSAGE() AS ErrorMsg;
END CATCH;
GO
