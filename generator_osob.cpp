#include <algorithm>
#include <cstdlib>
#include <ctime>
#include <fstream>
#include <iostream>
#include <vector>

using namespace std;

/*
id_biletu_laczonego serial primary key,
  kod_rezerewacji char(6) not null,
  --zawsze 6 znakowy, globalny
  --nie mamy modelu "pasazer", poniewaz nie zbieramy unikalnych identyfikatorow
(np. PESELu, nr paszportu jest nieobowiazkowy)
  tytul varchar(25) not null,
  --Pan, Pani
  imie varchar(25) not null,
  nazwisko varchar(25) not null,
  mail varchar(25),
  --moze byc null, spr poprawnosc
  data_urodzenia date not null,
  --spr czy ma <13, jesli tak przydziel czlonka zalogi do opieki
  --do ceny biletu dodaj 300 zl
  nr_paszportu numeric(30) ,
  --tylko loty miedzynarodowe!(schengen nie licza sie jako miedzynarodowe)
  --dla biletow laczonych, w ktorychg wystepuje wiecej niz jeden lot spr
  --czy miedzy lotami jest przynajmniej 30 min odstepu
  oplaty_dodatkowe numeric(7, 2) default 0
*/

template <typename T>
vector<T> readlines(string fi) {
  ifstream f(fi);
  vector<T> n;
  while (true) {
    T nn;
    if (!(f >> nn))
      break;
    n.push_back(nn);
  }
  return n;
}

template <typename M>
auto random_choice(const M& v) {
  return v[rand() % v.size()];
}

int main(int argc, char** argv) {
  cout << "begin;" << endl;
  fstream surname("nazwiska.txt");
  vector<string> names = readlines<string>("imiona.txt");
  vector<string> surnames = readlines<string>("nazwiska.txt");
  
  string alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  string digits = "0123456789";

  vector<string> kody_lotnisk = readlines<string>("airports_codes.txt");
  vector<int> id_linii_lotniczych = readlines<int>("id_linii_lotniczych.txt");
  kody_lotnisk = vector<string>(kody_lotnisk.begin(), kody_lotnisk.begin() + 150);

  int ilosc_linii = 100;
  int rok = 3600*24*365;

  // loty!

  string polecenie = argv[1];

  if (polecenie == "loty") {
  int ilosc_samolotow = 500;

  for (int id_samolotu=1; id_samolotu <= ilosc_samolotow; id_samolotu ++) {
    // 

    string start = random_choice(kody_lotnisk);
    int czas = rand() % (60*24);
    while (czas < 60*24*6) {
      string koniec = random_choice(kody_lotnisk);
      while (koniec == start) koniec = random_choice(kody_lotnisk);

      int odlot = czas; // sekundy po 1970
      czas += rand() % (9*60) + 40;
      int przylot = czas;
      czas += rand() % (20*60) + 4*60;

      int linia = random_choice(id_linii_lotniczych);
      string kod;
      for (int i=0;i<6;i++) kod += random_choice(alphabet);
  
      cout << "insert into plany_lotow (id_samolotu, linia_lotnicza, kod, skad, dokad, dzien_tygodnia, odlot, czas_lotu)   values (" << id_samolotu << "," <<
      linia << ",'" << kod << "','" <<
      start << "','" << koniec << "'," << (odlot/(24*60)) << "," << (odlot%(24*60)) << "," << przylot - odlot 
      << ");" << endl;

      start = koniec;
    }
  }
  } else if (polecenie == "bilety") {
  
  // bilety_laczone
  for (int i=1; i<=600; i++) {
    string name = random_choice(names);
    string surname = random_choice(surnames);
    string title;

    if (name[name.size()-1] == 'a') {
      title = "Pani";
    } else {
      title = "Pan";
    }

    string code;
    for (int i=0;i<6;i++) code += random_choice(alphabet);

    string mail = name + "." + surname + random_choice(digits) + 
    random_choice(vector<string>{"@gmail.com", "@gmail.com", "@onet.pl", "@buziaczek.pl"});

    string data_urodzenia = to_string(1920 + rand() % 80) + "-" + to_string(rand()%12+1) + "-" +
        to_string(rand()%28+1);

    string nr_paszportu = "A";
    for (int i=0; i < 2; i++) nr_paszportu += random_choice(alphabet);
    for (int i=0; i < 7; i++) nr_paszportu += random_choice(digits);

    cout << "insert into bilety_laczone (id_biletu_laczonego,kod_rezerewacji,imie,nazwisko,mail,tytul,data_urodzenia,nr_paszportu) values (" <<
     i << ",'" << code << "','" << name << "','" << surname << "','" << mail << "','" <<
     title << "','" << data_urodzenia << "'::date,'" << nr_paszportu << "');" << endl;

    // generujemy bileciki!
    
    string skad = random_choice(kody_lotnisk);
    string dokad = random_choice(kody_lotnisk);
    while (dokad == skad) dokad = random_choice(kody_lotnisk);

    int planuj_po = rok * 40;// + rand() % (rok / 5);
    cout << "select zaplanuj_lot(" << i << ", '" << skad << "', '" <<  dokad <<"', to_timestamp("<< planuj_po << ")::timestamp);" << endl;
  }
  }

  cout << "commit;" << endl;
}
