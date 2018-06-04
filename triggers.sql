create or replace function miejsce_check() returns trigger AS
$$
declare
    a numeric;
BEGIN
    select count(*) into a from loty left join samoloty on loty.id_samolotu=samoloty.id_samolotu left join modele_samolotow on samoloty.id_modelu=modele_samolotow.model left join
    miejsca_w_samolocie on miejsca_w_samolocie.id_modelu_samolot=modele_samolotow.model where loty.id_lotu=new.id_lotu;
    case when a=0 then raise exception 'Nie ma takiego miejsca w samolocie';
    end case;

    select count(*) into a from bilety where bilety.id_lotu=new.id_lotu and bilety.miejsce=new.miejsce;
    case when a>0 then raise exception 'Ten bilet jest już sprzedany';
    end case;
    
    return new;
END
$$ LANGUAGE plpgsql;

drop trigger if EXISTS miejsce_w_samolocie on bilety;

CREATE TRIGGER miejsce_w_samolocie before INSERT or update
on bilety
for each row execute procedure miejsce_check();