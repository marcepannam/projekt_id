--LINIA LOTNICZA TANIE CZARTERY SAMOLOTÓW
--Linia lotnicza powstała w 2005 roku. Do tej pory oferowała jedynie loty czarterowe.
--Od nowego roku postanowiła wprowadzić również loty rejsowe. Zatrudniła ciebie do zaprojektowania bazy, w której będzie przechowywać dane o lotach.
drop table if exists kraje cascade;
drop table if exists lotniska cascade;
drop table if exists modele_samolotow cascade;
drop table if exists samoloty cascade;
drop table if exists bilety cascade;
drop table if exists bilety_laczone cascade;
drop table if exists pasy_startowe cascade;
drop table if exists loty cascade;
drop table if exists nadanie_bagazu cascade;
drop table if exists miejsca_w_samolocie cascade;
drop table if exists rezerwacje_pasow_startowych cascade;
drop table if exists linie_lotnicze cascade;

create table kraje(
  kod_iso varchar(2) primary key,
  nazwa varchar(40) not null,
  czy_w_schengen boolean not null  
);

create table linie_lotnicze(
  id_linii_lotniczej serial primary key,
  nazwa varchar(50) not null,
  kod_iata varchar(2) not null,
  kod_icao varchar(3) not null,
  nazwa_kraju varchar(40)
);

create table lotniska(
  kod_IATA varchar(6) primary key,
  kraj varchar(2) not null references kraje
);


create table modele_samolotow(
  model varchar(20) primary key,
  potrzebna_dl_pasa_startowego numeric(6, 2) not null,--w metrach 
  ilosc_miejsc numeric (4) not null,
  ilosc_zalogi numeric (2) not null,
  zasieg varchar(30) not null
);


create table samoloty(
  id_samolotu serial primary key,
  nazwa varchar(20),
  --np Bodzio maly helikopter
  id_modelu varchar(20) not null references modele_samolotow(model),
  czy_sprawny boolean default true
);
create table bilety_laczone(
  id_biletu_laczonego serial primary key,
  kod_rezerewacji char(6) not null,
  --zawsze 6 znakowy, globalny
  --nie mamy modelu "pasazer", poniewaz nie zbieramy unikalnych identyfikatorow (np. PESELu, nr paszportu jest nieobowiazkowy)
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


create table pasy_startowe (
  id_pasa serial primary key,
  id_lotniska varchar(6) not null references lotniska(kod_IATA),
  dl_pasa numeric(6, 2) not null --w metrach
);

create table loty(
  id_lotu serial primary key,
  id_samolotu integer references samoloty(id_samolotu),
  linia_lotnicza integer references linie_lotnicze,
  kod numeric(6) not null,
  skad varchar(6) not null references lotniska (kod_IATA),  --nr lotniska
  dokad varchar(6) not null references lotniska (kod_IATA) check (skad <> dokad),
  odlot timestamp not null,--w utc
  przylot timestamp not null,--w utc
  nr_pasa_startowego_przylot serial references pasy_startowe(id_pasa), --kodlotniska+4cyfrowy_nr
  czy_miedzynarodowy boolean not null
  --check sprawdzajaca czy loty na pasach startowych sie nie pokrywaja
  --check spr czy dlugosc pasa startowego jest opowiednia
  --check sprawdzajaca czy samolot sie nie teleportuje
);

create table bilety(
  id_biletu serial primary key,
  id_lotu integer references loty(id_lotu),
  id_biletu_laczonego integer references bilety_laczone(id_biletu_laczonego),
  --nawetjak maszjeden bielt wpisac wartosc, wtedy id_biletu
  klasa varchar(20) default 'ekonomiczna', 
  --jeszcze biznes, premium (check)
  czy_karta_pokladowa_wystawiona boolean default false, 
  --zrobic funkcje wstawiajaca karty pokladowe
  cena numeric(7, 2) not null, 
  -- funkcja przeliczajaca  pln na euro i dolary
  oplacony boolean default false,
  --jesli nieoplacona nie wystawiaj karty pokladowej
  miejsce varchar(5) -- + check czy takie miejsce jest w samolocie i czy nie pokrywaja sie
);

create table rezerwacje_pasow_startowych(
  id_pasa integer not null references pasy_startowe(id_pasa),   
  od timestamp not null,
  "do" timestamp not null check ("do" > od)
);


create table miejsca_w_samolocie(
  id_modelu_samolotu varchar(20) not null references modele_samolotow(model),
  nr_miejsca varchar(5) not null,--np. A25
  rodzaj varchar(20) default 'normal' --pro, plus
);

create table nadanie_bagazu(
  waga numeric(3, 2), -- >=18 kg, >=32kg, 32kg +
  id_biletu integer references bilety(id_biletu)
);


COPY linie_lotnicze(id_linii_lotniczej, nazwa, kod_iata, kod_icao, nazwa_kraju) from stdin;
3	1Time Airline	1T	RNX	South Africa
10	40-Mile Air	Q5	MLA	United States
13	Ansett Australia	AN	AAA	Australia
21	Aigle Azur	ZI	AAF	France
22	Aloha Airlines	AQ	AAH	United States
24	American Airlines	AA	AAL	United States
28	Asiana Airlines	OZ	AAR	Republic of Korea
29	Askari Aviation	4K	AAS	Pakistan
32	Afriqiyah Airways	8U	AAW	Libya
35	Allegiant Air	G4	AAY	United States
42	ABSA - Aerolinhas Brasileiras	M3	TUS	Brazil
55	Astral Aviation	8V	ACP	Kenya
72	Ada Air	ZY	ADE	Albania
83	Adria Airways	JP	ADR	Slovenia
90	Air Europa	UX	AEA	Spain
93	Aero Benin	EM	AEB	Benin
96	Aegean Airlines	A3	AEE	Greece
106	Air Europe	PE	AEL	Italy
109	Alaska Central Express	KO	AER	United States
112	Astraeus	5W	AEU	United Kingdom
114	Aerosvit Airlines	VV	AEW	Ukraine
116	Air Italy	I9	AEY	Italy
120	Alliance Airlines	QQ	UTY	Australia
125	Ariana Afghan Airlines	FG	AFG	Afghanistan
130	Aeroflot Russian Airlines	SU	AFL	Russia
132	Air Bosna	JA	BON	Bosnia and Herzegovina
137	Air France	AF	AFR	France
139	Air Caledonie International	SB	ACI	France
149	Air Cargo Carriers	2Q	SNC	United States
153	Air Namibia	SW	NMB	Namibia
165	Aerolitoral	5D	SLI	Mexico
174	Air Glaciers	7T	AGV	Switzerland
179	Aeroper	PL	PLI	Peru
180	Atlas Blue	8A	BMM	Morocco
197	Azerbaijan Airlines	J2	AHY	Azerbaijan
198	Avies	U3	AIA	Estonia
208	Airblue	ED	ABQ	Pakistan
214	Air Berlin	AB	BER	Germany
218	Air India Limited	AI	AIC	India
220	Air Bourbon	ZB	BUB	Reunion
221	Air Atlanta Icelandic	CC	ABD	Iceland
225	Air Tahiti Nui	TN	THT	France
231	Arkia Israel Airlines	IZ	AIZ	Israel
239	Air Jamaica	JM	AJM	Jamaica
240	Air One	AP	ADH	Italy
241	Air Sahara	S2	RSH	India
242	Air Malta	KM	AMC	Malta
250	Air Japan	NQ	AJX	Japan
263	Air Kiribati	4A	AKL	Kiribati
281	America West Airlines	HP	AWE	United States
282	Air Wisconsin	ZW	AWI	United States
286	Tatarstan Airlines	U9	TAK	Russia
306	Air Malawi	QM	AML	Malawi
316	Air Macau	NX	AMU	Macao
319	Air Seychelles	HM	SEY	Seychelles
321	AeroMéxico	AM	AMX	Mexico
324	All Nippon Airways	NH	ANA	Japan
327	Air Nostrum	YW	ANE	Spain
328	Air Niugini	PX	ANG	Papua New Guinea
329	Air Arabia	G9	ABY	United Arab Emirates
330	Air Canada	AC	ACA	Canada
333	Air Baltic	BT	BTI	Latvia
336	Air Nippon	EL	ANK	Japan
338	Airnorth	TL	ANO	Australia
341	Air North Charter - Canada	4N	ANT	Canada
345	Air New Zealand	NZ	ANZ	New Zealand
371	Alitalia Express	XM	SMX	Italy
386	Aero Flight	GV	ARF	Germany
397	Arrow Air	JW	APW	United States
410	Aerocondor	2B	ARD	Portugal
411	Aires	4C	ARE	 S.A.
412	Aerolineas Argentinas	AR	ARG	Argentina
439	Alaska Airlines	AS	ASA	ALASKA
442	Air Sinai	4D	ASD	Egypt
452	Atlantic Southeast Airlines	EV	ASQ	United States
462	Astrakhan Airlines	OB	ASZ	Russia
465	Air Tanzania	TC	ATC	Tanzania
470	Air Burkina	2J	VBW	Burkina Faso
476	Airlines Of Tasmania	FO	ATM	Australia
477	Air Saint Pierre	PJ	SPM	France
491	Austrian Airlines	OS	AUA	Austria
493	Augsburg Airways	IQ	AUB	Germany
502	Abu Dhabi Amiri Flight	MO	AUH	United Arab Emirates
503	Aeroflot-Nord	5N	AUL	Russia
508	Aurigny Air Services	GR	AUR	United Kingdom
510	Austral Lineas Aereas	AU	AUT	Argentina
515	Avianca - Aerovias Nacionales de Colombia	AV	AVA	AVIANCA
524	Air Vanuatu	NF	AVN	Vanuatu
543	Air Bangladesh	B9	BGD	Bangladesh
547	Air Mediterranee	DR	BIE	France
563	Aeroline GmbH	7E	AWU	Germany
565	Air Wales	6G	AWW	United Kingdom
567	Air Caraïbes	TX	FWI	France
569	Air India Express	IX	AXB	India
575	Air Exel	XT	AXL	Netherlands
576	AirAsia	AK	AXM	Malaysia
595	Atlant-Soyuz Airlines	3G	AYZ	Russia
596	Alitalia	AZ	AZA	Italy
603	Amaszonas	Z8	AZN	Bolivia
608	Air Zimbabwe	UM	AZW	Zimbabwe
622	Aserca Airlines	R7	OCA	Venezuela
641	Rossiya-Russian Airlines	FV	SDM	Russia
659	American Eagle Airlines	MQ	EGF	United States
682	Air Ivoire	VU	VUN	Ivory Coast
683	Air Botswana	BP	BOT	Botswana
690	Air Foyle	GS	UPA	United Kingdom
692	Air Tahiti	VT	VTA	French Polynesia
695	Air VIA	VL	VIM	Bulgaria
715	Africa West	FK	WTA	Togo
724	ATRAN Cargo Airlines	V8	VAS	Russian Federation
751	Air China	CA	CCA	China
753	Aero Condor Peru	Q6	CDP	Peru
787	Air Chathams	CV	CVA	New Zealand
788	Air Marshall Islands	CW	CWM	Marshall Islands
792	Access Air	ZA	CYD	United States
794	Air Algerie	AH	DAH	Algeria
800	Adam Air	KI	DHI	Indonesia
807	Air Dolomiti	EN	DLA	Italy
816	Aeroflot-Don	D9	DNV	Russia
817	Air Madrid	NM	DRD	Spain
837	Aer Lingus	EI	EIN	Ireland
876	Air Finland	OF	FIF	Finland
879	Air Pacific	FJ	FJI	Fiji
881	Atlantic Airways	RC	FLI	Faroe Islands
882	Air Florida	QH	FLZ	United States
896	Air Iceland	NY	FXI	Iceland
897	Air Philippines	2P	GAP	Philippines
909	Air Guinee Express	2U	GIP	Guinea
921	Air Greenland	GL	GRL	Denmark
928	Atlas Air	5Y	GTI	United States
931	Air Guyane	GG	GUY	French Guiana
970	Air Bagan	W9	JAB	Myanmar
983	Air Canada Jazz	QK	JZA	Canada
995	Atlasjet	KK	KKK	Turkey
998	Air Koryo	JS	KOR	Democratic People's Republic of Korea
1006	Air Astana	KC	KZR	Kazakhstan
1008	Albanian Airlines	LV	LBC	Albania
1034	Aerolane	XL	LNE	Ecuador
1048	Atlantis European Airways	TD	LUR	Armenia
1052	Air Luxor	LK	LXR	Portugal
1057	Air Mauritius	MK	MAU	Mauritius
1066	Air Madagascar	MD	MDG	Madagascar
1073	Air Moldova	9U	MLD	Moldova
1087	Air Plus Comet	A7	MPD	Spain
1116	Aero Contractors	AJ	NIG	Nigeria
1143	Aeropelican Air Services	OT	PEL	Australia
1188	Aer Arann	RE	REA	Ireland
1191	Air Austral	UU	REU	France
1200	Asian Spirit	6K	RIT	Philippines
1202	Air Afrique	RK	RKA	Ivory Coast
1203	Airlinair	A5	RLA	France
1206	Aero Lanka	QL	RLN	Sri Lanka
1213	Air Salone	20	RNE	Sierra Leone
1216	Armavia	U8	RNV	Armenia
1224	AeroRep	P5	RPB	Colombia
1230	Aero-Service	BF	RSR	Republic of the Congo
1231	Aerosur	5L	RSU	Bolivia
1266	Avient Aviation	Z3	SMJ	Zimbabwe
1287	Aircompany Yakutia	R3	SYL	Russia
1290	Aeromar	VW	TAO	Mexico
1299	Arkefly	OR	TFL	Netherlands
1308	Airlines PNG	CG	TOK	Papua New Guinea
1316	AirTran Airways	FL	TRS	United States
1317	Air Transat	TS	TSC	Canada
1322	Avialeasing Aviation Company	EC	TWN	Uzbekistan
1326	Tyrolean Airways	VO	TYR	Austria
1338	Aerolineas Galapagos (Aerogal)	2K	GLG	Ecuador
1340	Alrosa Mirny Air Enterprise	6R	DRU	Russia
1355	British Airways	BA	BAW	United Kingdom
1359	Biman Bangladesh Airlines	BG	BBC	Bangladesh
1401	Belair Airlines	4T	BHP	Switzerland
1403	Bahamasair	UP	BHS	Bahamas
1411	British International Helicopters	BS	BIH	United Kingdom
1422	Bangkok Airways	PG	BKP	Thailand
1427	Blue1	KF	BLF	Finland
1434	Bearskin Lake Air Service	JV	BLS	Canada
1436	Bellview Airlines	B3	BLV	Nigeria
1437	bmi	BD	BMA	United Kingdom
1441	bmibaby	WW	BMI	United Kingdom
1442	Bemidji Airlines	CH	BMJ	United States
1463	Blue Panorama Airlines	BV	BPA	Italy
1472	Bering Air	8E	BRG	United States
1478	Belavia Belarusian Airlines	B2	BRU	Belarus
1500	Metro Batavia	7P	BTV	Indonesia
1508	Berjaya Air	J8	BVT	Malaysia
1510	Blue Wings	QW	BWG	Germany
1523	Brit Air	DB	BZH	France
1531	Brussels Airlines	SN	DAT	Belgium
1539	Binter Canarias	NT	IBB	Spain
1542	Blue Air	0B	JOR	Romania
1543	British Mediterranean Airways	KJ	LAJ	United Kingdom
1548	Bulgaria Air	FB	LZB	Bulgaria
1550	Barents AirLink	8N	NKF	Sweden
1581	CAL Cargo Air Lines	5C	ICL	Israel
1607	Calima Aviacion	XG	CLI	Spain
1615	Canadian Airlines	CP	CDN	Canada
1623	Canadian North	5T	MPE	Canada
1629	Cape Air	9K	KAP	United States
1663	Caribbean Airlines	BW	BWA	Trinidad and Tobago
1669	Carpatair	V3	KRP	Romania
1675	Caspian Airlines	RV	CPN	Iran
1680	Cathay Pacific	CX	CPA	Hong Kong SAR of China
1682	Cayman Airways	KX	CAY	Cayman Islands
1683	Cebu Pacific	5J	CEB	Philippines
1708	Centralwings	C0	CLW	Poland
1739	Chautauqua Airlines	RP	CHQ	United States
1756	China Airlines	CI	CAL	Taiwan
1758	China Eastern Airlines	MU	CES	China
1767	China Southern Airlines	CZ	CSN	China
1769	China United Airlines	HR	CUA	China
1771	Yunnan Airlines	3Q	CYH	China
1781	Cimber Air	QI	CIM	Denmark
1784	Cirrus Airlines	C9	RUS	Germany
1789	City Airline	CF	SDR	Sweden
1790	City Connexion Airlines	G3	CIX	Burundi
1792	CityJet	WX	BCY	Ireland
1795	BA CityFlyer	CJ	CFE	United Kingdom
1821	Colgan Air	9L	CJC	United States
1828	Comair	OH	COM	United States
1829	Comair	MN	CAW	South Africa
1843	CommutAir	C5	UCA	United States
1844	Comores Airlines	KR	CWK	Comoros
1860	Compass Airlines	CP	CPZ	United States
1868	Condor Flugdienst	DE	CFG	Germany
1876	Consorcio Aviaxsa	6A	CHP	Mexico
1879	Contact Air	C3	KIS	Germany
1881	Continental Airlines	CO	COA	United States
1884	Continental Micronesia	CS	CMI	United States
1886	Conviasa	V0	VCV	Venezuela
1889	Copa Airlines	CM	CMP	Panama
1908	Corsairfly	SS	CRL	France
1909	Corse-Mediterranee	XK	CCM	France
1925	Croatia Airlines	OU	CTN	Croatia
1936	Cubana de Aviación	CU	CUB	Cuba
1942	Cyprus Airways	CY	CYP	Cyprus
1946	Czech Airlines	OK	CSA	Czech Republic
1954	DAT Danish Air Transport	DX	DTR	Denmark
1966	Daallo Airlines	D3	DAO	Djibouti
1973	Dalavia	H8	KHB	Russia
1983	Darwin Airline	0D	DWT	Switzerland
2009	Delta Air Lines	DL	DAL	United States
2041	Djibouti Airlines	D8	DJB	Djibouti
2047	Dominicana de Aviaci	DO	DOA	Dominican Republic
2048	Domodedovo Airlines	E3	DMO	Russia
2051	DonbassAero	5D	UDC	Ukraine
2056	Dragonair	KA	HDA	DRAGON
2058	Druk Air	KB	DRK	Bhutan
2077	dba	DI	BAG	Germany
2091	EVA Air	BR	EVA	Taiwan
2104	East African	QU	UGX	Uganda
2117	Eastern Airways	T3	EZE	United Kingdom
2125	Eastland Air	DK	ELA	Australia
2138	Edelweiss Air	WK	EDW	Switzerland
2143	Egyptair	MS	MSR	Egypt
2150	El Al Israel Airlines	LY	ELY	Israel
2155	El-Buraq Air Transport	UZ	BRQ	Libya
2183	Emirates	EK	UAE	United Arab Emirates
2193	Empresa Ecuatoriana De Aviacion	EU	EEA	Ecuador
2213	Eritrean Airlines	B8	ERT	Eritrea
2218	Estonian Air	OV	ELL	Estonia
2220	Ethiopian Airlines	ET	ETH	Ethiopia
2222	Etihad Airways	EY	ETD	United Arab Emirates
2237	Eurocypria Airlines	UI	ECA	Cyprus
2239	Eurofly Service	GJ	EEU	Italy
2245	Eurolot	K2	ELO	Poland
2251	European Air Express	EA	EAL	Germany
2260	Eurowings	EW	EWG	Germany
2261	Evergreen International Airlines	EZ	EIA	United States
2264	Excel Airways	JN	XLA	United Kingdom
2293	Express One International	EO	LHN	United States
2295	ExpressJet	XE	BTA	United States
2297	easyJet	U2	EZY	United Kingdom
2324	Far Eastern Air Transport	EF	EFA	Taiwan
2350	Finnair	AY	FIN	Finland
2351	Finncomm Airlines	FC	WBA	Finland
2353	Firefly	FY	FFM	Malaysia
2354	First Air	7F	FAB	Canada
2357	First Choice Airways	DP	FCA	United Kingdom
2395	Flightline	B5	FLT	United Kingdom
2404	Florida West International Airways	RF	FWL	United States
2417	AirAsia X	D7	XAX	Malaysia
2418	FlyLal	TE	LIL	Lithuania
2419	FlyNordic	LF	NDC	Sweden
2420	Flybaboo	F7	BBO	Switzerland
2421	Flybe	BE	BEE	United Kingdom
2425	Flyglobespan	B4	GSM	United Kingdom
2439	Formosa Airlines	VY	FOS	Taiwan
2454	Freedom Air	FP	FRE	United States
2468	Frontier Airlines	F9	FFT	United States
2470	Frontier Flying Service	2F	FTA	United States
2486	GB Airways	GT	GBL	United Kingdom
2520	Garuda Indonesia	GA	GIA	Indonesia
2524	Gazpromavia	4G	GZP	Russia
2538	Georgian Airways	A9	TGZ	Georgia
2541	Georgian National Airlines	QB	GFG	Georgia
2547	Germania	ST	GMI	Germany
2548	Germanwings	4U	GWI	Germany
2556	Ghana International Airlines	G0	GHB	Ghana
2575	Go Air	G8	GOW	India
2577	GoJet Airlines	G7	GJS	United States
2581	Gol Transportes Aéreos	G3	GLO	Brazil
2585	Golden Air	DC	GAO	Sweden
2607	Great Lakes Airlines	ZK	GLA	United States
2622	Grupo TACA	TA	TAT	Costa Rica
2638	Gulf Air Bahrain	GF	GBA	Bahrain
2657	Hageland Aviation Services	H6	HAG	United States
2660	Hainan Airlines	HU	CHH	China
2663	Haiti Ambassador Airlines	2T	HAM	Haiti
2674	Hamburg International	4R	HHI	Germany
2681	TUIfly	X3	HLX	Germany
2682	Hapagfly	HF	HLF	Germany
2688	Hawaiian Airlines	HA	HAL	United States
2704	Heli France	8H	HFR	France
2731	Helijet	JB	JBA	Canada
2747	Hellas Jet	T4	HEJ	Greece
2748	Hello	HW	FHE	Switzerland
2750	Helvetic Airways	2L	OAW	Switzerland
2757	Hex'Air	UD	HER	France
2765	Hokkaido International Airlines	HD	ADO	Japan
2773	Hong Kong Airlines	HX	CRK	Hong Kong SAR of China
2774	Hong Kong Express Airways	UO	HKE	Hong Kong SAR of China
2778	Horizon Air	QX	QXE	United States
2782	Horizon Airlines	BN	HZA	Australia
2822	Iberia Airlines	IB	IBE	Spain
2825	Iberworld	TY	IWD	Spain
2826	Ibex Airlines	FW	IBX	Japan
2835	Icelandair	FI	ICE	Iceland
2845	Imair Airlines	IK	ITX	Azerbaijan
2850	IndiGo Airlines	6E	IGO	India
2853	Indian Airlines	IC	IAC	India
2855	Indigo	I9	IBU	United States
2857	Indonesia AirAsia	QZ	AWQ	Indonesia
2858	Indonesian Airlines	IO	IAA	Indonesia
2881	Interair South Africa	D6	ILN	South Africa
2883	Interavia Airlines	ZA	SUW	Russia
2896	Interlink Airlines	ID	ITK	South Africa
2916	Intersky	3L	ISK	Austria
2922	Iran Air	IR	IRA	Iran
2923	Iran Aseman Airlines	EP	IRC	Iran
2926	Iraqi Airways	IA	IAW	Iraq
2942	Cargo Plus Aviation	8L	CGP	United Arab Emirates
2948	Islas Airways	IF	ISW	Spain
2950	Islena De Inversiones	WC	ISV	Honduras
2954	Israir	6H	ISR	Israel
2958	Itek Air	GI	IKA	Kyrgyzstan
2969	JAL Express	JC	JEX	Japan
2970	JALways	JO	JAZ	Japan
2987	Japan Airlines	JL	JAL	Japan
2988	Japan Airlines Domestic	JL	JAL	Japan
2989	Japan Asia Airways	EG	JAA	Japan
2990	Japan Transocean Air	NU	JTA	Japan
2993	Jazeera Airways	J9	JZR	Kuwait
2994	Jeju Air	7C	JJA	Republic of Korea
3000	Jet Airways	9W	JAI	India
3021	Jetstar Asia Airways	3K	JSA	Singapore
3026	Jet2.com	LS	EXS	United Kingdom
3027	Jet4You	8J	JFU	Morocco
3029	JetBlue Airways	B6	JBU	United States
3032	Jetairfly	JF	JAF	Belgium
3052	Jetstar Airways	JQ	JST	Australia
3081	Juneyao Airlines	HO	DKH	China
3087	KD Avia	KD	KNI	Russia
3088	KLM Cityhopper	WA	KLC	Netherlands
3090	KLM Royal Dutch Airlines	KL	KLM	Netherlands
3097	Kam Air	RQ	KMF	Afghanistan
3110	Kavminvodyavia	KV	MVD	Russia
3123	Kenmore Air	M5	KEN	United States
3126	Kenya Airways	KQ	KQA	Kenya
3142	Kingfisher Airlines	IT	KFR	India
3148	Kish Air	Y9	IRK	Iran
3157	Kogalymavia Air Company	7K	KGL	Russia
3163	Korean Air	KE	KAL	Republic of Korea
3168	Krasnojarsky Airlines	7B	KJC	Russia
3175	Kuban Airlines	GW	KIL	Russia
3179	Kuwait Airways	KU	KAC	Kuwait
3180	Kuzu Airlines Cargo	GO	KZU	Turkey
3197	LACSA	LR	LRC	Costa Rica
3200	LAN Airlines	LA	LAN	Chile
3201	LAN Argentina	4M	DSM	Argentina
3204	LAN Express	LU	LXP	Chile
3205	LAN Peru	LP	LPE	Peru
3210	LOT Polish Airlines	LO	LOT	Poland
3211	LTE International Airways	XO	LTE	Spain
3212	LTU Austria	L3	LTO	Austria
3233	Lao Airlines	QV	LAO	Lao Peoples Democratic Republic
3239	Lauda Air	NG	LDA	Austria
3251	Leeward Islands Air Transport	LI	LIA	Antigua and Barbuda
3258	Libyan Arab Airlines	LN	LAA	Libya
3287	Linhas A	LM	LAM	Mozambique
3290	Lion Mentari Airlines	JT	LNI	Indonesia
3319	Luftfahrtgesellschaft Walter	HE	LGW	Germany
3320	Lufthansa	LH	DLH	Germany
3321	Lufthansa Cargo	LH	GEC	Germany
3322	Lufthansa CityLine	CL	CLH	Germany
3326	Lufttransport	L5	LTR	Norway
3329	Luxair	LG	LGL	Luxembourg
3342	L	MJ	LPR	Argentina
3349	MasAir	M7	MAA	Mexico
3350	MAT Macedonian Airlines	IN	MAK	Macedonia
3354	MIAT Mongolian Airlines	OM	MGL	Mongolia
3357	MNG Airlines	MB	MNB	Turkey
3363	Macair Airlines	CC	MCK	Australia
3370	Mahan Air	W5	IRM	Iran
3378	Malaysia Airlines	MH	MAS	Malaysia
3386	Malmö Aviation	TF	SCW	Sweden
3387	Malta Air Charter	R5	MAC	Malta
3389	Malév	MA	MAH	Hungary
3391	Mandala Airlines	RI	MDL	Indonesia
3392	Mandarin Airlines	AE	MDA	Taiwan
3393	Mango	JE	MNO	South Africa
3411	Martinair	MP	MPH	Netherlands
3432	Maxair	8M	MXL	Sweden
3437	Maya Island Air	MW	MYD	Belize
3463	Meridiana	IG	ISS	Italy
3465	Merpati Nusantara Airlines	MZ	MNA	Indonesia
3466	Mesa Airlines	YV	ASH	United States
3467	Mesaba Airlines	XJ	MES	United States
3479	Mexicana de Aviaci	MX	MXA	Mexico
3490	Middle East Airlines	ME	MEA	Lebanon
3494	Midway Airlines	JI	MDW	United States
3497	Midwest Airlines	YX	MEP	United States
3498	Midwest Airlines (Egypt)	MY	MWA	Egypt
3529	Moldavian Airlines	2M	MDV	Moldova
3532	Monarch Airlines	ZB	MON	United Kingdom
3539	Montenegro Airlines	YM	MGX	Montenegro
3545	Moskovia Airlines	3R	GAI	Russia
3547	Motor Sich	M9	MSI	Ukraine
3568	MyTravel Airways	VZ	MYT	United Kingdom
3569	Myanma Airways	UB	UBA	Myanmar
3570	Myanmar Airways International	8M	MMM	Myanmar
3589	Nasair	UE	NAS	Eritrea
3608	National Jet Systems	NC	NJS	Australia
3613	Nationwide Airlines	CE	NTW	South Africa
3618	Nauru Air Corporation	ON	RON	Nauru
3637	Nepal Airlines	RA	RNA	Nepal
3641	NetJets	1I	EJA	United States
3644	New England Airlines	EJ	NEA	United States
3652	NextJet	2N	NTJ	Sweden
3661	Niki	HG	NLY	Austria
3674	Nok Air	DD	NOK	Thailand
3731	Northwest Airlines	NW	NWA	United States
3734	Northwestern Air	J3	PLR	Canada
3737	Norwegian Air Shuttle	DY	NAX	Norway
3740	Nouvel Air Tunisie	BJ	LBT	Tunisia
3743	Novair	1I	NVR	Sweden
3754	Nas Air	XY	KNE	Saudi Arabia
3759	Oasis Hong Kong Airlines	O8	OHK	Hong Kong
3764	Oceanair	O6	ONE	Brazil
3776	Olympic Airlines	OA	OAL	Greece
3778	Oman Air	WY	OMA	Oman
3781	Omni Air International	OY	OAE	United States
3788	Onur Air	8Q	OHY	Turkey
3805	Orenburg Airlines	R2	ORB	Russia
3811	Orient Thai Airlines	OX	OEA	Thailand
3814	Origin Pacific Airways	QO	OGN	New Zealand
3822	Ostfriesische Lufttransport	OL	OLT	Germany
3826	Overland Airways	OJ	OLA	Nigeria
3831	Ozjet Airlines	O7	OZJ	Australia
3834	PAN Air	PV	PNR	Spain
3835	PB Air	9Q	PBA	Thailand
3839	PLUNA	PU	PUA	Uruguay
3840	PMTair	U4	PMT	Cambodia
3850	Jetstar Pacific	BL	PIC	Vietnam
3856	Pacific Coastal Airline	8P	PCO	Canada
3857	Pacific East Asia Cargo Airlines	Q8	PEC	Philippines
3865	Pacific Wings	LW	NMI	United States
3871	Pakistan International Airlines	PK	PIA	Pakistan
3907	Paramount Airways	I7	PMW	India
3926	Pegasus Airlines	PC	PGT	Turkey
3935	Peninsula Airways	KS	PEN	United States
3952	Philippine Airlines	PR	PAL	Philippines
3969	Piedmont Airlines (1948-1989)	PI	PDT	United States
3976	Pinnacle Airlines	9E	FLG	United States
4013	Polynesian Airlines	PH	PAO	Samoa
4021	Porter Airlines	PD	POE	Canada
4022	Portugalia	NI	PGA	Portugal
4026	Potomac Air	BK	PDC	United States
4031	Precision Air	PW	PRF	Tanzania
4089	Qantas	QF	QFA	Australia
4091	Qatar Airways	QR	QTR	Qatar
4178	Regional Express	ZL	RXA	Australia
4187	Republic Airlines	RW	RPA	United States
4188	Republic Express Airlines	RH	RPH	Indonesia
4234	Air Rarotonga	GZ	RAR	Cook Islands
4248	Royal Air Maroc	AT	RAM	Morocco
4255	Royal Brunei Airlines	BI	RBA	Brunei
4259	Royal Jordanian	RJ	RJA	Jordan
4264	Royal Nepal Airlines	RA	RNA	Nepal
4292	Rwandair Express	WB	RWD	Rwanda
4295	Ryan International Airlines	RD	RYN	United States
4296	Ryanair	FR	RYR	Ireland
4299	Régional	YS	RAE	France
4304	SATA International	S4	RZO	Portugal
4305	South African Airways	SA	SAA	South Africa
4311	Shaheen Air International	NL	SAI	Pakistan
4319	Scandinavian Airlines System	SK	SAS	Sweden
4329	S7 Airlines	S7	SBI	Russia
4335	Seaborne Airlines	BB	SBS	United States
4349	SriLankan Airlines	UL	ALK	Sri Lanka
4356	Sun Country Airlines	SY	SCX	United States
4374	Sky Express	G3	SEH	Greece
4375	Spicejet	SG	SEJ	India
4388	Star Flyer	7G	SFJ	Japan
4411	Skagway Air Service	N5	SGY	United States
4429	SATA Air Acores	SP	SAT	Portugal
4435	Singapore Airlines	SQ	SIA	Singapore
4436	Sibaviatrans	5M	SIB	Russia
4438	Skynet Airlines	SI	SIH	Ireland
4454	Sriwijaya Air	SJ	SJY	Indonesia
4455	Sama Airlines	ZS	SMY	Saudi Arabia
4464	Singapore Airlines Cargo	SQ	SQC	Singapore
4469	Siem Reap Airways	FT	SRH	Cambodia
4475	South East Asian Airlines	DG	SRQ	Philippines
4496	Skyservice Airlines	5G	SSV	Canada
4513	Servicios de Transportes A	FS	STU	Argentina
4521	Sudan Airways	SD	SUD	Sudan
4533	Saudi Arabian Airlines	SV	SVA	Saudi Arabia
4547	Southwest Airlines	WN	SWA	United States
4550	Southern Winds Airlines	A4	SWD	Argentina
4559	Swiss International Air Lines	LX	SWR	Switzerland
4560	Swissair	SR	SWR	Switzerland
4564	Swe Fly	WV	SWV	Sweden
4573	SunExpress	XQ	SXS	Turkey
4586	Syrian Arab Airlines	RB	SYR	Syrian Arab Republic
4589	Skywalk Airlines	AL	SYX	United States
4599	Shandong Airlines	SC	CDG	China
4607	Spring Airlines	9S	CQH	China
4608	Sichuan Airlines	3U	CSC	China
4609	Shanghai Airlines	FM	CSH	China
4611	Shenzhen Airlines	ZH	CSZ	China
4619	Sun D'Or	7L	ERO	Israel
4620	SkyEurope	NE	ESK	Slovakia
4652	Spanair	JK	JKK	Spain
4687	Spirit Airlines	NK	NKS	United States
4691	SATENA	9R	NSE	Colombia
4735	Santa Barbara Airlines	S3	BBR	Venezuela
4737	Sky Airline	H2	SKU	Chile
4738	SkyWest	OO	SKW	United States
4739	Skyways Express	JZ	SKX	Sweden
4740	Skymark Airlines	BC	SKY	Japan
4750	SilkAir	MI	SLK	Singapore
4752	Surinam Airways	PY	SLM	Suriname
4776	Sterling Airlines	NB	SNB	Denmark
4781	Skynet Asia Airways	6J	SNJ	Japan
4797	Solomon Airlines	IE	SOL	Solomon Islands
4805	Saratov Aviation Division	6W	SOV	Russia
4808	Sat Airlines	HZ	SOZ	Kazakhstan
4822	Shuttle America	S5	TCF	United States
4840	Scat Air	DV	VSV	Kazakhstan
4863	TAME	EQ	TAE	Ecuador
4867	TAM Brazilian Airlines	JJ	TAM	Brazil
4869	TAP Portugal	TP	TAP	Portugal
4870	Tunisair	TU	TAR	Tunisia
4889	Thai Air Cargo	T2	TCG	Thailand
4896	Thomas Cook Airlines	FQ	TCW	Belgium
4897	Thomas Cook Airlines	MT	TCX	United Kingdom
4936	Tiger Airways	TR	TGW	Singapore
4937	Tiger Airways Australia	TT	TGW	Australia
4940	Thai Airways International	TG	THA	Thailand
4947	Thai AirAsia	FD	AIQ	Thailand
4951	Turkish Airlines	TK	THY	Turkey
4965	Twin Jet	T7	TJT	France
4981	Trans Mediterranean Airlines	TL	TMA	Lebanon
5002	Tiara Air	3P	TNM	Aruba
5013	Thomsonfly	BY	TOM	United Kingdom
5016	Tropic Air	PM	TOS	Belize
5020	TAMPA	QT	TPA	Colombia
5038	TransAsia Airways	GE	TNA	Taiwan
5039	Transavia Holland	HV	TRA	Netherlands
5041	TACV	VR	TCV	Portugal
5064	Transwest Air	9T	ABS	Canada
5067	Transaero Airlines	UN	TSO	Russia
5083	Turkmenistan Airlines	T5	TUA	Turkmenistan
5085	Tuninter	UG	TUI	Tunisia
5097	Travel Service	QS	TVS	Czech Republic
5122	TUIfly Nordic	6B	BLX	Sweden
5133	TAAG Angola Airlines	DT	DTA	Angola
5156	TAM Mercosur	PZ	LAP	Paraguay
5160	Trans States Airlines	AX	LOF	United States
5179	Tarom	RO	ROT	Romania
5187	Turan Air	3T	URN	Azerbaijan
5188	TRIP Linhas A	8R	TIB	Brazil
5207	USA3000 Airlines	U5	GWY	United States
5209	United Airlines	UA	UAL	United States
5234	Ural Airlines	U6	SVR	Russia
5251	UM Airlines	UF	UKM	Ukraine
5265	US Airways	US	USA	United States
5271	UTair Aviation	UT	UTA	Russia
5281	Uzbekistan Airways	HY	UZB	Uzbekistan
5282	Ukraine International Airlines	PS	AUI	Ukraine
5297	Valuair	VF	VLU	Singapore
5309	Vietnam Airlines	VN	HVN	Vietnam
5311	VIM Airlines	NN	MOV	Russia
5325	Volaris	Y4	VOI	Mexico
5326	Volga-Dnepr Airlines	VI	VDA	Russia
5331	Virgin America	VX	VRD	United States
5333	Virgin Express	TV	VEX	Belgium
5335	Virgin Nigeria Airways	VK	VGN	Nigeria
5347	Virgin Atlantic Airways	VS	VIR	United Kingdom
5350	Viva Macau	ZG	VVM	Macao
5351	Volare Airlines	VE	VLE	Italy
5352	Vueling Airlines	VY	VLG	Spain
5353	Vladivostok Air	XF	VLK	Russia
5354	Varig Log	LC	VLO	Brazil
5360	Virgin Australia	VA	VOZ	Australia
5368	VRG Linhas Aereas	RG	VRN	Brazil
5373	VASP	VP	VSP	Brazil
5383	VLM Airlines	VG	VLM	Belgium
5399	WebJet Linhas A	WJ	WEB	Brazil
5401	Welcome Air	2W	WLC	Austria
5416	WestJet	WS	WJA	Canada
5424	Western Airlines	WA	WAL	United States
5439	Widerøe	WF	WIF	Norway
5447	Wind Jet	IV	JET	Italy
5451	Wings Air	IW	WON	Indonesia
5461	Wizz Air	W6	WZZ	Hungary
5462	Wizz Air Hungary	8Z	WVL	Bulgaria
5465	World Airways	WO	WOA	United States
5479	XL Airways France	SE	SEU	France
5484	Xiamen Airlines	MF	CXA	China
5492	Yamal Airlines	YL	LLM	Russia
5496	Yemenia	IY	IYE	Yemen
5523	Zoom Airlines	Z4	OOM	Canada
5584	Sky Express	XW	SXR	Russia
5651	Royal Air Cambodge	VJ	RAC	Cambodia
5982	Air Busan	BX	ABL	Republic of Korea
6196	Globus	GH	GLP	Russia
6222	Air Kazakhstan	9Y	KZK	Kazakhstan
6557	Japan Air System	JD	JAS	Japan
8463	United Airways	4H	UBD	Bangladesh
8576	Fly540	5H	FFV	Kenya
8745	Transavia France	TO	TVF	France
8809	Island Air (WP)	WP	MKU	United States
9082	Uni Air	B7	UIA	Taiwan
9239	Red Wings	WZ	RWZ	Russia
9343	Felix Airways	FU	FXX	Yemen
9344	Kostromskie avialinii	K1	KOQ	Russia
9373	Greenfly	XX	GFY	Spain
9577	ELK Airways	--	ELK	Estonia
9620	Gabon Airlines	GY	GBK	Gabon
9656	Maldivo Airlines	ML	MAV	Maldives
9666	Virgin Pacific	VH	VNP	Fiji
9809	Eastar Jet	ZE	ESR	South Korea
9810	Jin Air	LJ	JNA	South Korea
9825	Baltic Air lines	B1	BA1	Latvia
9828	Ciel Canadien	YC	YCC	Canada
9829	Canadian National Airways	CN	YCP	Canada
9833	Epic Holiday	FA	4AA	United States
10114	Line Blue	L8	LBL	Germany
10123	Texas Wings	TQ	TXW	United States
10128	Dennis Sky	DH	DSY	Israel
10226	Atifly	A1	A1F	United States
10673	CanXpress	C1	CA1	Canada
10675	Sharp Airlines	SH	SHA	Australia
10683	CanXplorer	C2	CAP	Canada
10735	World Experience Airline	W1	WE1	Canada
10748	Locair	ZQ	LOC	United States
10765	SeaPort Airlines	K5	SQH	United States
10800	Star1 Airlines	V9	HCW	Lithuania
10955	MexicanaLink	I6	MXI	Mexico
10960	Island Spirit	IP	ISX	Iceland
11755	Regional Paraguaya	P7	REP	Paraguay
11811	AlMasria Universal Airlines	UJ	LMU	Egypt
11816	KoralBlue Airlines	K7	KBR	Egypt
11823	Elysian Airlines	E4	GIE	Cameroon
11834	Hellenic Imperial Airways	HT	IMP	Greece
11836	Amsterdam Airlines	WD	AAN	Netherlands
11838	Arik Niger	Q9	NAK	Niger
11840	STP Airways	8F	STP	Sao Tome and Principe
11850	Skyjet Airlines	UQ	SJU	Uganda
11857	Royal Falcon	RL	RFJ	Jordan
11873	Euroline	4L	MJX	Georgia
11948	Viking Hellas	VQ	VKH	Greece
12962	Gadair European Airlines	GP	GDR	Spain
12965	Spirit of Manila Airlines	SM	MNP	Philippines
12975	Chongqing Airlines	OQ	CQN	China
12978	West Air China	PN	CHB	China
12997	QatXpress	C3	QAX	Qatar
13076	OneChina	1C	1CH	China
13089	Joy Air	JR	JOY	China
13303	Parmiss Airlines (IPV)	PA	IPV	Iran
13304	EuropeSky	ES	EUV	Germany
13306	BRAZIL AIR	GB	BZE	Brazil
13335	Homer Air	MR	OME	Germany
13633	PanAm World Airways	WQ	PQW	United States
13690	Virginwings	YY	VWA	Germany
13704	KSY	KY	KSY	Greece
13732	Buquebus Líneas Aéreas	BQ	BQB	Uruguay
13734	SOCHI AIR	CQ	KOL	Russia
13757	Wizz Air Ukraine	WU	WAU	Ukraine
13781	88	47	VVN	Cyprus
13815	LCM AIRLINES	LQ	LMM	Russia
13947	Tom\\'s & co airliners	&T	T&O	France
13983	Azul	AD	AZU	Brazil
14061	LSM Airlines	PQ	LOO	Russia
14094	LionXpress	C4	LIX	Cameroon
14485	Fly Dubai	FZ	FDB	United Arab Emirates
14620	Domenican Airlines	D1	MDO	Dominican Republic
14849	Aereonautica militare	JY	AXZ	Italy
14881	LSM AIRLINES 	YZ	YZZ	Russia
15867	Zabaykalskii Airlines	ZP	ZZZ	Russia
15893	Marysya Airlines	M4	1QA	Russia
15975	Black Stallion Airways	BZ	BSA	United States
15984	German International Air Lines	GM	GER	Germany
15985	TrasBrasil	TB	TBZ	Brazil
15989	TransBrasil Airlines	TH	THS	Brazil
16103	Air Mekong	P8	MKG	Vietnam
16116	Air Hamburg (AHO)	HH	AHO	Germany
16120	ZABAIKAL AIRLINES	Z6	ZTT	Russia
16127	TransHolding	TI	THI	Brazil
16139	Serbian Airlines	S1	SA1	Serbia
16150	TransHolding System	YO	TYS	Brazil
16151	CCML Airlines	CB	CCC	Colombia
16234	Fly Brasil	F1	FBL	Brazil
16261	CB Airways UK ( Interliging Flights )	1F	CIF	United Kingdom
16262	Fly Colombia ( Interliging Flights )	3F	3FF	Colombia
16264	Trans Pas Air	T6	TP6	United States
16323	Himalayan Airlines	HC	HYM	Nepal
16327	Indya Airline Group	G1	IG1	India
16359	Japan Regio	ZX	ZXY	Japan
16459	Sky Regional	RS	SKV	Canada
16507	LSM International 	II	UWW	Russia
16508	Baikotovitchestrian Airlines 	BU	BUU	American Samoa
16511	Luchsh Airlines 	L4	LJJ	Russia
16615	Mongolian International Air Lines 	7M	ZTF	Mongolia
16624	Tway Airlines	TW	TWB	South Korea
16628	Jusur airways	JX	JSR	Egypt
16645	NEXT Brasil	XB	NXB	Brazil
16660	AeroWorld 	W4	WER	Russia
16702	Usa Sky Cargo	E1	ES2	United States
16707	Hankook Airline	HN	HNX	South Korea
16725	Marusya Airways	Y8	MRS	Russia
16726	Era Alaska	7H	ERR	United States
16728	AirRussia	R8	RRJ	Russia
16735	Hankook Air US	H1	HA1	United States
16796	I-Fly	H5	RSY	Russia
16837	VickJet	KT	VKJ	France
16860	Salsa d\\'Haiti	SO	SLC	Haiti
16901	12 North	12	N12	India
16942	Mauritania Airlines International	L6	MAI	Mauritania
16956	MAT Airways	6F	MKD	Macedonia
16960	Asian Wings Airways	AW	AWM	Burma
16963	Air Arabia Egypt	E5	RBG	Egypt
17022	Orchid Airlines	OI	ORC	Australia
17023	Asia Wings	Y5	AWA	Kazakhstan
17083	Nile Air	NP	NIA	Egypt
17094	Senegal Airlines	DN	SGG	Senegal
17115	Copenhagen Express	0X	CX0	Denmark
17408	BusinessAir	8B	BCC	Thailand
17571	Sky Wing Pacific	C7	CR7	South Korea
17574	Air Indus	PP	AI0	Pakistan
17750	Aviabus	U1	ABI	Russia
17780	Michael Airlines	DF	MJG	Puerto Rico
17786	Korongo Airlines	ZC	KGO	Congo (Kinshasa)
17794	Indonesia Sky	I5	IDS	Indonesia
17841	Aws express	B0	666	United States
17859	Southjet	76	SJS	United States
17860	Southjet connect	77	ZCS	United States
17862	Southjet cargo	78	XAN	United States
17881	Iberia Express	I2	IBS	Spain
17890	Nordic Global Airlines	NJ	NGB	Finland
17891	Scoot	TZ	SCO	Singapore
17935	Zenith International Airline	ZN	ZNA	Thailand
17936	Orbit Airlines Azerbaijan	O1	OAB	Azerbaijan
18178	Vision Airlines (V2)	V2	RBY	United States
18239	Yellowtail	YE	YEL	United States
18241	Royal Airways	KG	RAW	United States
18252	FlyHigh Airlines Ireland (FH)	FH	FHI	Ireland
18529	T.J. Air	TJ	TJA	United States
18700	SOCHI AIR CHATER	Q3	QER	Russia
18732	Malindo Air	OD	MXD	Malaysia
18930	Maryland Air	M1	M1F	United States
18946	VivaColombia	5Z	VVC	Colombia
19016	Apache Air	ZM	IWA	United States
19030	Jettor Airlines	NR	JTO	Hong Kong
19287	National Air Cargo	N8	NCR	United States
19290	Eastern Atlantic Virtual Airlines	13	EAV	United States
19361	Snowbird Airlines	S8	SBD	Finland
19367	Kharkiv Airlines	KH	KHK	Ukraine
19433	XAIR USA	XA	XAU	United States
19473	XPTO	XP	XPT	Portugal
19582	Air Serbia	JU	ASL	Serbia
19610	Air Lituanica	LT	LTU	Lithuania
19674	Rainbow Air (RAI)	RN	RAB	United States
19675	Rainbow Air Canada	RY	RAY	Canada
19676	Rainbow Air Polynesia	RX	RPO	United States
19677	Rainbow Air Euro	RU	RUE	United Kingdom
19678	Rainbow Air US	RM	RNY	United States
19751	Dobrolet	QD	DOB	Russia
19774	Spike Airlines	S0	SAL	United States
19803	All Argentina	L1	AL1	Argentina
19804	All America	A2	AL2	United States
19805	All Asia	L9	AL3	China
19806	All Africa	9A	99F	South Africa
19807	Regionalia México	N4	J88	Mexico
19808	All Europe	N9	N99	United Kingdom
19809	All Spain	N7	N77	Spain
19810	Regional Air Iceland	9N	N78	Iceland
19812	Voestar	8K	K88	Brazil
19813	All Colombia	7O	7KK	Colombia
19814	Regionalia Uruguay	2X	2K2	Uruguay
19815	Regionalia Venezuela	9X	9XX	Venezuela
19827	Regionalia Chile	9J	CR1	Chile
19828	Vuela Cuba	6C	6CC	Cuba
19830	All Australia	88	8K8	Australia
19831	Fly Europa	ER	RWW	Spain
19834	FlyPortugal	PO	FPT	Portugal
19886	Spring Airlines Japan	IJ	SJO	Japan
19890	Dense Airways	KP	DWA	United States
19891	Dense Connection	KZ	DC2	United States
19908	Vuola Italia	4S	VI4	Italy
19928	All Argentina Express	Z0	Z9H	Argentina
19970	All America AR	2R	M7A	Argentina
19971	All America CL	1R	R1R	Chile
19974	SOCHI AIR EXPRESS	Q4	SAE	Russia
19977	All America BR	1Y	A9B	Brazil
20004	Volotea Costa Rica	9V	VC9	Costa Rica
20017	Fly Romania	X5	OTJ	Romania
20073	All America CO	0Y	7ZC	Colombia
20074	All America MX	0M	0MM	Mexico
20110	FOX Linhas Aereas	FX	FOX	Brazil
20144	Via Conectia Airlines	6V	CZV	Uruguay
20160	City Airways	E8	GTA	Thailand
20170	Norwegian Long Haul AS	DU	NLH	Norway
20207	TransNusa Air	M8	TNU	Indonesia
20218	Tomp Airlines	ZT	T9P	Chile
20224	Global Airlines	0G	GA0	Argentina
20264	Air Vistara	UK	VTI	India
20268	TransRussiaAirlines	1E	RGG	Russia
20282	REXAIR VIRTUEL	RR	RXR	France
20285	WestJet Encore	WR	WEN	Canada
20286	Air Pegasus	OP	PPL	India
20288	International Europe	9I	INE	Spain
20401	V Air	ZV	VAX	Taiwan
20565	Boutique Air (Priv)	4B	BTQ	United States
20577	VOLOTEA Airways	V7	VOE	Spain
20599	INAVIA Internacional	Z5	IIR	Argentina
20607	Liberty Airways	LE	LTY	United States
20657	Bassaka airlines	5B	BSX	Cambodia
20769	VIA Líneas Aéreas	V1	VIA	Argentina
20802	GermanXL	GX	GXG	Germany
20827	Fly France	FF	FRF	France
20881	Europe Jet	EX	EU9	France
20976	World Scale Airlines	W3	WSS	United States
20978	All America US	AG	SSA	United States
20995	BudgetAir	1K	BG1	Germany
21012	Fly One	F5	FI5	Moldova
21131	All America BOPY	0P	PYB	Paraguay
21317	Svyaz Rossiya	7R	SJM	Russia
\.


COPY kraje(kod_iso, nazwa, czy_w_schengen) from stdin;
AW	Aruba	false
AG	Antigua and Barbuda	false
AE	United Arab Emirates	false
AF	Afghanistan	false
DZ	Algeria	false
AZ	Azerbaijan	false
AL	Albania	false
AM	Armenia	false
AO	Angola	false
AS	American Samoa	false
AR	Argentina	false
AU	Australia	false
AT	Austria	true
AI	Anguilla	false
AQ	Antarctica	false
BH	Bahrain	false
BB	Barbados	false
BW	Botswana	false
BM	Bermuda	false
BE	Belgium	true
BS	Bahamas	false
BD	Bangladesh	false
BZ	Belize	false
BA	Bosnia and Herzegovina	false
BO	Bolivia	false
MM	Burma	false
BJ	Benin	false
BY	Belarus	false
SB	Solomon Islands	false
BR	Brazil	false
BT	Bhutan	false
BG	Bulgaria	true
BN	Brunei	false
BI	Burundi	false
CA	Canada	false
KH	Cambodia	false
TD	Chad	false
LK	Sri Lanka	false
CD	Congo (Kinshasa)	false
CG	Congo (Brazzaville)	false
CN	China	false
CL	Chile	false
KY	Cayman Islands	false
CC	Cocos (Keeling) Islands	false
CM	Cameroon	false
KM	Comoros	false
CO	Colombia	false
MP	Northern Mariana Islands	false
CR	Costa Rica	false
CF	Central African Republic	false
CU	Cuba	false
CV	Cape Verde	false
CK	Cook Islands	false
CY	Cyprus	true
DK	Denmark	true
DJ	Djibouti	false
DM	Dominica	false
DO	Dominican Republic	false
EC	Ecuador	false
EG	Egypt	false
IE	Ireland	true
GQ	Equatorial Guinea	false
EE	Estonia	true
ER	Eritrea	false
SV	El Salvador	false
ET	Ethiopia	false
CZ	Czech Republic	true
GF	French Guiana	false
FI	Finland	true
FJ	Fiji	false
FK	Falkland Islands	false
FM	Micronesia	false
FO	Faroe Islands	false
PF	French Polynesia	false
FR	France	true
GM	Gambia	false
GA	Gabon	false
GE	Georgia	false
GH	Ghana	false
GI	Gibraltar	false
GD	Grenada	false
GG	Guernsey	false
GL	Greenland	false
DE	Germany	true
GP	Guadeloupe	false
GU	Guam	false
GR	Greece	false
GT	Guatemala	false
GN	Guinea	false
GY	Guyana	false
HT	Haiti	false
HK	Hong Kong	false
HN	Honduras	false
HR	Croatia	true
HU	Hungary	true
IS	Iceland	true
ID	Indonesia	false
IM	Isle of Man	false
IN	India	false
IO	British Indian Ocean Territory	false
IR	Iran	false
IL	Israel	false
IT	Italy	true
IV	Ivory Coast	false
IQ	Iraq	false
JP	Japan	false
JE	Jersey	false
JM	Jamaica	false
JO	Jordan	false
KE	Kenya	false
KG	Kyrgyzstan	false
KP	North Korea	false
KI	Kiribati	false
KR	South Korea	false
CX	Christmas Island	false
KW	Kuwait	false
KZ	Kazakhstan	false
LA	Laos	false
LB	Lebanon	false
LV	Latvia	true
LT	Lithuania	true
LR	Liberia	false
SK	Slovakia	true
LS	Lesotho	false
LU	Luxembourg	true
LY	Libya	false
MG	Madagascar	false
MQ	Martinique	false
MO	Macau	false
MD	Moldova	false
YT	Mayotte	false
MN	Mongolia	false
MS	Montserrat	false
MW	Malawi	false
ME	Montenegro	false
MK	Macedonia	false
ML	Mali	false
MC	Monaco	false
MA	Morocco	false
MU	Mauritius	false
MR	Mauritania	false
MT	Malta	true
OM	Oman	false
MV	Maldives	false
MX	Mexico	false
MY	Malaysia	false
MZ	Mozambique	false
NC	New Caledonia	false
NU	Niue	false
NF	Norfolk Island	false
NE	Niger	false
VU	Vanuatu	false
NG	Nigeria	false
NL	Netherlands	true
NO	Norway	true
NP	Nepal	false
NR	Nauru	false
SR	Suriname	false
AN	Netherlands Antilles	false
NI	Nicaragua	false
NZ	New Zealand	false
PY	Paraguay	false
PE	Peru	false
PK	Pakistan	false
PL	Poland	true
PA	Panama	false
PT	Portugal	true
PG	Papua New Guinea	false
PW	Palau	false
GW	Guinea-Bissau	false
QA	Qatar	false
RS	Serbia	false
MH	Marshall Islands	false
RO	Romania	true
PH	Philippines	false
PR	Puerto Rico	false
RU	Russia	false
RW	Rwanda	false
SA	Saudi Arabia	false
PM	Saint Pierre and Miquelon	false
KN	Saint Kitts and Nevis	false
SC	Seychelles	false
ZA	South Africa	false
SN	Senegal	false
SH	Saint Helena	false
SI	Slovenia	true
SL	Sierra Leone	false
SG	Singapore	false
SO	Somalia	false
ES	Spain	true
SS	South Sudan	false
LC	Saint Lucia	false
SD	Sudan	false
SE	Sweden	true
SY	Syria	false
CH	Switzerland	true
TT	Trinidad and Tobago	false
TH	Thailand	false
TJ	Tajikistan	false
TC	Turks and Caicos Islands	false
TK	Tokelau	false
TO	Tonga	false
TG	Togo	false
TN	Tunisia	false
TL	Timor-Leste	false
TR	Turkey	false
TV	Tuvalu	false
TW	Taiwan	false
TM	Turkmenistan	false
TZ	Tanzania	false
UG	Uganda	false
GB	United Kingdom	false
UA	Ukraine	false
US	United States	false
BF	Burkina Faso	false
UY	Uruguay	false
UZ	Uzbekistan	false
VC	Saint Vincent and the Grenadines	false
VE	Venezuela	false
VG	British Virgin Islands	false
VN	Vietnam	false
WF	Wallis and Futuna	false
EH	Western Sahara	false
WS	Samoa	false
SZ	Swaziland	false
YE	Yemen	false
ZM	Zambia	false
ZW	Zimbabwe	false
\.


alter table linie_lotnicze add column kraj varchar(2);
update linie_lotnicze set kraj = (select kod_iso from kraje where nazwa_kraju=nazwa);
delete from linie_lotnicze where kraj is null;
alter table linie_lotnicze add foreign key (kraj) references kraje;
alter table linie_lotnicze drop column nazwa_kraju;
--funkcja spr czy dwom osobom niezostalo przyznane jedno miejsce

--funkcja wypisz kortke podróż bagażu np KRK->WAW->BAR->VIE
