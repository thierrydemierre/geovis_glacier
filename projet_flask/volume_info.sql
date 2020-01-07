CREATE EXTENSION IF NOT EXISTS postgis;
DROP TABLE IF EXISTS vol_change CASCADE;

CREATE TABLE vol_change(
  vol_change_id varchar,
  st_date_vol_change varchar,
  end_date_vol_change varchar,
  gl_area_ini varchar,
  gl_area_end varchar,
  volume_change varchar,
  mean_thickness_change varchar
);

DROP TABLE IF EXISTS volume_info;

CREATE TABLE volume_info(
  glacier_name varchar,
  glacier_id varchar,
  start_date_observation_volume varchar,
  end_date_observation_volume varchar,
  glacier_area_st_date_volume varchar,
  glacier_area_end_date_volume varchar,
  volume_change varchar,
  mean_thickness_change varchar
);

COPY volume_info
FROM 'D:/geovis2/volume_info.csv'
DELIMITER ';' CSV HEADER ENCODING 'UTF8' QUOTE E'\b' ESCAPE '''';

INSERT INTO vol_change
SELECT glacier_id AS vol_change_id,
start_date_observation_volume AS st_date_vol_change,
end_date_observation_volume AS end_date_vol_change,
glacier_area_st_date_volume AS gl_area_ini,
glacier_area_end_date_volume AS gl_area_end,
volume_change AS volume_change,
mean_thickness_change AS mean_thickness_change
FROM volume_info
GROUP BY vol_change_id, st_date_vol_change, end_date_vol_change, gl_area_ini, gl_area_end, volume_change, mean_thickness_change
ORDER BY vol_change_id, st_date_vol_change;
