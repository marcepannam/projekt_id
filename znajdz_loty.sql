create or replace function znajdz_id_lotow(src text, dest text, czas timestamp) returns text[] as $$
import time, datetime

def parse_date(x):
    return time.mktime(datetime.datetime.strptime(x, "%Y-%m-%d %H:%M:%S").timetuple())

czas1 = parse_date(czas)

que = set()
que.add(src)
dist = {}
dist[src] = czas1
parent = {}
result = []
min_space = 30 * 60

query = plpy.prepare('select id_lotu, dokad, przylot from loty where skad = $1 and odlot >= to_timestamp($2)', ['text', 'float'])

def get_edges(x):
    r = []
    for v in plpy.execute(query, [x, dist[x] + min_space]):
       dokad = v['dokad']
       przylot = parse_date(v['przylot'])
       r.append((dokad, przylot - dist[x], v['id_lotu']))
    return r

while que:
    node = min(que, key=lambda x: dist[x])
    que.remove(node)

    for i, cost, id_lotu in get_edges(node):
        if i not in dist or dist[i] > dist[node] + cost:
            parent[i] = (node, id_lotu)
            que.add(i)
            dist[i] = dist[node] + cost

if dest not in parent:
    return []

i = dest
while i != src:
    result.append(parent[i][1])
    i = parent[i][0]

result.reverse()
#raise Exception(result)
return result


$$ language plpython3u;

create or replace function znajdz_loty(src text, dest text, czas timestamp) returns setof loty as $$
select loty.* from
(select unnest(znajdz_id_lotow(src, dest, czas)) as id) a
join loty on id_lotu = id;
$$ language sql;


create or replace function zaplanuj_lot(id_biletu_laczonego bigint, src text, dest text, czas timestamp) returns void as $$

    insert into bilety (kod_lotu, data_lotu, id_biletu_laczonego, cena) select (select l.kod_lotu from loty l where l.id_lotu = z.id_lotu), (select odlot::date from loty l where l.id_lotu = z.id_lotu), $1, 100 from znajdz_loty($2, $3, czas) z;


$$ language sql;
