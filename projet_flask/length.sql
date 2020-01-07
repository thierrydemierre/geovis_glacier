CREATE EXTENSION IF NOT EXISTS postgis;
DROP TABLE IF EXISTS len_change CASCADE;

CREATE TABLE len_change(
  len_change_id varchar,
  st_date_len_change varchar,
  end_date_len_change varchar,
  length_change varchar
);

DROP TABLE IF EXISTS length_info;

CREATE TABLE length_info(
  glacier_name varchar,
  glacier_id varchar,
  start_date_observation_length varchar,
  end_date_observation_length varchar,
  length_change varchar
);

COPY length_info
FROM 'D:/geovis2/length_info.csv'
DELIMITER ';' CSV HEADER ENCODING 'UTF8' QUOTE E'\b' ESCAPE '''';

INSERT INTO len_change
SELECT glacier_id AS len_change_id,
start_date_observation_length AS st_date_len_change,
end_date_observation_length AS end_date_len_change,
length_change AS length_change
FROM length_info
GROUP BY len_change_id, st_date_len_change, end_date_len_change, length_change
ORDER BY len_change_id, st_date_len_change;
