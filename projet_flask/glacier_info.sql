CREATE EXTENSION IF NOT EXISTS postgis;
DROP TABLE IF EXISTS coord CASCADE;
DROP TABLE IF EXISTS gl_area CASCADE;
DROP TABLE IF EXISTS glacier_info CASCADE;
DROP TABLE IF EXISTS gl_name CASCADE;

CREATE TABLE gl_name (
  id varchar NOT NULL PRIMARY KEY,
  name varchar
);

CREATE TABLE gl_area(
  gl_area_id varchar,
  gl_area_2018 varchar,
  FOREIGN KEY (gl_area_id) REFERENCES gl_name(id)
);

CREATE TABLE coord (
  coord_id varchar,
  coord_x varchar,
  coord_y varchar,
  FOREIGN KEY (coord_id) REFERENCES gl_name(id)
);

CREATE TABLE glacier_info(
  glacier_name varchar,
  glacier_id varchar,
  coordx varchar,
  coordy varchar,
  glacier_area varchar,
  survey_year_glacier_area varchar,
  coordx_f varchar,
  coordy_f varchar
);

COPY glacier_info
FROM 'D:/geovis2/glacier_info.csv'
DELIMITER ';' CSV HEADER ENCODING 'UTF8' QUOTE E'\b' ESCAPE '''';

INSERT INTO gl_name
SELECT glacier_id AS id,
glacier_name AS name
FROM glacier_info
GROUP BY id, name;

INSERT INTO coord
SELECT glacier_id AS coord_id,
coordx AS coord_x,
coordy AS coord_y
FROM glacier_info
GROUP BY coord_id, coord_x, coord_y
ORDER BY coord_id;

INSERT INTO gl_area
SELECT glacier_id AS gl_area_id,
glacier_area AS gl_area_2018
FROM glacier_info
GROUP BY gl_area_id, gl_area_2018
ORDER BY gl_area_id;

--ajouter les coordonnées sur le fichier de base glacier_info
ALTER TABLE glacier_info
ADD COLUMN geom geometry(POINT, 21781);

UPDATE glacier_info
SET geom = ST_Transform(
            ST_SetSRID(
              ST_MakePoint(
                (coordx)::numeric,
                (coordy)::numeric
              ),
              2056
            ),
            21781
          );

--ajouter les coordonnées au fichier coord ou au fichier dont on a besoin (changer si besoin)
ALTER TABLE glacier_info
DROP COLUMN geom;
ALTER TABLE glacier_info
ADD COLUMN geom geometry(POINT, 4326);

        UPDATE coord
          SET geom = ST_Transform(
                      ST_SetSRID(
                        ST_MakePoint(
                          (coord_x)::numeric,
                          (coord_y)::numeric
                        ),
                        2056
                      ),
                      4326
                    );

-- insertion dans gl_area
ALTER TABLE gl_area
ADD COLUMN geom geometry(POINT, 21781);
SELECT p.gl_area_id, p.geom FROM gl_area AS p INNER JOIN coord AS f ON p.gl_area_id = f.coord_id
INSERT INTO gl_area (geom) SELECT geom FROM coord

--changer les dates de varchar en dates
