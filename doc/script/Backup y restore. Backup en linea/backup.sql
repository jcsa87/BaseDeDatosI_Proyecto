/*
Verificar que el modelo de recuperación de la base de datos esté 
en el modo adecuado para realizar backup en línea.


Al estar en modo FULL, puedo realizar tanto BACKUP DATABASE (el backup
completo en línea) como BACKUP LOG (backup del log, como su nombre lo 
indica).
*/
SELECT name, recovery_model_desc
FROM sys.databases
WHERE name = 'servicio_tecnico_informatico';

/*
Realizar un backup full de la base de datos.


En SQL por defecto se realizan "en línea", es decir que no necesitas
detener la base de datos ni desconectar a los usuarios.


Lo realizamos sin la fecha ni el dia, a pesar de que sea lo conveniente
porque la consigna así lo pide.
*/

BACKUP DATABASE servicio_tecnico_informatico

TO DISK = 'C:\BackupsSTI\STI_FULL.bak'

WITH

    NAME = 'Backup Completo - servicio_tecnico_informatico',

    DESCRIPTION = 'Backup completo de la base de datos de servicio técnico',

    COMPRESSION;  -- Esta opción hace el archivo de backup más pequeño.

GO


/* Generar 10 inserts sobre una tabla de referencia.

Elegimos la tabla Diagnostico

Realizamos unos inserts para tener mas datos para ingresar sobre
la tabla de referencia:

INSERT INTO tipo_equipo (nombre) VALUES ('Desktop (PC de escritorio)');

INSERT INTO marca (nombre) VALUES ('HP');

INSERT INTO modelo (nombre, id_marca) VALUES ('Pavilion All-in-One 27', 2);

INSERT INTO usuario (usuario, nombre, apellido, id_rol, email, contraseña) 
VALUES ('mgarcia', 'Miguel', 'Garcia', 3, 'miguel.garcia@cliente.com', 'contraseña3');

INSERT INTO direccion (calle, altura) VALUES ('Calle Falsa', '123');

INSERT INTO cliente (nombre, apellido, dni, telefono, id_direccion, email, id_usuario) 
VALUES ('Miguel', 'Garcia', '28999123', '3794887766', 2, 'miguel.garcia@cliente.com', 5);
GO

INSERT INTO equipo (id_cliente, id_tipo, id_modelo) 
VALUES 
(1, 2, 2), -- id_equipo = 2: Un PC HP All-in-One del cliente Miguel Garcia
(5, 1, 1), -- id_equipo = 3: Otra Notebook Dell XPS de Carla Vega
(1, 1, 1), -- id_equipo = 4: Una Notebook Dell XPS del cliente Miguel Garcia
(1, 2, 2), -- id_equipo = 5: Un PC HP All-in-One de Carla Vega
(5, 1, NULL); -- id_equipo = 6: Una Notebook del cliente Miguel (sin modelo especificado)
GO
*/
INSERT INTO diagnostico (motivo, fecha_diagnostico, costo_estimado, id_equipo, id_emp) 
VALUES 
('El disco duro (HDD) presenta sectores defectuosos. Se recomienda reemplazar por un SSD de 240GB. Costo incluye clonación de datos.', '2025-11-10', 120.00, 1, 1),
('Falla en el módulo de memoria RAM. El equipo no pasa el POST. Se reemplazará el módulo de 8GB DDR4.', '2025-11-11', 75.50, 7, 1),
('Sobrecalentamiento excesivo por obstrucción en el disipador y ventilador. Requiere limpieza interna completa y cambio de pasta térmica.', '2025-11-12', 50.00, 8, 1),
('El sistema operativo está corrupto (Windows 11) y no arranca. Se realizará un formateo y reinstalación del SO, con respaldo de datos.', '2025-11-13', 60.00, 9, 2),
('El cargador no entrega voltaje. El pin de carga de la notebook está en buen estado. Se debe reemplazar el cargador original.', '2025-11-14', 45.00, 10, 1),
('Virus detectado (Ransomware). Se procederá a la limpieza de malware y se intentará recuperar archivos. Se recomienda instalar un antivirus licenciado.', '2025-11-15', 80.00, 1, 1),
('La bisagra izquierda de la pantalla está rota. Se debe reemplazar la carcasa inferior (palmrest) y la bisagra. Pieza bajo pedido.', '2025-11-16', 150.00, 11, 2),
('El teclado no responde en varias teclas. Se derramó líquido. Requiere reemplazo completo del teclado.', '2025-11-17', 90.00, 9, 5),
('Problema de drivers de Wi-Fi. La tarjeta es reconocida pero no se conecta a redes. Se actualizará el firmware y los controladores.', '2025-11-18', 30.00, 8, 1),
('La batería está agotada, dura menos de 15 minutos. Se necesita un reemplazo de batería interna.', '2025-11-19', 110.00, 7, 1);
GO

/*
Realizar backup del archivo de log y registrar la hora del backup
*/
DECLARE @dateTimeString VARCHAR(100);
DECLARE @fileName VARCHAR(500);
DECLARE @sqlCommand NVARCHAR(1000);

-- Crear un string con la fecha y hora (ej: '20251116_234500')
SET @dateTimeString = FORMAT(GETDATE(), 'yyyyMMdd_HHmmss');

-- Construir la ruta del archivo. Nota el uso de _LOG y la extensión .trn
SET @fileName = 'C:\BackupsSTI\servicio_tecnico_informatico_LOG_' + @dateTimeString + '.trn';

-- Construir el comando BACKUP LOG completo
SET @sqlCommand = N'BACKUP LOG servicio_tecnico_informatico
TO DISK = ''' + @fileName + '''
WITH
    NAME = ''Backup del Log - ' + @dateTimeString + ''',
    DESCRIPTION = ''Backup del log de transacciones para servicio técnico'',
    COMPRESSION;';
/* La N le indica a SQL Server que el texto (el "string") que viene después es de 
tipo Unicode (específicamente, NVARCHAR).
*/

-- Ejecutar el comando de backup
EXEC sp_executesql @sqlCommand;
GO

/*
Generar otros 10 insert sobre la tabla de referencia.

Habiendo ocupado la tabla diagnostico
*/
INSERT INTO diagnostico (motivo, fecha_diagnostico, costo_estimado, id_equipo, id_emp) 
VALUES 
('Fallo en la tarjeta gráfica dedicada. Muestra "artifacts" en pantalla. Requiere reballing o reemplazo de chip gráfico.', '2025-11-20', 250.00, 7, 1),
('El equipo no detecta la red WiFi. La tarjeta inalámbrica está dañada. Se procederá al reemplazo de la tarjeta WiFi M.2.', '2025-11-21', 40.00, 11, 2),
('El cliente reporta lentitud extrema. El disco duro está al 100% de uso. Análisis de S.M.A.R.T. indica que el disco está fallando. Se recomienda SSD.', '2025-11-22', 115.00, 1, 5),
('La pantalla se ve muy oscura, sin brillo. El inverter de la pantalla (backlight) está quemado. Se debe reemplazar el inverter.', '2025-11-23', 70.00, 8, 2),
('El equipo (All-in-One) se apaga solo después de 10 minutos. Falla en la fuente de alimentación interna. Se debe reemplazar la fuente.', '2025-11-24', 130.00, 9, 1),
('El conector USB 3.0 frontal está roto físicamente. Se desoldará el puerto dañado y se soldará uno nuevo.', '2025-11-25', 55.00, 10, 5),
('La webcam integrada no es detectada por el sistema. El cable flex de la cámara está cortado. Se reemplazará el flex.', '2025-11-26', 65.00, 7, 5),
('El audio no funciona. Los parlantes internos están dañados. Se reemplazarán los parlantes.', '2025-11-27', 48.00, 11, 1),
('El equipo enciende pero no da video. Se diagnostica un "brickeo" de BIOS. Se intentará flashear la BIOS con un programador externo.', '2025-11-28', 95.00, 9, 2),
('El touchpad no funciona (ni clic ni movimiento). Se verificó el controlador y el cable flex. El touchpad está defectuoso. Requiere reemplazo.', '2025-11-29', 85.00, 8, 1);
GO

/*
Realizar nuevamente backup de archivo de log  en otro archivo físico.

Al ocupar la funcion GETDATE() para asignarle la hora actual, se genera la
copia en otro archivo fisico
*/

DECLARE @dateTimeString VARCHAR(100);
DECLARE @fileName VARCHAR(500);
DECLARE @sqlCommand NVARCHAR(1000);

-- Se crea un NUEVO string con la fecha y hora actual
SET @dateTimeString = FORMAT(GETDATE(), 'yyyyMMdd_HHmmss');

-- Construir la ruta del archivo. Nota el uso de _LOG y la extensión .trn
SET @fileName = 'C:\BackupsSTI\servicio_tecnico_informatico_LOG_' + @dateTimeString + '.trn';

-- Se construye el comando BACKUP LOG
SET @sqlCommand = N'BACKUP LOG servicio_tecnico_informatico
TO DISK = ''' + @fileName + '''
WITH
    NAME = ''Backup del Log - ' + @dateTimeString + ''',
    DESCRIPTION = ''Backup del log de transacciones para servicio técnico'',
    COMPRESSION;';

-- Ejecutar el comando de backup
EXEC sp_executesql @sqlCommand;
GO


/*
Restaurar la base de datos al momento del primer backup del archivo de log. Es decir 
después de los primeros 10 insert.
*/

-- Cambiamos la base de datos en ejercicio a master para poder realizarlo
USE master;
GO

/*
Es necesario cambiar la base de datos a SINGLE_USER para desconectar
a los demás usuarios para poder restaurar, es necesario porque muchas veces
una conexión propia en la computadora puede obstaculizar el procedimiento.
*/

ALTER DATABASE servicio_tecnico_informatico
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
GO

/*
Restauramos el BACKUP completo (sin recuperar)

Usamos NORECOVERY para "dejar la puerta abierta" y poder aplicar el log.
*/

RESTORE DATABASE servicio_tecnico_informatico
FROM DISK = 'C:\BackupsSTI\STI_FULL.bak'
WITH NORECOVERY, REPLACE; -- REPLACE es por si la BD ya existe
GO

/*
Restauramos el primer BACKUP del LOG (esta vez con recuperación)

Usamos RECOVERY para dejar la base de datos lista.
*/
RESTORE LOG servicio_tecnico_informatico
FROM DISK = 'C:\BackupsSTI\servicio_tecnico_informatico_LOG_20251117_000459.trn'
WITH RECOVERY;
GO

/*
Aquí volvemos a poner el modo MULTI_USER para que las aplicaciones
y los otros usuarios puedan conectarse de nuevo.
*/
ALTER DATABASE servicio_tecnico_informatico
SET MULTI_USER;
GO

/*
Verificar el resultado.

Aqui probamos que haya funcionado el restore, por lo que muestra los
10 inserts que deberian estar.
*/

USE servicio_tecnico_informatico;

SELECT COUNT(*) FROM diagnostico;

/*
Restaurar la base de datos aplicando ambos archivos de log.

Acá repetimos el proceso que utilizamos anteriormente, exceptuando que al restaurar el primer
log, utilizamos un NORECOVERY para poder seguir agregando el segundo backup de log.
*/
USE master;
GO

ALTER DATABASE servicio_tecnico_informatico
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
GO

RESTORE DATABASE servicio_tecnico_informatico
FROM DISK = 'C:\BackupsSTI\STI_FULL.bak'
WITH NORECOVERY, REPLACE;
GO

RESTORE LOG servicio_tecnico_informatico
FROM DISK = 'C:\BackupsSTI\servicio_tecnico_informatico_LOG_20251117_000459.trn'
WITH NORECOVERY;
GO

-- Usamos RECOVERY porque este SÍ es el final.

RESTORE LOG servicio_tecnico_informatico
FROM DISK = 'C:\BackupsSTI\servicio_tecnico_informatico_LOG_20251117_003420.trn'
WITH RECOVERY;
GO

ALTER DATABASE servicio_tecnico_informatico
SET MULTI_USER;
GO

/*
Verificamos el resultado.

Aqui probamos que haya funcionado el restore, por lo que muestra los
20 inserts que deberian estar.
*/

USE servicio_tecnico_informatico;

SELECT COUNT(*) FROM diagnostico;