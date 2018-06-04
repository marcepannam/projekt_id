create or replace function miejsce_check() returns trigger AS
$$
declare
    a numeric;
BEGIN
    select count(*) into a from bilety where bilety.id_lotu=new.id_lotu and bilety.miejsce=new.miejsce;
    case when a>0 then raise exception 'Ten bilet jest już sprzedany'; else return new; end case;
END
$$ LANGUAGE plpgsql;

drop trigger if EXISTS miejsce_w_samolocie on bilety;

CREATE TRIGGER miejsce_w_samolocie before INSERT or update
on bilety
for each row execute procedure miejsce_check();