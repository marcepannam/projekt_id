#Plane ticket reservation system

Contains information from OpenFlights Database, which is made available [here](https://openflights.org/data.html) under the Open Database License (ODbL).

Set up:

sudo apt-get install postgresql-plpython3
sudo apt-get install nodejs 

Set up the DB:

psql < create.sql

Start application:

cd client && node index.js

Caution:

Application assumes that it connects to the database 'testuser' owned by user 'testuser' with password 'test'
Change lines 6-9 in file index.js in order to reflect your local settings.
