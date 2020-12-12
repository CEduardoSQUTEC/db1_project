CREATE DATABASE Casboni;

--------------------------------------------
-- Entidades
--------------------------------------------
-- 1k, 10k 100k y 10^6
create schema mil;

-- Truncate
-- truncate ingreso cascade;
-- truncate compatible cascade;
-- truncate provee cascade;
-- 
-- alters
-- ALTER TABLE tienda 
-- DROP COLUMN id_kardex;
-- 
-- ALTER TABLE vehiculo 
-- alter column color type varchar(8);
-- 
-- ALTER TABLE ingreso 
-- alter column nro_comprobante type varchar(10);

-- Cliente
CREATE TABLE mil.Cliente (
    id bigserial,
    PRIMARY KEY (id)
);

-- Persona_Natural
CREATE TABLE mil.Persona_Natural (
    id bigserial,
    dni serial,
    nombre varchar(50) not null,
    apellido varchar(50) not null,
    ruc_natural bigserial not null,
    PRIMARY KEY (id)
);

-- Persona_Juridica
CREATE TABLE mil.Persona_Juridica (
    id bigserial,
    nombre varchar(50) not null,
    ruc_empresarial bigserial not null,
    PRIMARY KEY (id)
);

-- Ingreso -- con procedure
CREATE TABLE mil.Ingreso (
    nro_comprobante varchar(10),
    fecha timestamp,
    PRIMARY KEY (nro_comprobante)
);

-- Tienda
CREATE TABLE mil.Tienda (
    id serial,
    nombre varchar(255),
    PRIMARY KEY (id)
);

-- Kardex
CREATE TABLE mil.Kardex (
    id bigserial,
    id_tienda serial,
    nro_comprobante_ingreso varchar(10),
    tipo_operacion serial,
    PRIMARY KEY (id),
    FOREIGN KEY (id_tienda)
    REFERENCES mil.Tienda (id),
    FOREIGN KEY (nro_comprobante_ingreso)
    REFERENCES mil.Ingreso (nro_comprobante)
);

-- Comprobante
CREATE TABLE mil.Comprobante (
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
    REFERENCES mil.Tienda (id),
    FOREIGN KEY (id_cliente)
    REFERENCES mil.Cliente (id),

    CHECK(cantidad > 0)
);

-- Modelo
CREATE TABLE mil.Modelo (
    nombre varchar(50),
    ano serial,
    marca varchar(50),
    PRIMARY KEY (nombre, ano, marca)
);

-- Vehiculo -- con procedure
CREATE TABLE mil.Vehiculo (
    placa varchar(6),
    nVim varchar(17),
    nMotor varchar(14),
    modelo_nombre varchar(50),
    modelo_marca varchar(50),
    modelo_ano serial,
    color varchar(8),
    PRIMARY KEY (placa),
    FOREIGN KEY (modelo_nombre, modelo_ano, modelo_marca)
    REFERENCES mil.Modelo (nombre, ano, marca)
);

-- Distribuidor
CREATE TABLE mil.Distribuidor (
    nombre varchar(255),
    id integer,
    PRIMARY KEY (id)
);

-- Categoria
CREATE TABLE mil.Categoria (
    id serial,
    id_padre serial,
    nombre varchar(25),
    PRIMARY KEY (id)
);

-- Producto
CREATE TABLE mil.Producto (
    marca varchar(50),
    codigo varchar(50),
    id_categoria serial not null,
    imagen varchar(50),
    documentacion varchar(50),
    descripcion varchar(50),
    u_medida varchar(20),
    PRIMARY KEY (marca, codigo),
    FOREIGN KEY (id_categoria)
    REFERENCES mil.Categoria (id)
);

--------------------------------------------
-- Relaciones
--------------------------------------------
-- Compatible -- con procedure
CREATE TABLE mil.Compatible (
    modelo_nombre varchar(50),
    modelo_marca varchar(50),
    modelo_ano serial,
    producto_marca varchar(50),
    producto_codigo varchar(50),
    PRIMARY KEY (modelo_nombre, modelo_ano, modelo_marca, producto_marca, producto_codigo),
    FOREIGN KEY (modelo_nombre, modelo_ano, modelo_marca)
    REFERENCES mil.Modelo (nombre, ano, marca),
    FOREIGN KEY (producto_marca, producto_codigo)
    REFERENCES mil.Producto (marca, codigo)
);

-- Posee
CREATE TABLE mil.Posee (
    id_cliente bigserial,
    placa_vehiculo varchar(8),
    PRIMARY KEY (id_cliente),
    FOREIGN KEY (placa_vehiculo)
    REFERENCES mil.Vehiculo (placa)
);

-- Provee -- con procedure
CREATE TABLE mil.Provee (
    producto_marca varchar(50),
    producto_codigo varchar(50),
    nro_comprobante_ingreso varchar(10),
    cantidad int not null default 0,
    precio_unitario real,
    PRIMARY KEY (producto_marca, producto_codigo, nro_comprobante_ingreso),
    FOREIGN KEY (producto_marca, producto_codigo)
    REFERENCES mil.Producto (marca, codigo),
    FOREIGN KEY (nro_comprobante_ingreso)
    REFERENCES mil.Ingreso (nro_comprobante),

    CHECK(cantidad > 0)
);

-- Distribuye 
CREATE TABLE mil.Distribuye (
    id_distribuidor integer,
    nro_comprobante_ingreso varchar(10),
    PRIMARY KEY (id_distribuidor, nro_comprobante_ingreso),
    FOREIGN KEY (id_distribuidor)
    REFERENCES mil.Distribuidor (id),
    FOREIGN KEY (nro_comprobante_ingreso)
    REFERENCES mil.Ingreso (nro_comprobante)
);

-- Tiene
CREATE TABLE mil.Tiene (
    id_kardex bigserial,
    id_distribuidor integer,
    FOREIGN KEY (id_kardex)
    REFERENCES mil.Kardex (id),
    FOREIGN KEY (id_distribuidor)
    REFERENCES mil.Distribuidor (id)
);

-- Sigue -- con procedure
CREATE TABLE mil.Sigue (
    id_kardex bigserial,
    producto_marca varchar(50),
    producto_codigo varchar(50),
    nro_comprobante_ingreso varchar(10),
    PRIMARY KEY (id_kardex, producto_marca, producto_codigo, nro_comprobante_ingreso),
    FOREIGN KEY (producto_marca, producto_codigo)
    REFERENCES mil.Producto (marca, codigo),
    FOREIGN KEY (nro_comprobante_ingreso)
    REFERENCES mil.Ingreso (nro_comprobante),
    FOREIGN KEY (id_kardex)
    REFERENCES mil.Kardex (id)
);

-- Stock -- con procedure
CREATE TABLE mil.Stock (
    id_tienda serial,
    producto_marca varchar(50),
    producto_codigo varchar(50),
    cantidad int not null default 0,
    PRIMARY KEY (id_tienda, producto_marca, producto_codigo),
    FOREIGN KEY (id_tienda)
    REFERENCES mil.Tienda (id),
    FOREIGN KEY (producto_marca, producto_codigo)
    REFERENCES mil.Producto (marca, codigo),
    
    CHECK(cantidad > 0)
);

-- Aparece -- con procedure
CREATE TABLE mil.Aparece (
    producto_marca varchar(50),
    producto_codigo varchar(50),
    nro_comprobante bigserial,
    cantidad int not null default 0,
    precio_unitario real,
    PRIMARY KEY (nro_comprobante, producto_marca, producto_codigo),
    FOREIGN KEY (producto_marca, producto_codigo)
    REFERENCES mil.Producto (marca, codigo),
    FOREIGN KEY (nro_comprobante)
    REFERENCES mil.Comprobante (numero),

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
-- select count(*) from mil.ingreso;
DO
$$
DECLARE 
	i int;
begin
	for i in 1..1000
    LOOP
		INSERT INTO mil.ingreso values(random_string(10),CURRENT_TIMESTAMP);
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- Vehiculo
-- select count(*) from mil.vehiculo;

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
    FOR i IN SELECT nombre, ano, marca from mil.modelo  
    LOOP
        SELECT INTO mo_nombrex, mo_anox, mo_marcax nombre, ano, marca FROM mil.modelo ORDER BY random() LIMIT 1;
        INSERT INTO mil.vehiculo values(num, random_string(17), random_string(14), mo_nombrex, mo_marcax, mo_anox, '#ffffff');
        select into num num+1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- Compatible
-- select count(*) from mil.compatible;

DO
$$
DECLARE 
	i int;
	mo_nombrex varchar(50);
	mo_marcax varchar(50);
	mo_anox int;
	pro_marca varchar(50);
	pro_codigo varchar(50);
begin
    for i in 1..1000 
    LOOP
		SELECT INTO mo_nombrex, mo_anox, mo_marcax nombre, ano, marca FROM mil.modelo ORDER BY random() LIMIT 1;
		SELECT INTO pro_marca, pro_codigo marca, codigo FROM mil.producto ORDER BY random() LIMIT 1;
		INSERT INTO mil.compatible values(mo_nombrex, mo_marcax, mo_anox, pro_marca, pro_codigo);
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- Provee
-- select count(*) from mil.provee;

DO
$$
DECLARE 
	i int;
	pro_marca varchar(50);
	pro_codigo varchar(50);
	ing_num_comp varchar(10);
	mo_anox int;
begin
    for i in 1..1000 
    LOOP
		SELECT INTO pro_marca, pro_codigo marca, codigo FROM mil.producto ORDER BY random() LIMIT 1;
		SELECT INTO ing_num_comp nro_comprobante FROM mil.ingreso ORDER BY random() LIMIT 1;
		INSERT INTO mil.provee values(pro_marca, pro_codigo, ing_num_comp, random_between(1,1000), random_between(1,1000));
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- Sigue
-- select count(*) from mil.sigue;

DO
$$
DECLARE 
	i int;
	id_kar int;
	pro_marca varchar(50);
	pro_codigo varchar(50);
	ing_num_comp varchar(10);
begin
    for i in 1..1000 
    LOOP
		SELECT INTO pro_marca, pro_codigo marca, codigo FROM mil.producto ORDER BY random() LIMIT 1;
		SELECT INTO id_kar id FROM mil.kardex ORDER BY random() LIMIT 1;
		SELECT INTO ing_num_comp nro_comprobante FROM mil.ingreso ORDER BY random() LIMIT 1;
		INSERT INTO mil.sigue values(id_kar, pro_marca, pro_codigo, ing_num_comp);
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- Stock
-- select count(*) from mil.stock;

DO
$$
DECLARE 
	i int;
	id_tien int;
	pro_marca varchar(50);
	pro_codigo varchar(50);
begin
    for i in 1..1000 
    LOOP
		SELECT INTO pro_marca, pro_codigo marca, codigo FROM mil.producto ORDER BY random() LIMIT 1;
		SELECT INTO id_tien id FROM mil.tienda ORDER BY random() LIMIT 1 ;
		INSERT INTO mil.stock values(id_tien, pro_marca, pro_codigo, random_between(1,1000));
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- Aparece
-- select count(*) from mil.aparece;

DO
$$
DECLARE 
	i int;
	pro_marca varchar(50);
	pro_codigo varchar(50);
	nro_comp int;
begin
    for i in 1..1000
    LOOP
		SELECT INTO pro_marca, pro_codigo marca, codigo FROM mil.producto ORDER BY random() LIMIT 1;
		SELECT INTO nro_comp numero FROM mil.comprobante ORDER BY random() LIMIT 1;
		INSERT INTO mil.aparece values(pro_marca, pro_codigo, nro_comp, random_between(1,1000), random_between(1,10000));
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------