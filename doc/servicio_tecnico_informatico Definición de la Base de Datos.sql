CREATE DATABASE servicio_tecnico_informatico

USE servicio_tecnico_informatico

CREATE TABLE Marca (
    id_marca INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE Tipo (
    id_tipo INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE EstadoReparacion (
    id_estadoReparacion INT PRIMARY KEY IDENTITY(1,1),
    descripcion VARCHAR(255)
);

CREATE TABLE MedioDePago (
    id_medioDePago INT PRIMARY KEY IDENTITY(1,1),
    descripcion VARCHAR(100)
);

CREATE TABLE CategoriaRepuesto (
    id_categoria_repuesto INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100)
);

CREATE TABLE Direccion (
    id_direccion INT PRIMARY KEY IDENTITY(1,1),
    direccion VARCHAR(255),  
    calle VARCHAR(150),
    altura VARCHAR(20),
    piso VARCHAR(10),
    depto VARCHAR(10),
    numero_depto VARCHAR(10)
);

CREATE TABLE rol (
    id_rol INT PRIMARY KEY,
    descripcion VARCHAR(50)
)

CREATE TABLE Usuario (
    id_usuario INT PRIMARY KEY IDENTITY(1,1),
    usuario VARCHAR(50) NOT NULL UNIQUE,
    nombre VARCHAR(100),
    apellido VARCHAR(100),
    id_rol INT, 
    email VARCHAR(100) NOT NULL UNIQUE,
    contraseña VARCHAR(255) NOT NULL
);

ALTER TABLE usuario
    ADD CONSTRAINT FK_usuario_rol FOREIGN KEY(id_rol) REFERENCES rol(id_rol)

GO

CREATE TABLE Proveedor (
    id_proveedor INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(150),
    id_categoria_repuesto INT,
    CONSTRAINT FK_Proveedor_Categoria FOREIGN KEY (id_categoria_repuesto) REFERENCES CategoriaRepuesto(id_categoria_repuesto)
);

CREATE TABLE Modelo (
    id_modelo INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100),
    id_marca INT,
    CONSTRAINT FK_Modelo_Marca FOREIGN KEY (id_marca) REFERENCES Marca(id_marca)
);

CREATE TABLE Cliente (
    id_cliente INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    dni VARCHAR(20) UNIQUE,
    telefono VARCHAR(50),
    id_direccion INT,
    email VARCHAR(100) UNIQUE,
    id_usuario INT,
    CONSTRAINT FK_Cliente_Direccion FOREIGN KEY (id_direccion) REFERENCES Direccion(id_direccion),
    CONSTRAINT FK_Cliente_Usuario FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario)
);

GO

CREATE TABLE Repuesto (
    id_repuesto INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(150) NOT NULL,
    marca VARCHAR(100),
    stock INT,
    id_proveedor INT,
    id_categoria_repuesto INT,
    CONSTRAINT FK_Repuesto_Proveedor FOREIGN KEY (id_proveedor) REFERENCES Proveedor(id_proveedor),
    CONSTRAINT FK_Repuesto_Categoria FOREIGN KEY (id_categoria_repuesto) REFERENCES CategoriaRepuesto(id_categoria_repuesto)
);

CREATE TABLE Equipo (
    id_equipo INT PRIMARY KEY IDENTITY(1,1),
    id_cliente INT NOT NULL,
    id_tipo INT,
    id_modelo INT,
    CONSTRAINT FK_Equipo_Cliente FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    CONSTRAINT FK_Equipo_Tipo FOREIGN KEY (id_tipo) REFERENCES Tipo(id_tipo),
    CONSTRAINT FK_Equipo_Modelo FOREIGN KEY (id_modelo) REFERENCES Modelo(id_modelo)
);

CREATE TABLE ingreso_equipo (
    id_ingreso_equipo INT,
    falla VARCHAR(1000),
    fecha_ingreso DATETIME DEFAULT GETDATE(),
    id_cliente INT,
    id_equipo INT,
    CONSTRAINT PK_ingreso_equipo PRIMARY KEY(id_cliente, id_equipo, id_ingreso_equipo),
    CONSTRAINT FK_ingreso_cliente FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    CONSTRAINT FK_ingreso_equipo FOREIGN KEY (id_equipo) REFERENCES Equipo(id_equipo)
);

GO

CREATE TABLE Diagnostico (
    id_diagnostico INT PRIMARY KEY IDENTITY(1,1),
    motivo VARCHAR(1000), -- Se detalla análisis, motivo y solución
    fecha_diagnostico DATETIME,
    costo_estimado DECIMAL(10, 2),
    id_equipo INT,
    id_emp INT, -- Se referencia a la tabla usuario 
    CONSTRAINT FK_Diagnostico_Equipo FOREIGN KEY (id_equipo) REFERENCES Equipo(id_equipo),
    CONSTRAINT FK_Diagnostico_Empleado FOREIGN KEY (id_emp) REFERENCES Usuario(id_usuario)
);

GO

CREATE TABLE Reparacion (
    id_reparacion INT PRIMARY KEY IDENTITY(1,1),
    fecha_resolucion DATETIME,
    id_diagnostico INT,
    id_estadoReparacion INT,
    monto_total DECIMAL(10, 2),
    CONSTRAINT FK_Reparacion_Diagnostico FOREIGN KEY (id_diagnostico) REFERENCES Diagnostico(id_diagnostico),
    CONSTRAINT FK_Reparacion_Estado FOREIGN KEY (id_estadoReparacion) REFERENCES EstadoReparacion(id_estadoReparacion)
);

GO

CREATE TABLE Repuesto_Reparacion (
    id_reparacion INT NOT NULL,
    id_repuesto INT NOT NULL,
    CONSTRAINT PK_RepuestoReparacion PRIMARY KEY (id_reparacion, id_repuesto),
    CONSTRAINT FK_RepRep_Reparacion FOREIGN KEY (id_reparacion) REFERENCES Reparacion(id_reparacion),
    CONSTRAINT FK_RepRep_Repuesto FOREIGN KEY (id_repuesto) REFERENCES Repuesto(id_repuesto)
);

GO

CREATE TABLE Factura (
    id_factura INT PRIMARY KEY IDENTITY(1,1),
    id_cliente INT,
    id_reparacion INT,
    importe DECIMAL(10, 2),
    fecha_emision DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Factura_Cliente FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    CONSTRAINT FK_Factura_Reparacion FOREIGN KEY (id_reparacion) REFERENCES Reparacion(id_reparacion)
);

GO

-- Nivel 7: Tablas finales
PRINT 'Creando tablas de Nivel 7...'

CREATE TABLE Pago (
    id_pago INT PRIMARY KEY IDENTITY(1,1),
    id_medioDePago INT,
    id_factura INT,
    monto DECIMAL(10, 2),
    CONSTRAINT FK_Pago_MedioDePago FOREIGN KEY (id_medioDePago) REFERENCES MedioDePago(id_medioDePago),
    CONSTRAINT FK_Pago_Factura FOREIGN KEY (id_factura) REFERENCES Factura(id_factura)
);

GO

PRINT 'Script completado. Todas las tablas han sido creadas.'CREATE DATABASE servicio_tecnico_informatico

USE servicio_tecnico_informatico

CREATE TABLE Marca (
    id_marca INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE Tipo (
    id_tipo INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE EstadoReparacion (
    id_estadoReparacion INT PRIMARY KEY IDENTITY(1,1),
    descripcion VARCHAR(255)
);

CREATE TABLE MedioDePago (
    id_medioDePago INT PRIMARY KEY IDENTITY(1,1),
    descripcion VARCHAR(100)
);

CREATE TABLE CategoriaRepuesto (
    id_categoria_repuesto INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100)
);

CREATE TABLE Direccion (
    id_direccion INT PRIMARY KEY IDENTITY(1,1),
    direccion VARCHAR(255),  
    calle VARCHAR(150),
    altura VARCHAR(20),
    piso VARCHAR(10),
    depto VARCHAR(10),
    numero_depto VARCHAR(10)
);

CREATE TABLE rol (
    id_rol INT PRIMARY KEY,
    descripcion VARCHAR(50)
)

CREATE TABLE Usuario (
    id_usuario INT PRIMARY KEY IDENTITY(1,1),
    usuario VARCHAR(50) NOT NULL UNIQUE,
    nombre VARCHAR(100),
    apellido VARCHAR(100),
    id_rol INT, 
    email VARCHAR(100) NOT NULL UNIQUE,
    contraseña VARCHAR(255) NOT NULL
);

ALTER TABLE usuario
    ADD CONSTRAINT FK_usuario_rol FOREIGN KEY(id_rol) REFERENCES rol(id_rol)

GO

CREATE TABLE Proveedor (
    id_proveedor INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(150),
    id_categoria_repuesto INT,
    CONSTRAINT FK_Proveedor_Categoria FOREIGN KEY (id_categoria_repuesto) REFERENCES CategoriaRepuesto(id_categoria_repuesto)
);

CREATE TABLE Modelo (
    id_modelo INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100),
    id_marca INT,
    CONSTRAINT FK_Modelo_Marca FOREIGN KEY (id_marca) REFERENCES Marca(id_marca)
);

CREATE TABLE Cliente (
    id_cliente INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    dni VARCHAR(20) UNIQUE,
    telefono VARCHAR(50),
    id_direccion INT,
    email VARCHAR(100) UNIQUE,
    id_usuario INT,
    CONSTRAINT FK_Cliente_Direccion FOREIGN KEY (id_direccion) REFERENCES Direccion(id_direccion),
    CONSTRAINT FK_Cliente_Usuario FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario)
);

GO

CREATE TABLE Repuesto (
    id_repuesto INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(150) NOT NULL,
    marca VARCHAR(100),
    stock INT,
    id_proveedor INT,
    id_categoria_repuesto INT,
    CONSTRAINT FK_Repuesto_Proveedor FOREIGN KEY (id_proveedor) REFERENCES Proveedor(id_proveedor),
    CONSTRAINT FK_Repuesto_Categoria FOREIGN KEY (id_categoria_repuesto) REFERENCES CategoriaRepuesto(id_categoria_repuesto)
);

CREATE TABLE Equipo (
    id_equipo INT PRIMARY KEY IDENTITY(1,1),
    id_cliente INT NOT NULL,
    id_tipo INT,
    id_modelo INT,
    CONSTRAINT FK_Equipo_Cliente FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    CONSTRAINT FK_Equipo_Tipo FOREIGN KEY (id_tipo) REFERENCES Tipo(id_tipo),
    CONSTRAINT FK_Equipo_Modelo FOREIGN KEY (id_modelo) REFERENCES Modelo(id_modelo)
);

CREATE TABLE ingreso_equipo (
    id_ingreso_equipo INT,
    falla VARCHAR(1000),
    fecha_ingreso DATETIME DEFAULT GETDATE(),
    id_cliente INT,
    id_equipo INT,
    CONSTRAINT PK_ingreso_equipo PRIMARY KEY(id_cliente, id_equipo, id_ingreso_equipo),
    CONSTRAINT FK_ingreso_cliente FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    CONSTRAINT FK_ingreso_equipo FOREIGN KEY (id_equipo) REFERENCES Equipo(id_equipo)
);

GO

CREATE TABLE Diagnostico (
    id_diagnostico INT PRIMARY KEY IDENTITY(1,1),
    motivo VARCHAR(1000), -- Se detalla análisis, motivo y solución
    fecha_diagnostico DATETIME DEFAULT GETDATE(),
    costo_estimado DECIMAL(10, 2),
    id_equipo INT,
    id_emp INT, -- Se referencia a la tabla usuario 
    CONSTRAINT FK_Diagnostico_Equipo FOREIGN KEY (id_equipo) REFERENCES Equipo(id_equipo),
    CONSTRAINT FK_Diagnostico_Empleado FOREIGN KEY (id_emp) REFERENCES Usuario(id_usuario)
);

GO

CREATE TABLE Reparacion (
    id_reparacion INT PRIMARY KEY IDENTITY(1,1),
    fecha_estimada DATE,
    fecha_resolucion DATETIME,
    id_diagnostico INT,
    id_estadoReparacion INT,
    monto_total DECIMAL(10, 2),
    CONSTRAINT FK_Reparacion_Diagnostico FOREIGN KEY (id_diagnostico) REFERENCES Diagnostico(id_diagnostico),
    CONSTRAINT FK_Reparacion_Estado FOREIGN KEY (id_estadoReparacion) REFERENCES EstadoReparacion(id_estadoReparacion)
);

GO

CREATE TABLE Repuesto_Reparacion (
    id_reparacion INT NOT NULL,
    id_repuesto INT NOT NULL,
    CONSTRAINT PK_RepuestoReparacion PRIMARY KEY (id_reparacion, id_repuesto), -- Clave primaria compuesta
    CONSTRAINT FK_RepRep_Reparacion FOREIGN KEY (id_reparacion) REFERENCES Reparacion(id_reparacion),
    CONSTRAINT FK_RepRep_Repuesto FOREIGN KEY (id_repuesto) REFERENCES Repuesto(id_repuesto)
);

GO

CREATE TABLE Factura (
    id_factura INT PRIMARY KEY IDENTITY(1,1),
    id_cliente INT,
    fecha_emision DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Factura_Cliente FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
);
GO


CREATE TABLE Pago (
    id_pago INT PRIMARY KEY IDENTITY(1,1),
    id_medioDePago INT,
    id_factura INT,
    monto DECIMAL(10, 2),
    id_reparacion INT,
    CONSTRAINT FK_Pago_MedioDePago FOREIGN KEY (id_medioDePago) REFERENCES MedioDePago(id_medioDePago),
    CONSTRAINT FK_Pago_Reparacion FOREIGN KEY (id_reparacion) REFERENCES Reparacion(id_reparacion),
    CONSTRAINT FK_Pago_Factura FOREIGN KEY (id_factura) REFERENCES Factura(id_factura)
);
GO
