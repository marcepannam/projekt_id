--LINIA LOTNICZA TANIE CZARTERY SAMOLOTÓW
--Linia lotnicza powstała w 2005 roku. Do tej pory oferowała jedynie loty czarterowe.
--Od nowego roku postanowiła wprowadzić również loty rejsowe. Zatrudniła ciebie do zaprojektowania bazy, w której będzie przechowywać dane o lotach.

drop table if exists kraje cascade;
drop table if exists miasta cascade;
drop table if exists lotniska cascade;
drop table if exists modele_samolotow cascade;
drop table if exists samoloty cascade;
drop table if exists bilety cascade;
drop table if exists bilety_laczone cascade;
drop table if exists nadanie_bagazu cascade;
drop table if exists miejsca_w_samolocie cascade;
drop table if exists linie_lotnicze cascade;
drop table if exists plany_lotow cascade;
drop view if exists loty cascade;

create table kraje(
  kod_iso varchar(2) primary key,
  nazwa varchar(40) not null,
  czy_w_schengen boolean not null  
);

create table miasta(
  id_miasta serial primary key,
  nazwa varchar(40) not null,
  kraj varchar(2) references kraje,
  strefa_czasowa numeric(4,2)
);

create table linie_lotnicze(
  id_linii_lotniczej serial primary key,
  nazwa varchar(50) not null,
  kod_iata varchar(2) not null,
  kod_icao varchar(3) not null,
  nazwa_kraju varchar(40)
);

create table lotniska(
  kod_iata varchar(3) primary key,
  nazwa varchar(80),
  nazwa_miasta varchar(40),
  kod_icao varchar(4),
  szerokosc double precision,
  dlugosc double precision
);


create table modele_samolotow(
  model serial primary key,
  kod_iata varchar(3) not null,
  nazwa varchar(50) not null,
--PASY STARTOWE - WYRZUCONE
--potrzebna_dl_pasa_startowego numeric(6, 2) not null,--w metrach 
  liczba_miejsc numeric (4) not null,
  ilosc_zalogi numeric (2) not null,
  zasieg integer not null
);


create table samoloty(
  id_samolotu serial primary key,
  nazwa varchar(30),
  --np Bodzio maly helikopter
  id_modelu integer not null references modele_samolotow(model),
  czy_sprawny boolean default true
);
create table bilety_laczone(
  id_biletu_laczonego serial primary key,
  kod_rezerewacji char(6) not null,
  --zawsze 6 znakowy, globalny
  --nie mamy modelu "pasazer", poniewaz nie zbieramy unikalnych identyfikatorow (np. PESELu, nr paszportu jest nieobowiazkowy)
  imie varchar(30) not null,
  nazwisko varchar(30) not null,
  mail varchar(100),
  --moze byc null, spr poprawnosc
  tytul varchar(25) not null,
  --Pan, Pani
  data_urodzenia date not null,
  --spr czy ma <13, jesli tak przydziel czlonka zalogi do opieki
  --do ceny biletu dodaj 300 zl
  nr_paszportu varchar(30),
  --tylko loty miedzynarodowe!(schengen nie licza sie jako miedzynarodowe)
  --dla biletow laczonych, w ktorychg wystepuje wiecej niz jeden lot spr
  --czy miedzy lotami jest przynajmniej 30 min odstepu
  oplaty_dodatkowe numeric(7, 2) default 0,
  check (oplaty_dodatkowe >= 0),
  check (ascii('A') <= ascii(substring(imie, 1, 1)) and ascii(substring(imie, 1, 1)) <= ascii('Z')),
  check (ascii('A') <= ascii(substring(nazwisko, 1, 1)) and ascii(substring(nazwisko, 1, 1)) <= ascii('Z')),
  check (tytul like 'Pan' OR tytul like 'Pani')
);


--PASY STARTOWE - WYRZUCONE
--create table pasy_startowe (
--  id_pasa serial primary key,
--  id_lotniska varchar(6) not null references lotniska(kod_IATA),
--  dl_pasa numeric(6, 2) not null --w metrach
--);

create table plany_lotow(
  id_samolotu integer references samoloty(id_samolotu) not null,

  linia_lotnicza integer references linie_lotnicze not null,
  kod varchar(6) primary key,
  skad varchar(6) not null references lotniska (kod_IATA),  --nr lotniska
  dokad varchar(6) not null references lotniska (kod_IATA) check (skad <> dokad),
  dzien_tygodnia int check(dzien_tygodnia >= 0 and dzien_tygodnia < 7),
  odlot int not null check(odlot >= 0 and odlot < 24 * 60), -- w minutach
  czas_lotu int not null check(czas_lotu > 0) -- w minutach
);

-- wszystkie loty od 2010 przez 10 tygodnii
create view loty as 
select
(kod || '_' || tydzien::text) as id_lotu,
kod as kod_lotu,
id_samolotu,
linia_lotnicza,
kod,
skad,
dokad,
current_date::timestamp + (dzien_tygodnia * '1 day'::interval) + (tydzien * '7 day'::interval) + (odlot * '1 minute'::interval) as odlot,
current_date::timestamp + (dzien_tygodnia * '1 day'::interval) + (tydzien * '7 day'::interval) + ((odlot+czas_lotu) * '1 minute'::interval) as przylot
from plany_lotow p 
cross join (select generate_series(0, 9) as tydzien) t;

-- (kod, data odlotu) muszą być unikalne. Nie stanowią primary key ze wzgłedów praktycznych.
--create unique index loty_index
--on loty (kod, skad::date);

create table bilety(
  kod_lotu varchar(6) references plany_lotow(kod),
  data_lotu date, -- check(extract(dow from data_lotu) = ),
  id_biletu_laczonego integer references bilety_laczone(id_biletu_laczonego),
  --nawetjak maszjeden bielt wpisac wartosc, wtedy id_biletu
  czy_karta_pokladowa_wystawiona boolean default false,
  --zrobic funkcje wstawiajaca karty pokladowe
  cena numeric(7, 2) not null,
  -- funkcja przeliczajaca pln na euro i dolary
  oplacony boolean default false,
  --jesli nieoplacona nie wystawiaj karty pokladowej
  miejsce varchar(5),  -- + check czy takie miejsce jest w samolocie i czy nie pokrywaja sie
  primary key (kod_lotu, data_lotu, miejsce)
);


--check (
    --(select count(*) from miejsca_w_samolocie ms 
    --join samoloty s on ms.id_modelu_samolotu = s.id_modelu_samolotu 
    --join loty l on l.id_samolotu = s.id_samolotu
    --where s.id_samolotu = id_lotu) = 1
  --),

create table miejsca_w_samolocie(
  id_modelu_samolotu integer not null references modele_samolotow(model),
  nr_miejsca varchar(3) not null,--np. A25
  klasa varchar(20) default 'ekonomiczna' check(klasa = 'ekonomiczna' or klasa = 'biznes' or klasa = 'premium'),
  primary key(id_modelu_samolotu, nr_miejsca)
);

create or replace function ustaw_miejsce() returns trigger as $$
begin 
  if new.miejsce is null then
    new.miejsce = 
      (select nr_miejsca from miejsca_w_samolocie m
      join samoloty s on m.id_modelu_samolotu = s.id_modelu
      join loty l on s.id_samolotu = l.id_samolotu
      where new.kod_lotu = l.kod_lotu
      and nr_miejsca not in 
      (select b.miejsce from bilety b
       where new.kod_lotu = b.kod_lotu and new.data_lotu = b.data_lotu)
      limit 1);
    if new.miejsce is null then
      raise exception 'brakuje miejsc';
    end if;
  end if;
  return new;
end
$$ language plpgsql;

create trigger ustaw_miejsce before insert on bilety for each row execute procedure ustaw_miejsce();

--create table nadanie_bagazu(
--  waga numeric(3, 2) check (waga <= 32), -- >=18 kg, >=32kg, 32kg +
--  id_lotu integer not null,
--  miejsce varchar(5) not null,
--  foreign key (id_lotu, miejsce) references bilety(id_lotu, miejsce)
--);

--zmiany w tabelach zawiera plik alter.sql

--funkcja wypisz kortke podróż bagażu np KRK->WAW->BAR->VIE

create or replace language plpython3u;
