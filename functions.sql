CREATE OR REPLACE FUNCTION ortodroma(fi1 NUMERIC(18, 15), lambda1  NUMERIC(18, 15), fi2  NUMERIC(18, 15), lambda2  NUMERIC(18, 15)) RETURNS  NUMERIC(5, 3) AS $$
DECLARE
	angle_distance NUMERIC(20, 15);
BEGIN
	angle_distance = acos(sin(fi1) * sin(fi2) + cos(fi1) * cos(fi2) * cos(fi2 - fi1));
RETURN round((angle_distance * 111.195), 3);
END; 
$$ language plpgsql;

CREATE OR REPLACE FUNCTION from_PLN(how_much NUMERIC(6,2), currency char(3)) RETURNS NUMERIC(6,2) AS $$
BEGIN
	IF currency = 'EUR' 
	THEN 
		RETURN round( (how_much / 4.3) , 2);
	ELSE 
		IF currency = 'USD'THEN
			RETURN round((how_much / 3.8), 2);
		ELSE
			RAISE EXCEPTION 'currency not accepted';
		END IF;
	END IF;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION good_for_fly() RETURNS TRIGGER AS $good_for_fly$
DECLARE 
	line RECORD;
	line_ RECORD;
	S1 NUMERIC(18, 15);
	D1 NUMERIC(18, 15);
	S2 NUMERIC(18, 15);
	D2 NUMERIC(18, 15);
	line1 RECORD;
	line2 RECORD;
BEGIN
	FOR line IN( SELECT czy_sprawny FROM samoloty WHERE samoloty.id_samolotu = NEW.id_samolotu ) LOOP
		IF line.czy_sprawny = FALSE THEN RAISE EXCEPTION 'niesprawny samolot - nie poleci'; END IF;
	END LOOP;
	FOR line_ IN(
		SELECT zasieg FROM ((SELECT id_modelu FROM samoloty WHERE id_samolotu = NEW.id_samolotu) AS model 
		JOIN modele_samolotow ON samoloty.id_modelu = modele_samolotow.model) AS wszystko_o_samolocie)
	LOOP
		FOR line1 IN( SELECT szerokosc, dlugosc FROM lotniska WHERE kod_iata = airport1 ) LOOP S1 = line1.szerokosc; D1 = line1.dlugosc; END LOOP;
		FOR line2 IN( SELECT szerokosc, dlugosc FROM lotniska WHERE kod_iata = airport2 ) LOOP S2 = line2.szerokosc; D2 = line2.dlugosc; END LOOP;
		IF line_.zasieg < ortodroma(S1, D1, S2, D2) THEN RAISE EXCEPTION 'samolot ma zbyt krótki zasięg'; END IF;
	END LOOP;
END;
$good_for_fly$ language plpgsql;
CREATE TRIGGER good_for_fly BEFORE INSERT OR UPDATE ON plany_lotow;
for each row execute procedure good_for_fly();

CREATE OR REPLACE FUNCTION ticket_cost(airport1 char(3), airport2 char(3), klasa varchar(20), oplaty_dodatkowe NUMERIC(7,2)) RETURNS NUMERIC(8,2) AS $$
DECLARE
	total_cost NUMERIC (8, 2);
	S1 NUMERIC(18, 15);
	D1 NUMERIC(18, 15);
	S2 NUMERIC(18, 15);
	D2 NUMERIC(18, 15);
	line RECORD;
	line_ RECORD;
BEGIN
	FOR line IN( SELECT szerokosc, dlugosc FROM lotniska WHERE kod_iata = airport1 ) LOOP S1 = line.szerokosc; D1 = line.dlugosc; END LOOP;
	FOR line_ IN( SELECT szerokosc, dlugosc FROM lotniska WHERE kod_iata = airport2 ) LOOP S2 = line_.szerokosc; D2 = line_.dlugosc; END LOOP;
	total_cost = ortodroma(S1, D1, S2, D2);
	total_cost = total_cost / 2;
	total_cost = total_cost + 100;
	IF klasa = 'ekonomiczna' THEN
		 total_cost = total_cost * 1.2; 
	END IF;
	IF klasa = 'biznes' THEN 
		total_cost = total_cost * 1.6;
		total_cost = total_cost + 250; 
	END IF;
	IF klasa = 'premium' THEN 
		total_cost = total_cost * 2.1; 
		total_cost = total_cost + 1000.00; 
	END IF;
	total_cost = total_cost + oplaty_dodatkowe;
	RETURN total_cost;
END;
$$ language plpgsql;










