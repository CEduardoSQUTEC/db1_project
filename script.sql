CREATE DATABASE Casboni;

CREATE TABLE Vehiculo (
    placa varchar(6),
    nVim varchar(17),
    nMotor varchar(14),
    PRIMARY KEY (placa)
);

CREATE TABLE Tienda (
    nombre varchar(255),
    id integer,
    PRIMARY KEY (id)
);

CREATE TABLE Distribuidor (
    nombre varchar(255),
    id integer,
    PRIMARY KEY (id)
);

CREATE TABLE Producto (
    cantidad bigint,
    descripcion varchar(255),
    precio_unitario decimal,
    u_medida decimal,
    documentacion varchar(255),
    codigo integer,
    -- id_distribuidor integer,
    imagen varchar(255),
    PRIMARY KEY (codigo),
    -- FOREIGN KEY (id_distribuidor)
    -- REFERENCES Distribuidor (id),
);

CREATE TABLE Kardex (
    tipo_de_operacion varchar(255),
    cantidad integer,
    id_traslado integer,
    id_tienda integer,
    id_producto integer,
    PRIMARY KEY (id_traslado)
    FOREIGN KEY (id_tienda)
    REFERENCES Tienda (id_tienda),
    FOREIGN KEY (id_producto)
    REFERENCES Producto (codigo),
);

CREATE TABLE Categoria (
    nombre varchar(100),
    id integer,
    id_padre integer,
    PRIMARY KEY (id)
)