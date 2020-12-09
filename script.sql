CREATE DATABASE Casboni;

--------------------------------------------
-- Entidades
--------------------------------------------
-- 1k, 10k 100k y 10^6

-- Cliente
CREATE TABLE Cliente (
    id bigserial,
    PRIMARY KEY (id)
);

-- Persona_Natural
CREATE TABLE Persona_Natural (
    id bigserial,
    dni serial,
    nombre varchar(50) not null,
    apellido varchar(50) not null,
    ruc_natural bigserial not null,
    PRIMARY KEY (id)
);

-- Persona_Juridica
CREATE TABLE Persona_Juridica (
    id bigserial,
    nombre varchar(50) not null,
    ruc_empresarial bigserial not null,
    PRIMARY KEY (id)
);

-- Ingreso
CREATE TABLE Ingreso (
    nro_comprobante varchar(50),
    fecha timestamp,
    PRIMARY KEY (nro_comprobante)
);

-- Tienda
CREATE TABLE Tienda (
    id serial,
    nombre varchar(255),
    PRIMARY KEY (id)
);

CREATE TABLE Kardex (
    id bigserial,
    id_tienda serial,
    nro_comprobante_ingreso varchar(50),
    tipo_operacion serial,
    PRIMARY KEY (id),
    FOREIGN KEY (id_tienda)
    REFERENCES Tienda (id),
    FOREIGN KEY (nro_comprobante_ingreso)
    REFERENCES Ingreso (nro_comprobante)
);

-- Comprobante
CREATE TABLE Comprobante (
    numero bigserial,
    --numero varchar(50)
    id_tienda serial,
    id_cliente bigserial,
    total real,
    igv double precision,
    subtotal double precision,
    fecha timestamp,
    cantidad int not null default 0,
    PRIMARY KEY (numero),
    FOREIGN KEY (id_tienda)
    REFERENCES Tienda (id),
    FOREIGN KEY (id_cliente)
    REFERENCES Cliente (id),

    CHECK(cantidad > 0)
);

-- Modelo
CREATE TABLE Modelo (
    nombre varchar(50),
    ano serial,
    marca varchar(50),
    PRIMARY KEY (nombre, ano, marca)
);

-- Vehiculo
CREATE TABLE Vehiculo (
    placa varchar(6),
    nVim varchar(17),
    nMotor varchar(14),
    modelo_nombre varchar(50),
    modelo_ano serial,
    modelo_marca varchar(50),
    color varchar(8),
    PRIMARY KEY (placa),
    FOREIGN KEY (modelo_nombre, modelo_ano, modelo_marca)
    REFERENCES Modelo (nombre, ano, marca)
);

-- Distribuidor
CREATE TABLE Distribuidor (
    nombre varchar(255),
    id integer,
    PRIMARY KEY (id)
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
    id_categoria serial not null,
    imagen varchar(50),
    documentacion varchar(50),
    descripcion varchar(50),
    u_medida varchar(20),
    PRIMARY KEY (marca, codigo),
    FOREIGN KEY (id_categoria)
    REFERENCES Categoria (id)
);

--------------------------------------------
-- Relaciones
--------------------------------------------
-- Compatible

--no me convence :(
CREATE TABLE Compatible (
    modelo_nombre varchar(50),
    modelo_marca varchar(50),
    modelo_ano serial,
    producto_marca varchar(50),
    producto_codigo varchar(50),
    PRIMARY KEY (producto_marca, producto_codigo),
    FOREIGN KEY (modelo_nombre, modelo_ano, modelo_marca)
    REFERENCES Modelo (nombre, ano, marca),
    FOREIGN KEY (producto_marca, producto_codigo)
    REFERENCES Producto (marca, codigo)
);

-- Posee
CREATE TABLE Posee (
    id_cliente bigserial,
    placa_vehiculo varchar(10),
    PRIMARY KEY (id_cliente),
    FOREIGN KEY (placa_vehiculo)
    REFERENCES Vehiculo (placa)
);

-- Provee
CREATE TABLE Provee (
    producto_marca varchar(50),
    producto_codigo varchar(50),
    nro_comprobante_ingreso varchar(10),
    cantidad int not null default 0,
    precio_unitario real,
    PRIMARY KEY (producto_marca, producto_codigo, nro_comprobante_ingreso),
    FOREIGN KEY (producto_marca, producto_codigo)
    REFERENCES Producto (marca, codigo),
    FOREIGN KEY (nro_comprobante_ingreso)
    REFERENCES Ingreso (nro_comprobante),

    CHECK(cantidad > 0)
);

-- Distribuye
CREATE TABLE Distribuye (
    id_distribuidor integer,
    nro_comprobante_ingreso varchar(50),
    PRIMARY KEY (id_distribuidor, nro_comprobante_ingreso),
    FOREIGN KEY (id_distribuidor)
    REFERENCES Distribuidor (id),
    FOREIGN KEY (nro_comprobante_ingreso)
    REFERENCES Ingreso (nro_comprobante)
);

-- Tiene
CREATE TABLE Tiene (
    id_kardex bigserial,
    id_distribuidor integer,
    FOREIGN KEY (id_kardex)
    REFERENCES Kardex (id),
    FOREIGN KEY (id_distribuidor)
    REFERENCES Distribuidor (id)
);

-- Sigue
CREATE TABLE Sigue (
    id_kardex bigserial,
    producto_marca varchar(50),
    producto_codigo varchar(50),
    nro_comprobante_ingreso varchar(50),
    PRIMARY KEY (id_kardex, producto_marca, producto_codigo),
    FOREIGN KEY (producto_marca, producto_codigo)
    REFERENCES Producto (marca, codigo),
    FOREIGN KEY (nro_comprobante_ingreso)
    REFERENCES Ingreso (nro_comprobante),
    FOREIGN KEY (id_kardex)
    REFERENCES Kardex (id)
);

-- Stock
CREATE TABLE Stock (
    id_tienda serial,
    producto_marca varchar(50),
    producto_codigo varchar(50),
    cantidad int not null default 0,
    PRIMARY KEY (id_tienda, producto_marca, producto_codigo),
    FOREIGN KEY (id_tienda)
    REFERENCES Tienda (id),
    FOREIGN KEY (producto_marca, producto_codigo)
    REFERENCES Producto (marca, codigo),
    
    CHECK(cantidad > 0)
);

-- Aparece
CREATE TABLE Aparece (
    producto_marca varchar(50),
    producto_codigo varchar(50),
    nro_comprobante bigserial,
    cantidad int not null default 0,
    precio_unitario real,
    PRIMARY KEY (nro_comprobante, producto_marca, producto_codigo),
    FOREIGN KEY (producto_marca, producto_codigo)
    REFERENCES Producto (marca, codigo),
    FOREIGN KEY (nro_comprobante)
    REFERENCES Comprobante (numero),

    CHECK(cantidad > 0)
);


-- ya funca
CREATE FUNCTION shop_item(tienda_id int, producto_marca varchar(50), producto_codigo varchar(50), cantidad_comprada int, comprobante varchar(50))
RETURNS null AS
BEGIN 
  --update a stock
  UPDATE Stock
  SET cantidad = cantidad - cantidad_comprada
  WHERE Stock.id_tienda = tienda_id 
  AND Stock.producto_marca = producto_marca, 
  AND Stock.producto_codigo = producto_codigo;

  --insert into Kardex
  INSERT INTO Kardex(id_tienda, nro_comprobante_ingreso, tipo_operacion) --provisional
  VALUES(tienda_id, comprobante, 'VENTA'); --provisional
  
  --insert into Sigue
  INSERT INTO Sigue(producto_marca, producto_codigo)
  VALUES(producto_marca, producto_codigo); 

END;
language 'plpgsql';


CREATE FUNCTION add_item(tienda_id int, producto_marca varchar(50), producto_codigo varchar(50), cantidad_adquirida int, comprobante varchar(50))
RETURNS null AS
BEGIN 
  --update a stock
  UPDATE Stock
  SET cantidad = cantidad + cantidad_adquirida
  WHERE Stock.id_tienda = tienda_id 
  AND Stock.producto_marca = producto_marca, 
  AND Stock.producto_codigo = producto_codigo;

  --insert into Kardex
  INSERT INTO Kardex(id_tienda, nro_comprobante_ingreso, tipo_operacion) --provisional
  VALUES(tienda_id, comprobante, 'COMPRA'); --provisional
  
  --insert into Sigue
  INSERT INTO Sigue(producto_marca, producto_codigo)
  VALUES(producto_marca, producto_codigo); 

END;
language 'plpgsql';


CREATE FUNCTION transfer_item(tienda_id int, producto_marca varchar(50), producto_codigo varchar(50), cantidad_transferida int, tienda_destino_id)
RETURNS null AS
BEGIN 
  --update a stock de la tienda origen
  UPDATE Stock
  SET cantidad = cantidad - cantidad_transferida
  WHERE Stock.id_tienda = tienda_destino_id 
  AND Stock.producto_marca = producto_marca, 
  AND Stock.producto_codigo = producto_codigo;

  --update a stock de la tienda destino
  UPDATE Stock
  SET cantidad = cantidad + cantidad_transferida
  WHERE Stock.id_tienda = tienda_destino_id 
  AND Stock.producto_marca = producto_marca, 
  AND Stock.producto_codigo = producto_codigo;

  --insert into Kardex 
  INSERT INTO Kardex(id_tienda, nro_comprobante_ingreso, tipo_operacion) --provisional
  VALUES(tienda_id, comprobante, 'TRASLADO'); --provisional
  
  --insert into Sigue
  INSERT INTO Sigue(producto_marca, producto_codigo)
  VALUES(producto_marca, producto_codigo); 

END;
language 'plpgsql';



