CREATE OR REPLACE FUNCTION correct_after_domain(letter char(1)) RETURNS BOOLEAN AS $$
DECLARE
	nr INTEGER;
BEGIN
	nr = ascii(letter);
	IF 
		(ascii('A') <= nr AND nr <= ascii('Z')) OR
		(ascii('a') <= nr AND nr <= ascii('z')) OR
		(ascii('0') <= nr AND nr <= ascii('9')) OR
		letter = '-' OR
		letter = '.'
	THEN
		RETURN true;
	END IF;
	RETURN false;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION email_check(email varchar(25)) RETURNS BOOLEAN AS $$
DECLARE
	size_ INTEGER;
BEGIN
	IF email IS NULL THEN RETURN TRUE END IF;
	size_ = char_length(email);
	IF 
		substring(email, 1, 1) = '.' OR 
		substring(email, 1, 1) = '@' OR 
		substring(email, size_, 1) = '@' OR 
		substring(email, size_, 1) = '.' OR
		position('@' in email) = 0
	THEN
		RETURN FALSE;
	END IF;
	FOR i in (position('@' in email) + 1)..size_ LOOP
		IF not correct_after_domain(substring(email, i, 1)) THEN return false; END IF;
	END LOOP;
	RETURN true;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION ortodroma(fi1 double, lambda1 double, fi2 double, lambda2 double) RETURNS double AS $$
DECLARE
	angle_distance NUMERIC(3,5);
BEGIN
	angle_distance = acos(sin(fi1) * sin(fi2) + cos(fi1) * cos(fi2) * cos(fi2 - fi1));
	RETURN angle_distance * 111,195;
END; $$ language plpgsql;

CREATE OR REPLACE FUNCTION from_PLN(how_much NUMERIC(6,2), currency char(3)) RETURNS NUMERIC(6,2) AS $$
BEGIN
	IF currency = 'EUR' 
	THEN 
		RETURN round( (how_much / 4.3) , 2);
	ELSE 
		IF currency = 'USD'THEN
			RETURN round((how_much / 3.8), 2);
		ELSE
			RAISE EXCEPTION 'not civilised currency';
		END IF;
	END IF;
END;
$$ LANGUAGE plpgsql;
