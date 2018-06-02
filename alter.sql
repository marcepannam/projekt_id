alter table linie_lotnicze add column kraj varchar(2);
update linie_lotnicze set kraj = (select kod_iso from kraje where nazwa_kraju=nazwa);
delete from linie_lotnicze where kraj is null;
alter table linie_lotnicze add foreign key (kraj) references kraje;
alter table linie_lotnicze drop column nazwa_kraju;
