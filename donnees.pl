binome(2,[gjb,jpg]).
binome(5,[jm,pl]).
binome(7,[jpg,pl]).

incompatibilite(L1, L2):- \+ intersection(L1,L2,[]).

seance(2,2013-12-04, 9, 4).

lireFichierJurys(FICHIER, R):-csv_read_file(FICHIER, R),
	creerPredicatsJurys(R).

lireFichierBinomes(FICHIER, R):- csv_read_file(FICHIER, R),
	creerPredicatsBinomes(R).

creerPredicatsJurys([X|Y]):-[X|Y]\= [],
	asserta(X),
	creerPredicatsJurys(Y).

creerPredicatsJurys([]).

creerPredicatsBinomes([X|Y]):- [X|Y]\= [],
	asserta(X),
	creerPredicatsBinomes(Y).

creerPredicatsBinomes([]).

lancerMiseEnFormeBinomes([ID|R]):-row(ID, _),
	mettreEnFormePredicatsBinomes([], R, ID).

mettreEnFormePredicatsBinomes(L, R, ID):- row(ID, NOM),
	\+ member(NOM, L),
	L1 = [NOM|L],
	!,
	mettreEnFormePredicatsBinomes(L1, R, ID),
	!.

mettreEnFormePredicatsBinomes([X|Y], [X|Y], ID):- \+ row(ID, _).

mettreEnFormePredicatsBinomes(L, L, ID):- row(ID, NOM),
	!,
	member(NOM,L).

lancerMiseEnFormePredicatsDispo(ListeResultat):-mettreEnFormePredicatsDispo([], ListeResultat),
	!.

mettreEnFormePredicatsDispo(ListeEntree, ListeResultat):-row(ID, DATE, HEURE, SALLE),
	L1 = [ID, DATE, HEURE, SALLE],
	\+ member(L1, ListeEntree),
	mettreEnFormePredicatsDispo([L1|ListeEntree], ListeResultat).

mettreEnFormePredicatsDispo(ListeEntree, ListeEntree):-row(ID, DATE, HEURE, SALLE),
	member([ID, DATE, HEURE, SALLE], ListeEntree).

obtenirListeBinome(ListeEntree, ListeResultat):-row(ID, _),
	\+ member(ID, ListeEntree),
	obtenirListeBinome([ID|ListeEntree], ListeResultat).

obtenirListeBinome(ListeEntree, ListeEntree):-row(ID, _),
	member(ID, ListeEntree).
