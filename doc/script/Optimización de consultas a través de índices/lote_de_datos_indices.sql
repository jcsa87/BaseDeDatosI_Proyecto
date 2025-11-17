USE servicio_tecnico_informatico;
GO

-- Insertamos 100 clientes genéricos
DECLARE @i INT = 1;
WHILE @i <= 100
BEGIN
    INSERT INTO cliente (nombre, apellido, dni, telefono, id_direccion, email, id_usuario)
    VALUES (
        'Cliente_Nombre_' + CAST(@i AS VARCHAR(10)),
        'Cliente_Apellido_' + CAST(@i AS VARCHAR(10)),
        CAST(30000000 + @i AS VARCHAR(20)), -- DNI único
        '555-1234',
        1, -- Asumimos que la dirección ID=1 existe
        'cliente_' + CAST(@i AS VARCHAR(10)) + '@mail.com', -- Email único
        2  -- Asumimos que el usuario ID=2 (cliente) existe
    );
    SET @i = @i + 1;
END
GO

USE servicio_tecnico_informatico;
GO

-- Desactivamos temporalmente la FK para acelerar la inserción masiva
ALTER TABLE factura NOCHECK CONSTRAINT FK_factura_cliente;
GO

DECLARE @j INT = 1;
DECLARE @total_facturas INT = 1000000;
DECLARE @id_cliente_aleatorio INT;
DECLARE @fecha_aleatoria DATETIME;
DECLARE @dias_aleatorios INT;

-- Usamos T-SQL por lotes para no saturar el log de transacciones
WHILE @j <= @total_facturas
BEGIN
    -- Generar un ID de cliente aleatorio (entre 1 y 100)
    SET @id_cliente_aleatorio = (SELECT CAST(RAND() * 99 + 1 AS INT));

    -- Generar una fecha aleatoria en los últimos 1825 días (5 años)
    SET @dias_aleatorios = (SELECT CAST(RAND() * 1825 AS INT));
    SET @fecha_aleatoria = DATEADD(DAY, -@dias_aleatorios, GETDATE());

    INSERT INTO factura (id_cliente, fecha_emision)
    VALUES (@id_cliente_aleatorio, @fecha_aleatoria);

    SET @j = @j + 1;

END
GO

-- Reactivamos la FK
ALTER TABLE factura CHECK CONSTRAINT FK_factura_cliente;
GO

