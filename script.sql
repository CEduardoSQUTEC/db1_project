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
    nro_comprobante varchar(10),
    fecha timestamp,
    PRIMARY KEY (nro_comprobante)
);

-- Tienda
CREATE TABLE Tienda (
    id serial,
    nombre varchar(255),
    PRIMARY KEY (id)
);

-- Kardex
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
    modelo_marca varchar(50),
    modelo_ano serial,
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
    PRIMARY KEY (modelo_nombre, modelo_ano, modelo_marca, producto_marca, producto_codigo),
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
    PRIMARY KEY (id_kardex, producto_marca, producto_codigo, nro_comprobante_ingreso),
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

-----------------------------------------------------------------------------
-------------------- Procedures, ramdon functions and more ------------------
-----------------------------------------------------------------------------
Create or replace function random_string(length integer) returns text as
$$
declare
  chars text[] := '{0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}';
  result text := '';
  i integer := 0;
begin
  if length < 0 then
    raise exception 'Given length cannot be less than 0';
  end if;
  for i in 1..length loop
    result := result || chars[1+random()*(array_length(chars, 1)-1)];
  end loop;
  return result;
end;
$$ language plpgsql;


CREATE OR REPLACE FUNCTION random_between(low INT ,high INT) 
   RETURNS INT AS
$$
BEGIN
   RETURN floor(random()* (high-low + 1) + low);
END;
$$ language 'plpgsql' STRICT;


---------------------------------------------
-- Vehiculo
-- select count(*) from vehiculo;

DO
$$
DECLARE 
    i record;
    mo_nombrex varchar(50);
    mo_marcax varchar(50);
    mo_anox int;
    num int;
begin
	select into num 0;
    FOR i IN SELECT nombre, ano, marca from modelo  
    LOOP
        SELECT INTO mo_nombrex, mo_anox, mo_marcax nombre, ano, marca FROM modelo ORDER BY random() LIMIT 1;
        INSERT INTO vehiculo values(num, 'nvim', 'motor', mo_nombrex, mo_marcax, mo_anox, '#ffffff');
        select into num num+1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- Compatible
-- select count(*) from compatible;

DO
$$
DECLARE 
	i record;
	mo_nombrex varchar(50);
	mo_marcax varchar(50);
	mo_anox int;
	pro_marca varchar(50);
	pro_codigo varchar(50);
	num int;
begin
	select into num 0;
    FOR i IN SELECT marca from producto 
    LOOP
		SELECT INTO mo_nombrex, mo_anox, mo_marcax nombre, ano, marca FROM modelo ORDER BY random() LIMIT 1;
		SELECT INTO pro_marca, pro_codigo marca, codigo FROM producto ORDER BY random() LIMIT 1;
		INSERT INTO compatible values(mo_nombrex, mo_marcax, mo_anox, pro_marca, pro_codigo);
		select into num num+1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- Ingreso
-- select count(*) from ingreso;

DO
$$
DECLARE 
	i record;
	num int;
begin
	select into num 0;
    FOR i IN SELECT marca from producto 
    LOOP
		INSERT INTO ingreso values(random_string(10),CURRENT_TIMESTAMP);
		select into num num+1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- Provee
-- select count(*) from provee;

DO
$$
DECLARE 
	i record;
	pro_marca varchar(50);
	pro_codigo varchar(50);
	ing_num_comp varchar(10);
	mo_anox int;
	num int;
begin
	select into num 0;
    FOR i IN SELECT nro_comprobante from ingreso  
    LOOP
		SELECT INTO pro_marca, pro_codigo marca, codigo FROM producto ORDER BY random() LIMIT 1;
		SELECT INTO ing_num_comp nro_comprobante FROM ingreso ORDER BY random() LIMIT 1;
		INSERT INTO provee values(pro_marca, pro_codigo, ing_num_comp, random_between(1,1000), random_between(1,1000));
		select into num num+1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- Stock
-- select count(*) from stock;

DO
$$
DECLARE 
	i record;
	id_tien int;
	pro_marca varchar(50);
	pro_codigo varchar(50);
	num int;
begin
	select into num 0;
    FOR i IN SELECT marca from producto 
    LOOP
		SELECT INTO pro_marca, pro_codigo marca, codigo FROM producto ORDER BY random() LIMIT 1;
		SELECT INTO id_tien id FROM tienda ORDER BY random() LIMIT 1 ;
		INSERT INTO stock values(id_tien, pro_marca, pro_codigo, random_between(1,1000));
		select into num num+1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- Aparece
-- select count(*) from aparece;

DO
$$
DECLARE 
	i record;
	pro_marca varchar(50);
	pro_codigo varchar(50);
	nro_comp int;
	num int;
begin
	select into num 0;
    FOR i IN SELECT marca from producto 
    LOOP
		SELECT INTO pro_marca, pro_codigo marca, codigo FROM producto ORDER BY random() LIMIT 1;
		SELECT INTO nro_comp numero FROM comprobante ORDER BY random() LIMIT 1;
		INSERT INTO aparece values(pro_marca, pro_codigo, nro_comp, random_between(1,1000), random_between(1,10000));
		select into num num+1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- Sigue
-- select count(*) from sigue;

DO
$$
DECLARE 
	i record;
	id_kar int;
	pro_marca varchar(50);
	pro_codigo varchar(50);
	ing_num_comp varchar(10);
	num int;
begin
	select into num 0;
    FOR i IN SELECT marca from producto 
    LOOP
		SELECT INTO pro_marca, pro_codigo marca, codigo FROM producto ORDER BY random() LIMIT 1;
		SELECT INTO id_kar id FROM kardex ORDER BY random() LIMIT 1;
		SELECT INTO ing_num_comp nro_comprobante FROM ingreso ORDER BY random() LIMIT 1;
		INSERT INTO sigue values(id_kar, pro_marca, pro_codigo, ing_num_comp);
		select into num num+1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

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



