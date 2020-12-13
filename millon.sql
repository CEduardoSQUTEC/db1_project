CREATE DATABASE Casboni;

--------------------------------------------
-- Entidades
--------------------------------------------
-- 1k, 10k 100k y 10^6
create schema millon;

-- Cliente -- con procedure
CREATE TABLE millon.Cliente (
    id bigserial,
    PRIMARY KEY (id)
);

-- Persona_Natural -- con procedure
CREATE TABLE millon.Persona_Natural (
    id bigserial,
    dni serial,
    nombre varchar(50) not null,
    apellido varchar(50) not null,
    ruc_natural bigserial not null,
    PRIMARY KEY (id),
    FOREIGN KEY (id)
    REFERENCES millon.Cliente (id)
);

-- Persona_Juridica -- con procedure
CREATE TABLE millon.Persona_Juridica (
    id bigserial,
    nombre varchar(50) not null,
    ruc_empresarial bigserial not null,
    PRIMARY KEY (id),
    FOREIGN KEY (id)
    REFERENCES millon.Cliente (id)
);

-- Tienda (3)
CREATE TABLE millon.Tienda (
    id serial,
    nombre varchar(255),
    PRIMARY KEY (id)
);

-- Comprobante -- con procedure
CREATE TABLE millon.Comprobante (
    numero varchar(10),
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

-- Ingreso -- con procedure
CREATE TABLE millon.Ingreso (
    nro_comprobante varchar(10),
    fecha timestamp,
    PRIMARY KEY (nro_comprobante),
    FOREIGN KEY (nro_comprobante)
    REFERENCES millon.Comprobante (numero)
);

-- Kardex -- con procedure (no queería que comience con 1 ps)
CREATE TABLE millon.Kardex (
    id bigserial,
    id_tienda serial,
    nro_comprobante varchar(10),
    tipo_operacion serial,
    PRIMARY KEY (id),
    FOREIGN KEY (id_tienda)
    REFERENCES millon.Tienda (id),
    FOREIGN KEY (nro_comprobante)
    REFERENCES millon.Comprobante (numero)
);

-- Modelo -- con procedure
CREATE TABLE millon.Modelo (
    nombre varchar(50),
    ano serial,
    marca varchar(50),
    PRIMARY KEY (nombre, ano, marca)
);

-- Vehiculo -- con procedure
CREATE TABLE millon.Vehiculo (
    placa varchar(8),
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

-- Distribuidor (250)
CREATE TABLE millon.Distribuidor (
    nombre varchar(255),
    id integer,
    PRIMARY KEY (id)
);

-- Categoria (50)
CREATE TABLE millon.Categoria (
    id serial,
    id_padre serial,
    nombre varchar(25),
    PRIMARY KEY (id)
);

-- Producto -- con procedure
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

-- Posee -- con procedure
CREATE TABLE millon.Posee (
    id_cliente bigserial,
    placa_vehiculo varchar(8),
    PRIMARY KEY (id_cliente),
    FOREIGN KEY (placa_vehiculo)
    REFERENCES millon.Vehiculo (placa)
    FOREIGN KEY (id_cliente)
    REFERENCES millon.Cliente (id)
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
    REFERENCES millon.Comprobante (numero),

    CHECK(cantidad > 0)
);

-- Distribuye -- con procedure
CREATE TABLE millon.Distribuye (
    id_distribuidor integer,
    nro_comprobante_ingreso varchar(10),
    PRIMARY KEY (id_distribuidor, nro_comprobante_ingreso),
    FOREIGN KEY (id_distribuidor)
    REFERENCES millon.Distribuidor (id),
    FOREIGN KEY (nro_comprobante_ingreso)
    REFERENCES millon.Comprobante (numero)
);

-- Tiene -- con procedure
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
    nro_comprobante varchar(10),
    PRIMARY KEY (id_kardex, producto_marca, producto_codigo, nro_comprobante),
    FOREIGN KEY (producto_marca, producto_codigo)
    REFERENCES millon.Producto (marca, codigo),
    FOREIGN KEY (nro_comprobante)
    REFERENCES millon.Comprobante (numero),
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
-- Cliente
-- select count(*) from millon.cliente;
DO
$$
DECLARE 
	i int;
begin
	for i in 1..1000000
    LOOP
		INSERT INTO millon.cliente values(i);
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- Persona_Juridica
-- select count(*) from millon.persona_juridica;
DO
$$
DECLARE 
	i int;
begin
	for i in 1..1000000
    LOOP
		INSERT INTO millon.persona_juridica values(i, random_string(50), random_between(10,10));
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- Persona_Natural
-- select count(*) from millon.persona_natural;
DO
$$
DECLARE 
	i int;
begin
	for i in 1..1000000
    LOOP
		INSERT INTO millon.persona_natural values(i, random_between(8,9), random_string(50), random_string(50), random_between(10,10));
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Comprobante
-- select count(*) from millon.comprobante;
DO
$$
DECLARE 
	i int;
	id_tien int;
begin
	for i in 1..1000000
    loop
    	SELECT INTO id_tien id FROM millon.tienda ORDER BY random() LIMIT 1;
    	INSERT INTO millon.comprobante values(i, id_tien, i, random_between(1, 10000), 0.18, random_between(1, 1000), CURRENT_TIMESTAMP, random_between(100, 10000));
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Ingreso
-- select count(*) from millon.ingreso;
DO
$$
DECLARE 
	i int;
begin
	for i in 1..1000000
    LOOP
		INSERT INTO millon.ingreso values(i, CURRENT_TIMESTAMP);
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- Kardex
DO
$$
DECLARE 
    i int;
   	id_tien int;
    nro_comp_ing varchar(10);
begin
    for i in 1..1000000
    LOOP
        SELECT INTO id_tien id FROM millon.tienda ORDER BY random() LIMIT 1;
        INSERT INTO millon.kardex values(i+3/2, id_tien, i+2/2, floor(random()*4+1));
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- Modelo
DO
$$
DECLARE 
    i int;
begin
    for i in 1..1000000
    LOOP
        INSERT INTO millon.modelo values(concat('model', i), random_between(1960, 2020), concat('marca', i));
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- Vehiculo
-- select count(*) from millon.vehiculo;
DO
$$
DECLARE 
    i int;
    mo_anox int;
    num int;
begin
	  select into num 10;
    for i in 1..1000000
    LOOP
        select into mo_anox ano FROM millon.modelo where nombre=concat('model', i);
        INSERT INTO millon.vehiculo values(num, random_string(17), random_string(14), concat('model', i),  concat('marca', i), mo_anox, concat('#', random_string(7)));
        select into num num+1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- Categoría
-- select count(*) from millon.categoria;
-- select * from millon.categoria;
DO
$$
DECLARE 
    i int;
    id_ int;
    id_padre int;
begin
    for i in 1..50
    LOOP
        INSERT INTO millon.categoria values(i, floor(random()*50+1), random_string(25));
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- Producto
-- select count(*) from millon.producto 
-- select * from millon.producto 
DO
$$
DECLARE 
	i int;
	id_cat int;
begin
    for i in 1..1000000 
    LOOP
		SELECT INTO id_cat id FROM millon.Categoria ORDER BY random() LIMIT 1;
		INSERT INTO millon.producto values(i+1, i+2, id_cat, random_string(50), random_string(50), random_string(50), random_between(1, 20));
    END LOOP;
END;
$$ LANGUAGE plpgsql;



-- Compatible
-- select count(*) from millon.compatible;
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
    for i in 1..1000000 
    LOOP
		SELECT INTO mo_nombrex, mo_anox, mo_marcax modelo_nombre, modelo_ano, modelo_marca FROM millon.tablaX ORDER BY random() LIMIT 1;
		INSERT INTO millon.compatible values(mo_nombrex, mo_marcax, mo_anox, i, i);
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- Posee
-- select count(*) from millon.posee;
DO
$$
DECLARE 
	i int;
	num int;
begin
    select into num 10;
	for i in 1..1000000 
    LOOP
		INSERT INTO millon.posee values(i, num);
		select into num num+1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- Provee
-- select count(*) from millon.provee; AQUI
DO
$$
DECLARE 
	i int;
begin
    for i in 1..1000000 
    LOOP
		INSERT INTO millon.provee values(i+1, i+2, i+2/2, random_between(1, 1000), random_between(1, 1000));
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- Distribuye
-- select count(*) from millon.distribuye;
DO
$$
DECLARE 
	i int;
	id_dist int;
begin
    for i in 1..1000000 
    LOOP
		SELECT INTO id_dist id FROM millon.distribuidor ORDER BY random() LIMIT 1;
		INSERT INTO millon.distribuye values(id_dist, i+2/2);
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- Tiene
-- select count(*) from millon.tiene;
DO
$$
DECLARE 
	i int;
	id_dist int;
begin
    for i in 1..1000000 
    LOOP
		SELECT INTO id_dist id FROM millon.distribuidor ORDER BY random() LIMIT 1;
		INSERT INTO millon.tiene values(i+3/2, id_dist);
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- Sigue
-- select count(*) from millon.sigue;
DO
$$
DECLARE 
	i int;
begin
    for i in 1..1000000 
    LOOP
		INSERT INTO millon.sigue values(i+3/2, i+1, i+2, i+2/2);
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- Stock
-- select count(*) from millon.stock;
DO
$$
DECLARE 
	i int;
	id_tien int;
begin
    for i in 1..1000000 
    LOOP
		SELECT INTO id_tien id FROM millon.tienda ORDER BY random() LIMIT 1 ;
		INSERT INTO millon.stock values(id_tien, i+1, i+2, random_between(1,10000));
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Aparece
-- select count(*) from millon.aparece;
DO
$$
DECLARE 
	i int;
	pro_marca varchar(50);
	pro_codigo varchar(50);
	nro_comp int;
begin
    for i in 1..1000000
    LOOP
		SELECT INTO pro_marca, pro_codigo marca, codigo FROM millon.producto ORDER BY random() LIMIT 1;
		SELECT INTO nro_comp numero FROM millon.comprobante ORDER BY random() LIMIT 1;
		INSERT INTO millon.aparece values(pro_marca, pro_codigo, nro_comp, random_between(1,1000), random_between(1,10000));
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
