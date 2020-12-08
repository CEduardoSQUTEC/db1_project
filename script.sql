CREATE DATABASE Casboni;

--------------------------------------------
-- Entidades
--------------------------------------------
-- Cliente
CREATE TABLE Cliente (
    id bigserial,
    PRIMARY KEY (id)
);

-- Persona_Natural
CREATE TABLE Persona_Natural (
    id bigserial,
    dni serial,
    nombre varchar(50),
    apellido varchar(50),
    ruc_natural bigserial,
    PRIMARY KEY (id)
);

-- Persona_Juridica
CREATE TABLE Persona_Juridica (
    id bigserial,
    nombre varchar(50),
    ruc_empresarial bigserial,
    PRIMARY KEY (id)
);

-- Comprobante
CREATE TABLE Comprobante (
    numero bigserial,
    id_tienda smallserial,
    id_cliente bigserial,
    total real,
    igv real,
    subtotal real,
    fecha timestamp,
    cantidad serial,
    PRIMARY KEY (numero),
    FOREIGN KEY (id_tienda),
    REFERENCES Tienda (id),
    FOREIGN KEY (id_cliente),
    REFERENCES Cliente (id)
);

-- Modelo
CREATE TABLE Modelo (
    nombre varchar(50),
    ano smallserial,
    marca varchar(50)
);

CREATE TABLE Kardex (
    id bigserial,
    id_tienda smallserial,
    nro_comprobante_ingreso bigserial,
    tipo_operacion smallserial,
    PRIMARY KEY (id),
    FOREIGN KEY (id_tienda),
    REFERENCES Tienda (id),
    FOREIGN KEY (id_ingreso),
    REFERENCES Ingreso (nro_comprobante)
);

-- Tienda
CREATE TABLE Tienda (
    id smallserial,
    nombre varchar(255),
    id_kardex bigserial,
    PRIMARY KEY (id)
    FOREIGN KEY (id_kardex),
    REFERENCES Kardex (id),
);

-- Vehiculo
CREATE TABLE Vehiculo (
    placa varchar(6),
    nVim varchar(17),
    nMotor varchar(14),
    modelo_nombre varchar(50),
    modelo_marca varchar(50),
    modelo_ano varchar(50),
    color varchar(6),
    PRIMARY KEY (placa),
    FOREIGN KEY (modelo_nombre),
    REFERENCES Modelo (nombre),
    FOREIGN KEY (modelo_marca),
    REFERENCES Modelo (marca),
    FOREIGN KEY (modelo_ano),
    REFERENCES Modelo (ano)
);

-- Distribuidor
CREATE TABLE Distribuidor (
    nombre varchar(255),
    id integer,
    PRIMARY KEY (id)
);

-- Ingreso
CREATE TABLE Ingreso (
    nro_comprobante bigserial,
    fecha timestamp,
    PRIMARY KEY (nro_comprobante),
);

-- Categoria
CREATE TABLE Categoria (
    id serial,
    id_padre serial,
    nombre varchar(25),
    PRIMARY KEY (id)
);

-- Producto
CREATE TABLE Producto (
    marca varchar(50),
    codigo varchar(50),
    id_categoria serial,
    imagen varchar(50),
    documentacion varchar(50),
    descripcion varchar(50),
    documentacion varchar(70),
    u_medida varchar(20),
    PRIMARY KEY (marca),
    PRIMARY KEY (codigo),
    FOREIGN KEY (id_categoria),
    REFERENCES Categoria (id)
);

--------------------------------------------
-- Relaciones
--------------------------------------------
-- Compatible
CREATE TABLE Compatible (
    modelo_nombre varchar(50),
    modelo_marca varchar(50),
    modelo_ano varchar(50),
    producto_marca varchar(50),
    producto_codigo varchar(50),
    PRIMARY KEY (modelo_nombre),
    PRIMARY KEY (modelo_marca),
    PRIMARY KEY (modelo_ano),
    PRIMARY KEY (producto_marca),
    PRIMARY KEY (producto_codigo),
    REFERENCES Modelo (nombre),
    FOREIGN KEY (modelo_marca),
    REFERENCES Modelo (marca),
    FOREIGN KEY (modelo_ano),
    REFERENCES Modelo (ano),
    FOREIGN KEY (producto_marca),
    REFERENCES Producto (marca)
    FOREIGN KEY (producto_codigo),
    REFERENCES Producto (codigo)
);

-- Posee
CREATE TABLE Posee (
    id_cliente bigserial,
    placa_vehiculo varchar(10),
    PRIMARY KEY (id_cliente),
    FOREIGN KEY (placa_vehiculo),
    REFERENCES Cliente (id)
);

-- Provee
CREATE TABLE Provee (
    producto_marca varchar(50),
    producto_codigo varchar(50),
    nro_comprobante_ingreso varchar(10),
    cantidad bigserial,
    precio_unitario real,
    PRIMARY KEY (producto_marca),
    PRIMARY KEY (producto_codigo),
    PRIMARY KEY (id_ingreso),
    FOREIGN KEY (producto_marca),
    REFERENCES Producto (marca),
    FOREIGN KEY (producto_codigo),
    REFERENCES Producto (codigo),
    FOREIGN KEY (id_ingreso),
    REFERENCES Ingreso (nro_comprobante)
);

-- Distribuye
CREATE TABLE Distribuye (
    id_distribuidor varchar(10),
    nro_comprobante_ingreso varchar(10),
    PRIMARY KEY (id_distribuidor),
    PRIMARY KEY (nro_comprobante_ingreso),
    FOREIGN KEY (id_distribuidor),
    REFERENCES Distribuidor (id),
    FOREIGN KEY (nro_comprobante_ingreso),
    REFERENCES Ingreso (nro_comprobante)
);

-- Tiene
CREATE TABLE Tiene (
    id_kardex bigserial,
    id_distribuidor varchar(10)
    FOREIGN KEY (id_kardex),
    REFERENCES Kardex (id),
    FOREIGN KEY (id_distribuidor),
    REFERENCES Distribuidor (id)
);

-- Sigue
CREATE TABLE Sigue (
    producto_marca varchar(50),
    producto_codigo varchar(50),
    id_kardex bigserial,
    PRIMARY KEY (producto_marca),
    PRIMARY KEY (producto_codigo),
    PRIMARY KEY (id_kardex),
    REFERENCES Producto (marca),
    FOREIGN KEY (producto_codigo),
    REFERENCES Producto (codigo),
    FOREIGN KEY (id_ingreso),
    REFERENCES Ingreso (nro_comprobante),
    FOREIGN KEY (id_kardex),
    REFERENCES Kardex (id)
);

-- Stock
CREATE TABLE Stock (
    producto_marca varchar(50),
    producto_codigo varchar(50),
    id_tienda smallserial,
    cantidad serial,
    PRIMARY KEY (producto_marca),
    PRIMARY KEY (producto_codigo),
    PRIMARY KEY (tienda),
    REFERENCES Producto (marca),
    FOREIGN KEY (producto_codigo),
    REFERENCES Producto (codigo),
    FOREIGN KEY (id_ingreso),
    FOREIGN KEY (id_tienda),
    REFERENCES Tienda (id)
);

-- Aparece
CREATE TABLE Aparece (
    producto_marca varchar(50),
    producto_codigo varchar(50),
    nro_comprobante bigserial,
    cantidad serial,
    precio_unitario real,
    PRIMARY KEY (producto_marca),
    PRIMARY KEY (producto_codigo),
    PRIMARY KEY (nro_comprobante),
    REFERENCES Producto (marca),
    FOREIGN KEY (producto_codigo),
    REFERENCES Producto (codigo),
    FOREIGN KEY (nro_comprobante),
    REFERENCES Comprobante (codigo)
);