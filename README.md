# projekt_id

![er diagram](er.png)

Set up:

sudo apt-get install postgresql-plpython3

Contains information from OpenFlights Airports Database, which is made available [here](https://openflights.org/data.html) under the Open Database License (ODbL).

Set up the DB:

cat schemat.sql znajdz_loty.sql create.sql create_bilety.sql | psql