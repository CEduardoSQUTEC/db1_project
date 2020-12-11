CREATE DATABASE Casboni;

--------------------------------------------
-- Entidades
--------------------------------------------
-- 1k, 10k 100k y 10^6
create schema millon;

-- Cliente
CREATE TABLE millon.Cliente (
    id bigserial,
    PRIMARY KEY (id)
);

-- Persona_Natural
CREATE TABLE millon.Persona_Natural (
    id bigserial,
    dni serial,
    nombre varchar(50) not null,
    apellido varchar(50) not null,
    ruc_natural bigserial not null,
    PRIMARY KEY (id)
);

-- Persona_Juridica
CREATE TABLE millon.Persona_Juridica (
    id bigserial,
    nombre varchar(50) not null,
    ruc_empresarial bigserial not null,
    PRIMARY KEY (id)
);

-- Ingreso -- con procedure
CREATE TABLE millon.Ingreso (
    nro_comprobante varchar(10),
    fecha timestamp,
    PRIMARY KEY (nro_comprobante)
);

-- Tienda
CREATE TABLE millon.Tienda (
    id serial,
    nombre varchar(255),
    PRIMARY KEY (id)
);

-- Kardex
CREATE TABLE millon.Kardex (
    id bigserial,
    id_tienda serial,
    nro_comprobante_ingreso varchar(50),
    tipo_operacion serial,
    PRIMARY KEY (id),
    FOREIGN KEY (id_tienda)
    REFERENCES millon.Tienda (id),
    FOREIGN KEY (nro_comprobante_ingreso)
    REFERENCES millon.Ingreso (nro_comprobante)
);

-- Comprobante
CREATE TABLE millon.Comprobante (
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
    REFERENCES millon.Tienda (id),
    FOREIGN KEY (id_cliente)
    REFERENCES millon.Cliente (id),

    CHECK(cantidad > 0)
);

-- Modelo
CREATE TABLE millon.Modelo (
    nombre varchar(50),
    ano serial,
    marca varchar(50),
    PRIMARY KEY (nombre, ano, marca)
);

-- Vehiculo -- con procedure
CREATE TABLE millon.Vehiculo (
    placa varchar(6),
    nVim varchar(17),
    nMotor varchar(14),
    modelo_nombre varchar(50),
    modelo_marca varchar(50),
    modelo_ano serial,
    color varchar(8),
    PRIMARY KEY (placa),
    FOREIGN KEY (modelo_nombre, modelo_ano, modelo_marca)
    REFERENCES millon.Modelo (nombre, ano, marca)
);

-- Distribuidor
CREATE TABLE millon.Distribuidor (
    nombre varchar(255),
    id integer,
    PRIMARY KEY (id)
);

-- Categoria
CREATE TABLE millon.Categoria (
    id serial,
    id_padre serial,
    nombre varchar(25),
    PRIMARY KEY (id)
);

-- Producto
CREATE TABLE millon.Producto (
    marca varchar(50),
    codigo varchar(50),
    id_categoria serial not null,
    imagen varchar(50),
    documentacion varchar(50),
    descripcion varchar(50),
    u_medida varchar(20),
    PRIMARY KEY (marca, codigo),
    FOREIGN KEY (id_categoria)
    REFERENCES millon.Categoria (id)
);

--------------------------------------------
-- Relaciones
--------------------------------------------
-- Compatible -- con procedure
CREATE TABLE millon.Compatible (
    modelo_nombre varchar(50),
    modelo_marca varchar(50),
    modelo_ano serial,
    producto_marca varchar(50),
    producto_codigo varchar(50),
    PRIMARY KEY (modelo_nombre, modelo_ano, modelo_marca, producto_marca, producto_codigo),
    FOREIGN KEY (modelo_nombre, modelo_ano, modelo_marca)
    REFERENCES millon.Modelo (nombre, ano, marca),
    FOREIGN KEY (producto_marca, producto_codigo)
    REFERENCES millon.Producto (marca, codigo)
);

-- Posee
CREATE TABLE millon.Posee (
    id_cliente bigserial,
    placa_vehiculo varchar(10),
    PRIMARY KEY (id_cliente),
    FOREIGN KEY (placa_vehiculo)
    REFERENCES millon.Vehiculo (placa)
);

-- Provee -- con procedure
CREATE TABLE millon.Provee (
    producto_marca varchar(50),
    producto_codigo varchar(50),
    nro_comprobante_ingreso varchar(10),
    cantidad int not null default 0,
    precio_unitario real,
    PRIMARY KEY (producto_marca, producto_codigo, nro_comprobante_ingreso),
    FOREIGN KEY (producto_marca, producto_codigo)
    REFERENCES millon.Producto (marca, codigo),
    FOREIGN KEY (nro_comprobante_ingreso)
    REFERENCES millon.Ingreso (nro_comprobante),

    CHECK(cantidad > 0)
);

-- Distribuye - falta xd
CREATE TABLE millon.Distribuye (
    id_distribuidor integer,
    nro_comprobante_ingreso varchar(50),
    PRIMARY KEY (id_distribuidor, nro_comprobante_ingreso),
    FOREIGN KEY (id_distribuidor)
    REFERENCES millon.Distribuidor (id),
    FOREIGN KEY (nro_comprobante_ingreso)
    REFERENCES millon.Ingreso (nro_comprobante)
);

-- Tiene
CREATE TABLE millon.Tiene (
    id_kardex bigserial,
    id_distribuidor integer,
    FOREIGN KEY (id_kardex)
    REFERENCES millon.Kardex (id),
    FOREIGN KEY (id_distribuidor)
    REFERENCES millon.Distribuidor (id)
);

-- Sigue -- con procedure
CREATE TABLE millon.Sigue (
    id_kardex bigserial,
    producto_marca varchar(50),
    producto_codigo varchar(50),
    nro_comprobante_ingreso varchar(50),
    PRIMARY KEY (id_kardex, producto_marca, producto_codigo, nro_comprobante_ingreso),
    FOREIGN KEY (producto_marca, producto_codigo)
    REFERENCES millon.Producto (marca, codigo),
    FOREIGN KEY (nro_comprobante_ingreso)
    REFERENCES millon.Ingreso (nro_comprobante),
    FOREIGN KEY (id_kardex)
    REFERENCES millon.Kardex (id)
);

-- Stock -- con procedure
CREATE TABLE millon.Stock (
    id_tienda serial,
    producto_marca varchar(50),
    producto_codigo varchar(50),
    cantidad int not null default 0,
    PRIMARY KEY (id_tienda, producto_marca, producto_codigo),
    FOREIGN KEY (id_tienda)
    REFERENCES millon.Tienda (id),
    FOREIGN KEY (producto_marca, producto_codigo)
    REFERENCES millon.Producto (marca, codigo),
    
    CHECK(cantidad > 0)
);

-- Aparece -- con procedure
CREATE TABLE millon.Aparece (
    producto_marca varchar(50),
    producto_codigo varchar(50),
    nro_comprobante bigserial,
    cantidad int not null default 0,
    precio_unitario real,
    PRIMARY KEY (nro_comprobante, producto_marca, producto_codigo),
    FOREIGN KEY (producto_marca, producto_codigo)
    REFERENCES millon.Producto (marca, codigo),
    FOREIGN KEY (nro_comprobante)
    REFERENCES millon.Comprobante (numero),

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
-- Ingreso
-- select count(*) from millon.ingreso;
DO
$$
DECLARE 
	i record;
	num int;
begin
	select into num 0;
    FOR i IN SELECT marca from millon.producto 
    LOOP
		INSERT INTO millon.ingreso values(random_string(10),CURRENT_TIMESTAMP);
		select into num num+1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- Vehiculo
-- select count(*) from millon.vehiculo;

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
    FOR i IN SELECT nombre, ano, marca from millon.modelo  
    LOOP
        SELECT INTO mo_nombrex, mo_anox, mo_marcax nombre, ano, marca FROM millon.modelo ORDER BY random() LIMIT 1;
        INSERT INTO millon.vehiculo values(num, random_string(17), random_string(14), mo_nombrex, mo_marcax, mo_anox, '#ffffff');
        select into num num+1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- Compatible
-- select count(*) from millon.compatible;

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
    FOR i IN SELECT marca from millon.producto 
    LOOP
		SELECT INTO mo_nombrex, mo_anox, mo_marcax nombre, ano, marca FROM millon.modelo ORDER BY random() LIMIT 1;
		SELECT INTO pro_marca, pro_codigo marca, codigo FROM millon.producto ORDER BY random() LIMIT 1;
		INSERT INTO millon.compatible values(mo_nombrex, mo_marcax, mo_anox, pro_marca, pro_codigo);
		select into num num+1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- Provee
-- select count(*) from millon.provee;

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
    FOR i IN SELECT nro_comprobante from millon.ingreso  
    LOOP
		SELECT INTO pro_marca, pro_codigo marca, codigo FROM millon.producto ORDER BY random() LIMIT 1;
		SELECT INTO ing_num_comp nro_comprobante FROM millon.ingreso ORDER BY random() LIMIT 1;
		INSERT INTO millon.provee values(pro_marca, pro_codigo, ing_num_comp, random_between(1,1000), random_between(1,1000));
		select into num num+1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- Sigue
-- select count(*) from millon.sigue;

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
    FOR i IN SELECT marca from millon.producto 
    LOOP
		SELECT INTO pro_marca, pro_codigo marca, codigo FROM millon.producto ORDER BY random() LIMIT 1;
		SELECT INTO id_kar id FROM millon.kardex ORDER BY random() LIMIT 1;
		SELECT INTO ing_num_comp nro_comprobante FROM millon.ingreso ORDER BY random() LIMIT 1;
		INSERT INTO millon.sigue values(id_kar, pro_marca, pro_codigo, ing_num_comp);
		select into num num+1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- Stock
-- select count(*) from millon.stock;

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
    FOR i IN SELECT marca from millon.producto 
    LOOP
		SELECT INTO pro_marca, pro_codigo marca, codigo FROM millon.producto ORDER BY random() LIMIT 1;
		SELECT INTO id_tien id FROM millon.tienda ORDER BY random() LIMIT 1 ;
		INSERT INTO millon.stock values(id_tien, pro_marca, pro_codigo, random_between(1,1000));
		select into num num+1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- Aparece
-- select count(*) from millon.aparece;

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
    FOR i IN SELECT marca from millon.producto 
    LOOP
		SELECT INTO pro_marca, pro_codigo marca, codigo FROM millon.producto ORDER BY random() LIMIT 1;
		SELECT INTO nro_comp numero FROM millon.comprobante ORDER BY random() LIMIT 1;
		INSERT INTO millon.aparece values(pro_marca, pro_codigo, nro_comp, random_between(1,1000), random_between(1,10000));
		select into num num+1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------