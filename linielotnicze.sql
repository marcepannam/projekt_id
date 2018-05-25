--LINIA LOTNICZA TANIE CZARTERY SAMOLOTÓW
--Linia lotnicza powstała w 2005 roku. Do tej pory oferowała jedynie loty czarterowe.
--Od nowego roku postanowiła wprowadzić również loty rejsowe. Zatrudniła ciebie do zaprojektowania bazy, w której będzie przechowywać dane o lotach.

create table kraj(
	id_kraju serial primary key,
	nazwa varchar(20) not null,
	czy_w_schegen boolean not null	
);


create table lotniska(
	kod_IATA varchar(6) primary key,
	kraj serial not null references kraj(id_kraju)
);


create table samoloty(
	id_samolotu serial primary key,
	nazwa varchar(20),
	--np Bodzio maly helikopter
	id_modelu serial not null,
	czy_sprawny boolean default true
);

create table modele_samolotow(
	model varchar (20) primary key,
	potrzebna_dl_pasa_startowego numeric(6, 2) not null,--w metrach	
	ilosc_miejsc numeric (4) not null,
	ilosc_zalogi numeric (2) not null,
	zasieg varchar(30) not null
);

create table bilety_laczone(
	id_biletu_laczonego serial primary key,
	kod_rezerewacji char(6) not null,
	--zawsze 6 znakowy, globalny
	imie varchar(25) not null,
	nazwisko varchar(25) not null,
	mail varchar(25),
	--moze byc null, spr poprawnosc
	tytul varchar(25) not null,
	--Pan, Pani
	data_urodzenia date not null,
	--spr czy ma <13, jesli tak przydziel czlonka zalogi do opieki
	--do ceny biletu dodaj 300 zl
	nr_paszportu numeric(30) ,
	--tylko loty miedzynarodowe!(schengen nie licza sie jako miedzynarodowe)
	--dla biletow laczonych, w ktorychg wystepuje wiecej niz jeden lot spr
	--czy miedzy lotami jest przynajmniej 30 min odstepu
	oplaty_dodatkowe numeric(7, 2) default 0
);

create table bilety(
	id_biletu serial primary key,
	id_biletu_laczonego integer references bilety_laczone(id_biletu_laczonego),
	--nawetjak maszjeden bielt wpisac wartosc, wtedy id_biletu
	klasa varchar(20) default 'ekonomiczna', 
	--jeszcze biznes, premium (check)
	czy_karta_pokladowa_wystawiona boolean default false, 
	--zrobic funkcje wstawiajaca karty pokladowe
	cena numeric(7, 2) not null, 
	-- funkcja przeliczajaca  pln na euro i dolary
	oplacony boolean default false
	--jesli nieoplacona nie wystawiaj karty pokladowej
);


create table pasy_startowe (
	id_pasa serial primary key,
	id_lotniska varchar(6) not null references lotniska(kod_IATA),
	dl_pasa numeric(6, 2) not null --w metrach
);

create table lot(
	id_samolotu integer references samoloty(id_samolotu),
	kod numeric(6) not null,
	skad varchar(6) not null references lotniska (kod_IATA),	--nr lotniska
	dokad varchar(6) not null references lotniska (kod_IATA),
	odlot timestamp not null,--w utc
	wylot timestamp not null,--w utc
	nr_pasa_startowego_przylot serial references pasy_startowe(id_pasa), --kodlotniska+4cyfrowy_nr
	czy_miedzynarodowy boolean not null
	--check sprawdzajaca czy loty na pasach startowych sie nie pokrywaja
	--check spr czy dlugosc pasa startowego jest opowiednia
	--check sprawdzajaca czy samolot sie nie teleportuje
);

create table rezerwacja_pasow_startowych(
	id_pasa integer not null, 	
	od timestamp not null,
	"do" timestamp not null
);


create table miejsca_w_samolocie(
	id_modelu_samolotu numeric(2) not null,
	nr_miejsca varchar(5) not null,--np. A25	
	rodzaj varchar(20) default 'normal' --pro, plus
);

create table nadanie_bagazu(
	waga numeric(3, 2), -- >=18 kg, >=32kg, 32kg +
	id_biletu integer references bilety(id_biletu)
);


--funkcja spr czy dwom osobom niezostalo przyznane jedno miejsce

--funkcja wypisz kortke podróż bagażu np KRK->WAW->BAR->VIE
