CREATE DATABASE servicio_tecnico_informatico

USE servicio_tecnico_informatico

CREATE TABLE marca (
    id_marca INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE tipo_equipo (
    id_tipo INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE estado_reparacion (
    id_estado_reparacion INT PRIMARY KEY IDENTITY(1,1),
    descripcion VARCHAR(255) NOT NULL
);

CREATE TABLE medio_de_pago (
    id_medioDePago INT PRIMARY KEY IDENTITY(1,1),
    descripcion VARCHAR(100) NOT NULL
);

CREATE TABLE categoria_repuesto (
    id_categoria_repuesto INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE direccion (
    id_direccion INT PRIMARY KEY IDENTITY(1,1),
    direccion VARCHAR(255),  
    calle VARCHAR(150),
    altura VARCHAR(20),
    piso VARCHAR(10),
    numero_depto VARCHAR(10)
);

CREATE TABLE rol (
    id_rol INT PRIMARY KEY,
    descripcion VARCHAR(50)
)

CREATE TABLE usuario (
    id_usuario INT PRIMARY KEY IDENTITY(1,1),
    usuario VARCHAR(50) NOT NULL UNIQUE,
    nombre VARCHAR(100),
    apellido VARCHAR(100),
    id_rol INT, 
    email VARCHAR(100) NOT NULL UNIQUE,
    contraseña VARCHAR(255) NOT NULL,
    CONSTRAINT FK_usuario_rol FOREIGN KEY(id_rol) REFERENCES rol(id_rol)
);

CREATE TABLE proveedor (
    id_proveedor INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(150),
    id_categoria_repuesto INT,
    CONSTRAINT FK_proveedor_categoria FOREIGN KEY (id_categoria_repuesto) REFERENCES categoria_repuesto(id_categoria_repuesto)
);

CREATE TABLE modelo (
    id_modelo INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100),
    id_marca INT,
    CONSTRAINT FK_modelo_marca FOREIGN KEY (id_marca) REFERENCES marca(id_marca)
);

CREATE TABLE cliente (
    id_cliente INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    dni VARCHAR(20) UNIQUE,
    telefono VARCHAR(50),
    id_direccion INT,
    email VARCHAR(100) UNIQUE,
    id_usuario INT,
    CONSTRAINT FK_cliente_direccion FOREIGN KEY (id_direccion) REFERENCES direccion(id_direccion),
    CONSTRAINT FK_cliente_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);

GO

CREATE TABLE repuesto (
    id_repuesto INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(150) NOT NULL,
    marca VARCHAR(100),
    stock INT,
    id_proveedor INT,
    id_categoria_repuesto INT,
    CONSTRAINT FK_repuesto_proveedor FOREIGN KEY (id_proveedor) REFERENCES proveedor(id_proveedor),
    CONSTRAINT FK_repuesto_categoria FOREIGN KEY (id_categoria_repuesto) REFERENCES categoria_repuesto(id_categoria_repuesto)
);

CREATE TABLE equipo (
    id_equipo INT PRIMARY KEY IDENTITY(1,1),
    id_cliente INT NOT NULL,
    id_tipo INT,
    id_modelo INT,
    CONSTRAINT FK_equipo_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
    CONSTRAINT FK_equipo_tipo FOREIGN KEY (id_tipo) REFERENCES tipo_equipo(id_tipo),
    CONSTRAINT FK_equipo_modelo FOREIGN KEY (id_modelo) REFERENCES modelo(id_modelo)
);

CREATE TABLE ingreso_equipo (
    id_ingreso_equipo INT,
    falla VARCHAR(255),
    fecha_ingreso DATETIME DEFAULT GETDATE(),
    id_cliente INT,
    id_equipo INT,
    CONSTRAINT PK_ingreso_equipo PRIMARY KEY(id_cliente, id_equipo, id_ingreso_equipo),
    CONSTRAINT FK_ingreso_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
    CONSTRAINT FK_ingreso_equipo FOREIGN KEY (id_equipo) REFERENCES equipo(id_equipo)
);

GO

CREATE TABLE diagnostico (
    id_diagnostico INT PRIMARY KEY IDENTITY(1,1),
    motivo VARCHAR(1000), -- Se detalla análisis, motivo y solución
    fecha_diagnostico DATE,
    costo_estimado DECIMAL(10, 2),
    id_equipo INT,
    id_emp INT, -- Se referencia a la tabla usuario 
    CONSTRAINT FK_diagnostico_equipo FOREIGN KEY (id_equipo) REFERENCES equipo(id_equipo),
    CONSTRAINT FK_diagnostico_empleado FOREIGN KEY (id_emp) REFERENCES usuario(id_usuario)
);

GO

CREATE TABLE reparacion (
    id_reparacion INT PRIMARY KEY IDENTITY(1,1),
    fecha_resolucion DATETIME,
    id_diagnostico INT,
    id_estado_reparacion INT,
    monto_total DECIMAL(10, 2),
    CONSTRAINT FK_reparacion_diagnostico FOREIGN KEY (id_diagnostico) REFERENCES diagnostico(id_diagnostico),
    CONSTRAINT FK_reparacion_estado FOREIGN KEY (id_estado_reparacion) REFERENCES estado_reparacion(id_estado_reparacion)
);

GO

CREATE TABLE repuesto_reparacion (
    id_reparacion INT NOT NULL,
    id_repuesto INT NOT NULL,
    CONSTRAINT PK_repuesto_reparacion PRIMARY KEY (id_reparacion, id_repuesto), -- Clave primaria compuesta
    CONSTRAINT FK_rep_reparacion_reparacion FOREIGN KEY (id_reparacion) REFERENCES reparacion(id_reparacion),
    CONSTRAINT FK_rep_reparacion_repuesto FOREIGN KEY (id_repuesto) REFERENCES repuesto(id_repuesto)
);

GO

CREATE TABLE factura (
    id_factura INT PRIMARY KEY IDENTITY(1,1),
    id_cliente INT,
    fecha_emision DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_factura_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
);

GO

CREATE TABLE pago (
    id_pago INT PRIMARY KEY IDENTITY(1,1),
    id_medio_de_pago INT,
    id_factura INT,
    monto DECIMAL(10, 2),
    id_reparacion INT,
    CONSTRAINT FK_pago_medio_de_pago FOREIGN KEY (id_medio_de_pago) REFERENCES medio_de_pago(id_medioDePago),
    CONSTRAINT FK_pago_reparacion FOREIGN KEY (id_reparacion) REFERENCES reparacion(id_reparacion),
    CONSTRAINT FK_pago_factura FOREIGN KEY (id_factura) REFERENCES factura(id_factura)
);



GO

-- Inserción de datos
INSERT INTO rol (id_rol, descripcion) VALUES
(1, 'Administrador'),
(2, 'Tecnico'),
(3, 'Cliente');

INSERT INTO marca (nombre) 
VALUES ('Dell'); 

INSERT INTO tipo_equipo (nombre) 
VALUES ('Notebook');

INSERT INTO estado_reparacion (descripcion) VALUES
('Esperando a ser revisado'),     
('En Reparacion'),             
('Reparado');                 

INSERT INTO medio_de_pago (descripcion) 
VALUES ('Efectivo'); 

INSERT INTO categoria_repuesto (nombre) 
VALUES ('Pantallas'); 

INSERT INTO direccion (calle, altura, piso, numero_depto) 
VALUES ('Av. Siempre Viva', '742', 'PB', 'A'); 

GO

-- Creamos un usuario Técnico (Numero de rol = 2)
INSERT INTO usuario (usuario, nombre, apellido, id_rol, email, contraseña) 
VALUES ('jperez', 'Juan', 'Perez', 2, 'jperez@tecnico.com', 'contraseña');

-- Creamos un usuario Cliente (Numero de rol = 3)
INSERT INTO usuario (usuario, nombre, apellido, id_rol, email, contraseña) 
VALUES ('cvega', 'Carla', 'Vega', 3, 'carla.vega@cliente.com', 'contraseña2');

INSERT INTO proveedor (nombre, id_categoria_repuesto) 
VALUES ('Baterias Para Samsung', 1);

INSERT INTO modelo (nombre, id_marca) 
VALUES ('XPS 15 9500', 1);

GO

INSERT INTO cliente (nombre, apellido, dni, telefono, id_direccion, email, id_usuario) 
VALUES ('Carla', 'Vega', '30123456', '3794123456', 1, 'carla.vega@cliente.com', 2); 

INSERT INTO repuesto (nombre, marca, stock, id_proveedor, id_categoria_repuesto) 
VALUES ('Panel OLED 15.6" 4K', 'Dell', 10, 1, 1);

GO

INSERT INTO equipo (id_cliente, id_tipo, id_modelo) 
VALUES (1, 1, 1); 

GO

INSERT INTO ingreso_equipo (id_ingreso_equipo, falla, id_cliente, id_equipo) 
VALUES (1, 'Pantalla rota, no enciende.', 1, 1);

-- Creamos un diagnóstico (usa FK equipo=1 y usuario_tecnico=1)
INSERT INTO diagnostico (motivo, fecha_diagnostico, costo_estimado, id_equipo, id_emp) 
VALUES ('Requiere cambio de panel de pantalla. El costo incluye repuesto y mano de obra.', '2025-10-31', 350.50, 1, 1);

GO

INSERT INTO reparacion (fecha_resolucion, id_diagnostico, id_estado_reparacion, monto_total) 
VALUES (NULL, 1, 3, 350.50); --  Fecha resolucion NULL porque aún no se repara.

GO

-- Vinculamos el repuesto (ID = 3) a la reparación (ID = 1)
INSERT INTO repuesto_reparacion (id_reparacion, id_repuesto) 
VALUES (3, 1);

INSERT INTO factura (id_cliente, fecha_emision) 
VALUES (1, GETDATE());

GO

INSERT INTO pago (id_medio_de_pago, id_factura, monto, id_reparacion) 
VALUES (1, 1, 350.50, 3);

GO