create or replace function miejsce_check() returns trigger AS
$$
declare
    a numeric;
BEGIN
    select count(*) into a from loty left join samoloty on loty.id_samolotu=samoloty.id_samolotu left join modele_samolotow on samoloty.id_modelu=modele_samolotow.model left join
    miejsca_w_samolocie on miejsca_w_samolocie.id_modelu_samolotu=modele_samolotow.model where loty.kod_lotu=new.kod_lotu and date_trunc('day',loty.odlot)=new.data_lotu and miejsca_w_samolocie.nr_miejsca=new.miejsce;
    case when a=0 then raise exception 'Nie ma takiego miejsca w samolocie'; else
    end case;

    select count(*) into a from bilety where bilety.id_lotu=new.id_lotu and bilety.miejsce=new.miejsce;
    case when a>0 then raise exception 'Ten bilet jest już sprzedany'; else
    end case;

    return new;
END
$$ LANGUAGE plpgsql;

drop trigger if EXISTS miejsce_w_samolocie on bilety;

CREATE TRIGGER miejsce_w_samolocie before INSERT or update
on bilety
for each row execute procedure miejsce_check();



create or replace function teleport_check() returns trigger AS
$$
DECLARE
 a varchar;
 b varchar;
BEGIN
    select dokad into a from loty where id_samolotu=new.id_samolotu and przylot<=new.odlot order by przylot desc limit 1;
    select skad into b from loty where id_samolotu=new.id_samolotu and odlot>=new.przylot order by odlot asc limit 1;

    case when (not a like null) or (not a like new.skad) then raise exception 'Samolot teleportuje się'; else end case;
    case when (not b like null) or (not b like new.dokad) then raise exception 'Samolot releportuje się'; else end case;

    return new;
end
$$ language plpgsql;

drop trigger if exists teleport_check on plany_lotow;
create trigger teleport_check before insert or update on loty for each row execute procedure teleport_check();