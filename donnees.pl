incompatibilite(L1, L2):- \+ intersection(L1,L2,[]).

seance(2,2013-12-04, 9, 4).

lireFichier(FICHIER):-csv_read_file(FICHIER, R),
	creerPredicats(R).

creerPredicats([X|Y]):-[X|Y]\= [],
	asserta(X),
	creerPredicats(Y).

creerPredicats([]).

lancerMiseEnFormePredicatsDispo(ListeResultat):-mettreEnFormePredicatsDispo([], ListeResultat),
	!.

mettreEnFormePredicatsDispo(ListeEntree, ListeResultat):-row(ID, DATE, HEURE, SALLE),
	L1 = [ID, DATE, HEURE, SALLE],
	\+ member(L1, ListeEntree),
	mettreEnFormePredicatsDispo([L1|ListeEntree], ListeResultat).

mettreEnFormePredicatsDispo(ListeEntree, ListeEntree):-row(ID, DATE, HEURE, SALLE),
	member([ID, DATE, HEURE, SALLE], ListeEntree).

obtenirListeBinome(ListeEntree, ListeResultat):-row(ID, _),
	\+ member([ID|_], ListeEntree),
	findall(Enseignant, row(ID, Enseignant), ListeEnseignants),
	obtenirCompteDisponibilitesBinome(ID, NombreDisponibilites),
	obtenirListeBinome([[ID,NombreDisponibilites|ListeEnseignants]|ListeEntree], ListeResultat),!.

obtenirListeBinome(ListeEntree, ListeEntree):-row(ID, _),
	member([ID|_], ListeEntree).

obtenirCompteDisponibilitesBinome(ID, NombreDisponibilites):-findall(ID, row(ID, _, _, _), ListeDisponibilites),
	length(ListeDisponibilites, NombreDisponibilites).

obtenirBinomesConcurrents([ID|X], [[A|_]|Y], ListeEntree, ListeSortie):-ID == A,
	obtenirBinomesConcurrents([ID|X], Y, ListeEntree, ListeSortie).

obtenirBinomesConcurrents([ID|X], [[A|B]|Y], ListeEntree, ListeSortie):-ID \= A,
	incompatibilite([A|B], [ID|X]),
	obtenirBinomesConcurrents([ID|X], Y, [A|ListeEntree], ListeSortie).


obtenirBinomesConcurrents([ID|X], [[A|B]|Y], ListeEntree, ListeSortie):-ID \= A,
	\+ incompatibilite([A|B], [ID|X]),
	obtenirBinomesConcurrents([ID|X], Y, ListeEntree, ListeSortie).

obtenirBinomesConcurrents(_, [], ListeEntree, ListeEntree).
