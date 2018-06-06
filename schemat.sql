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
drop table if exists loty cascade;
drop table if exists nadanie_bagazu cascade;
drop table if exists miejsca_w_samolocie cascade;
drop table if exists linie_lotnicze cascade;
--PASY STARTOWE - WYRZUCONE
--drop table if exists pasy_startowe cascade;
--drop table if exists rezerwacje_pasow_startowych cascade;

create table kraje(
  kod_iso varchar(2) primary key,
  nazwa varchar(40) not null,
  czy_w_schengen boolean not null  
);

create table miasta(
  id_miasta serial primary key,
  nazwa varchar(40) not null,
  kraj varchar(2) references kraje
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
  oplaty_dodatkowe numeric(7, 2) default 0
);


--PASY STARTOWE - WYRZUCONE
--create table pasy_startowe (
--  id_pasa serial primary key,
--  id_lotniska varchar(6) not null references lotniska(kod_IATA),
--  dl_pasa numeric(6, 2) not null --w metrach
--);

create table loty(
  id_lotu serial primary key,
  id_samolotu integer references samoloty(id_samolotu),
  linia_lotnicza integer references linie_lotnicze not null,
  kod varchar(6) not null,
  skad varchar(6) not null references lotniska (kod_IATA),  --nr lotniska
  dokad varchar(6) not null references lotniska (kod_IATA) check (skad <> dokad),
  odlot timestamp not null,--w utc
  przylot timestamp not null--w utc
  --PASY STARTOWE - WYRZUCONE
  --nr_pasa_startowego_przylot serial references pasy_startowe(id_pasa) --kodlotniska+4cyfrowy_nr

  --check sprawdzajaca czy loty na pasach startowych sie nie pokrywaja
  --check spr czy dlugosc pasa startowego jest opowiednia
  --check sprawdzajaca czy samolot sie nie teleportuje
);

create table bilety(
  id_biletu serial primary key,
  id_lotu integer references loty(id_lotu),
  id_biletu_laczonego integer references bilety_laczone(id_biletu_laczonego),
  --nawetjak maszjeden bielt wpisac wartosc, wtedy id_biletu
  klasa varchar(20) default 'ekonomiczna', 
  --jeszcze biznes, premium (check)
  czy_karta_pokladowa_wystawiona boolean default false, 
  --zrobic funkcje wstawiajaca karty pokladowe
  cena numeric(7, 2) not null, 
  -- funkcja przeliczajaca  pln na euro i dolary
  oplacony boolean default false,
  --jesli nieoplacona nie wystawiaj karty pokladowej
  miejsce varchar(5) -- + check czy takie miejsce jest w samolocie i czy nie pokrywaja sie
);

--PASY STARTOWE - WYRZUCONE
--create table rezerwacje_pasow_startowych(
--  id_pasa integer not null references pasy_startowe(id_pasa),   
--  od timestamp not null,
--  "do" timestamp not null check ("do" > od)
--);

create table miejsca_w_samolocie(
  id_modelu_samolotu integer not null references modele_samolotow(model),
  nr_miejsca varchar(3) not null,--np. A25
  rodzaj varchar(20) default 'normal', --pro, plus
  primary key(id_modelu_samolotu, nr_miejsca)
);

create table nadanie_bagazu(
  waga numeric(3, 2), -- >=18 kg, >=32kg, 32kg +
  id_biletu integer references bilety(id_biletu)
);

--zmiany w tabelach zawiera plik alter.sql
--funkcja spr czy dwom osobom niezostalo przyznane jedno miejsce

--funkcja wypisz kortke podróż bagażu np KRK->WAW->BAR->VIE

create or replace language plpython3u;
