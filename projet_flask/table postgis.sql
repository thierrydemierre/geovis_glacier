CREATE EXTENSION IF NOT EXISTS postgis;
DROP TABLE IF EXISTS date CASCADE;
DROP TABLE IF EXISTS mass_balance CASCADE;


--Création des tables qui contiendront les données


CREATE TABLE date (
  date_id varchar,
  st_date varchar,
  end_date varchar
);

CREATE TABLE mass_balance(
  mass_balance_id varchar,
  winter_mb varchar,
  summer_mb varchar,
  annual_mb varchar,
  ela varchar,
  aar varchar,
  st_date varchar,
  end_date varchar
);


-- Création de la table qui contiendra le fichier csv
DROP TABLE IF EXISTS mass_balance_info;
DROP TABLE IF EXISTS mass_balance_volume_info;

CREATE TABLE mass_balance_info (
glacier_name varchar,
glacier_id varchar,
start_date_observation varchar,
end_date_observation varchar,
winter_mass_balance varchar,
summer_mass_balance varchar,
annual_mass_balance varchar,
equilibrium_line_altitude varchar,
accumulation_area_ratio varchar,
glacier_area_date varchar,
coordx varchar,
coordy varchar,
glacier_area varchar,
survey_year_glacier_area varchar
);


COPY mass_balance_info
FROM 'D:/geovis2/mass_balance_info.csv'
DELIMITER ';' CSV HEADER ENCODING 'UTF8' QUOTE E'\b' ESCAPE '''';


-- Commencer d'insérer les données dans les tables créées


INSERT INTO date
SELECT glacier_id AS date_id,
start_date_observation AS st_date,
end_date_observation AS end_date
FROM mass_balance_info
GROUP BY date_id, st_date, end_date
ORDER BY date_id, st_date;

INSERT INTO mass_balance
SELECT glacier_id AS mass_balance_id,
winter_mass_balance AS winter_mb,
summer_mass_balance AS summer_mb,
annual_mass_balance AS annual_mb,
equilibrium_line_altitude AS ela,
accumulation_area_ratio AS aar,
start_date_observation AS st_date,
end_date_observation AS end_date
FROM mass_balance_info
GROUP BY mass_balance_id, winter_mb, summer_mb, annual_mb, ela, aar, st_date, end_date
ORDER BY mass_balance_id, st_date;
