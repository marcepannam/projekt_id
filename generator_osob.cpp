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

vector<string> readlines(std::string fi) {
  ifstream f(fi);
  vector<string> n;
  while (true) {
    string nn;
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

int main() {
  fstream surname("nazwiska.txt");
  vector<string> names = readlines("imiona.txt");
  vector<string> surnames = readlines("nazwiska.txt");
  
  string alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  string digits = "0123456789";

  vector<string> kody_lotnisk = readlines("airports_codes.txt");
  kody_lotnisk = vector<string>(kody_lotnisk.begin(), kody_lotnisk.begin() + 10);

  int ilosc_linii = 100;
  int rok = 3600*24*365;

  // loty!

  for (int i=1; i <=30; i++) {
    string start = random_choice(kody_lotnisk);
    string koniec = random_choice(kody_lotnisk);
    while (koniec == start) koniec = random_choice(kody_lotnisk);
    int odlot = rok * 40 + rand() % (rok / 10); // sekundy po 1970
    int przylot = odlot + 3200 + rand() % 7200;
    int linia = rand() % ilosc_linii + 1;
    int id_samolotu = 1;
    string kod;
    for (int i=0;i<6;i++) kod += random_choice(alphabet);

    cout << "insert into loty (linia_lotnicza, kod, skad, dokad, odlot, przylot) values (" << linia << ",'" << kod << "','" <<
    start << "','" << koniec << "',to_timestamp(" << odlot << "),to_timestamp(" << przylot
    << "));" << endl;
  }
  
  // bilety_laczone
  for (int i=1; i<=100; i++) {
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

    cout << "select zaplanuj_lot(" << i << ", '" << skad << "', '" <<  dokad <<"', '2008-12-30 13:52:57'::timestamp);" << endl;
  }
}