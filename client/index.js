const http = require('http');
const fs = require('fs');
const {Pool, Client} = require('pg');

const pool = new Pool({
    user: 'thegu',
    host: '127.0.0.1',
    database: 'thegu',
    password: 'zaq1@WSX',
    port: 5432,
});

pool.query('SELECT NOW()', (err, res) => {
    console.log(err, res);
    //pool.end()
});

const hostname = '127.0.0.1';
const port = 80;

const server = http.createServer((req, res) => {
        switch (req.url) {
            case "/":
                fs.readFile("./index.html", function (err, data) {
                    if (err) {
                        res.end(err.where);
                    } else {
                        res.setHeader('Content-Type', 'text/html');
                        res.end(data);
                    }
                });
                break;
            case "/getAirports":
                pool.query("SELECT array_agg(kod_iata order by kod_iata) as kod,array_agg(lotniska.nazwa order by kod_iata) as nazwal,miasta.nazwa FROM miasta inner join lotniska on miasta.id_miasta=lotniska.miasto group by miasta.nazwa order by miasta.nazwa;", function (err, dbres) {
                        if (err) {
                            console.log(err);
                            res.end(err.where);

                        }
                        else {

                            res.setHeader('Content-Type', 'application/json');
                            res.end(JSON.stringify(dbres.rows));
                        }
                    }
                );
                break;
            case
            "/getFlights"
            :
                var body = '';
                req.on('data', function (data) {
                    body += data;

                    // Too much POST data, kill the connection!
                    // 1e6 === 1 * Math.pow(10, 6) === 1 * 1000000 ~~~ 1MB
                    if (body.length > 1e6)
                        request.connection.destroy();
                });

                req.on('end', function () {
                    var arr = JSON.parse(body);
                    console.log("SELECT znajdz_loty('" + arr[0] + "','" + arr[1] + "','" + arr[2] + "');");
                    pool.query("SELECT znajdz_loty($1,$2,$3);", [arr[0], arr[1], arr[2]], function (err, dbres) {
                            console.log(dbres);
                            res.setHeader('Content-Type', 'application/json');
                            if (err) {
                                console.log(err);
                                res.end(err.where);
                            } else {
                                var out = [];
                                for (var i = 0; i < dbres.rows.length; i++) {
                                    var temp = [];
                                    var string = dbres.rows[i].znajdz_loty;
                                    string = string.substring(1, string.length - 1);
                                    temp = string.split(',');
                                    console.log(temp);
                                    out[i] = {};
                                    out[i].kod = temp[1];
                                    out[i].skad = temp[5];
                                    out[i].dokad = temp[6];
                                    out[i].odlot = temp[7];
                                    out[i].przylot = temp[8];
                                    out[i].linia = temp[3];
                                    out[i].samolot = temp[2];
                                }
                                q = 0;
                                console.log('here', out.length);
                                var temp = out.length;
                                if (temp == 0) {
                                    res.end(JSON.stringify([]));
                                }
                                for (var j = 0; j < temp; j++) {
                                    console.log('here');

                                    (function (nr) {
                                        console.log("SELECT modele_samolotow.nazwa from samoloty left join modele_samolotow on samoloty.id_modelu=modele_samolotow.model where samoloty.id_samolotu=$1;", out[nr].samolot);
                                        pool.query("SELECT modele_samolotow.nazwa from samoloty left join modele_samolotow on samoloty.id_modelu=modele_samolotow.model where samoloty.id_samolotu=$1;", [out[nr].samolot],
                                            function (err, dbres) {
                                                if (err) {
                                                    console.log(err);
                                                    throw err;
                                                }
                                                out[nr].samolot = dbres.rows[0].nazwa;
                                                q++;
                                                if (q >= temp) {
                                                    q = 0;
                                                    for (var k = 0; k < temp; k++) {
                                                        (function (nr) {
                                                            console.log("SELECT nazwa from linie_lotnicze where id_linii_lotniczej=" + out[nr].linia + ";");
                                                            pool.query("SELECT nazwa from linie_lotnicze where id_linii_lotniczej=$1;", [out[nr].linia], function (err, dbres) {
                                                                out[nr].linia = dbres.rows[0].nazwa;
                                                                q++;
                                                                if (q >= temp) {
                                                                    res.end(JSON.stringify(out));
                                                                }
                                                            });
                                                        })(k)
                                                    }
                                                }
                                            });

                                    })(j);


                                }
                            }

                        }
                    )
                });
                break;
            case
            "/reserve"
            :
                var body = '';
                req.on('data', function (data) {
                    body += data;

                    // Too much POST data, kill the connection!
                    // 1e6 === 1 * Math.pow(10, 6) === 1 * 1000000 ~~~ 1MB
                    if (body.length > 1e6)
                        request.connection.destroy();
                });

                req.on('end', function () {
                    var obj = JSON.parse(body);
                    var query = "INSERT INTO bilety_laczone (kod_rezerewacji,imie,nazwisko,mail,tytul,data_urodzenia,nr_paszportu) values ('" + makeid() + "',$1,$2,$3,$4,$5,$6) returning id_biletu_laczonego;";
                    console.log(obj.birthdate);
                    pool.query(query, [obj.name, obj.surname, obj.email, obj.sex, obj.birthdate, obj.passportnr], function (err, dbres) {
                        if (err) {
                            console.log(err);
                            res.end("Blad nie zarezerwowano");
                        }
                        else {
                            console.log(dbres);
                            var idBiletu = dbres.rows[0].id_biletu_laczonego
                            for (var i = 0; i < obj.arr.length; i++) {
                                (function (obj, i, idBiletu) {
                                    //date trunc obj arr i odlot
                                    obj.arr[i].odlot = obj.arr[i].odlot.split(" ")[0].substring(1);
                                    var query = "INSERT INTO bilety (kod_lotu,data_lotu,id_biletu_laczonego,cena) values ($1,$2,$3,100);"
                                    pool.query(query, [obj.arr[i].kod, obj.arr[i].odlot, idBiletu], function (err, dbres) {
                                        if (err) {
                                            console.log(err);
                                            res.end("Blad, nie zarezerwowano");
                                        } else {
                                            res.end("Pomyślnie zarezerwowano");
                                        }
                                    })
                                })(obj, i, idBiletu);
                            }
                        }
                    });
                });
                break;
        }
    })
;

function makeid() {
    var text = "";
    var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

    for (var i = 0; i < 6; i++)
        text += possible.charAt(Math.floor(Math.random() * possible.length));

    return text;
}

function createCallback(i, out, res, q) {
    return function (err, dbres) {
        out[i].samolot = dbres.rows[0].nazwa;
        q++;
        console.log(q, out.length);
        if (q >= out.length) {
            res.end(JSON.stringify(out));
        }
    }
};

server.listen(port, hostname, () => {
    console.log(`Server running at http://${hostname}:${port}/`);
});