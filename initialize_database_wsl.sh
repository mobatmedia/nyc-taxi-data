#!/bin/bash

createdb.exe nyc-taxi-data

psql.exe -f setup_files/create_nyc_taxi_schema.sql nyc-taxi-data

shp2pgsql.exe -s 2263:4326 -I shapefiles/taxi_zones/taxi_zones.shp | psql.exe -d nyc-taxi-data
psql.exe -c "CREATE INDEX ON taxi_zones (locationid);" nyc-taxi-data
psql.exe -c "VACUUM ANALYZE taxi_zones;" nyc-taxi-data

shp2pgsql -s 2263:4326 -I shapefiles/nyct2010_15b/nyct2010.shp | psql.exe -d nyc-taxi-data
psql.exe -f setup_files/add_newark_airport.sql nyc-taxi-data
psql.exe -c "CREATE INDEX ON nyct2010 (ntacode);" nyc-taxi-data
psql.exe -c "VACUUM ANALYZE nyct2010;" nyc-taxi-data

psql.exe -f setup_files/add_tract_to_zone_mapping.sql nyc-taxi-data

cat data/fhv_bases.csv | psql.exe -c "COPY fhv_bases FROM stdin WITH CSV HEADER;" nyc-taxi-data
weather_schema="station_id, station_name, date, average_wind_speed, precipitation, snowfall, snow_depth, max_temperature, min_temperature"
cat data/central_park_weather.csv | psql.exe -c "COPY central_park_weather_observations (${weather_schema}) FROM stdin WITH CSV HEADER;" nyc-taxi-data
psql.exe -c "UPDATE central_park_weather_observations SET average_wind_speed = NULL WHERE average_wind_speed = -9999;" nyc-taxi-data
