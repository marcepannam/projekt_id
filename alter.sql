alter table linie_lotnicze add column kraj varchar(2);
update linie_lotnicze set kraj = (select kod_iso from kraje where nazwa_kraju=nazwa);
delete from linie_lotnicze where kraj is null;
alter table linie_lotnicze add foreign key (kraj) references kraje;
alter table linie_lotnicze drop column nazwa_kraju;
alter table lotniska add column miasto integer;
update lotniska set miasto = (select id_miasta from miasta where nazwa_miasta=nazwa);
alter table lotniska drop column nazwa_miasta;
alter table lotniska add foreign key (miasto) references miasta;
alter table modele_samolotow drop column liczba_miejsc;

