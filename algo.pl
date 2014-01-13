choisirBinomeNd([[ID, NombreDisponibilites | Y]|Z], _, ChoixFinal, MIN):-[[ID, NombreDisponibilites | Y]|Z] \= [],
	NombreDisponibilites < MIN,
	choisirBinomeNd(Z, [ID, NombreDisponibilites | Y], ChoixFinal, NombreDisponibilites).

choisirBinomeNd([[ID, NombreDisponibilites | Y]|Z], _, ChoixFinal, MIN):-[[ID, NombreDisponibilites | Y]|Z] \= [],
	MIN == -1,
	choisirBinomeNd(Z, [ID, NombreDisponibilites | Y], ChoixFinal, NombreDisponibilites).

choisirBinomeNd([[_, NombreDisponibilites | _]|Z], ChoixCourant, ChoixFinal, MIN):-[[_, NombreDisponibilites | _]|Z] \= [],
	NombreDisponibilites >= MIN,
	MIN \= -1,
	choisirBinomeNd(Z, ChoixCourant, ChoixFinal, MIN).

choisirBinomeNd([], ChoixCourant, ChoixCourant, _).

diminuerNombreDisponibilitesBinome(IDBinome, [[ID, NombreDisponibilites | Y]|Z], Valeur, [[ID, 0 | Y]|Z]):-ID == IDBinome,
	NombreDisponibilites2 is NombreDisponibilites - Valeur,
	NombreDisponibilites2 < 0.

diminuerNombreDisponibilitesBinome(IDBinome, [[ID, NombreDisponibilites | Y]|Z], Valeur, [[ID, NombreDisponibilites2 | Y]|Z]):-ID == IDBinome,
	NombreDisponibilites2 is NombreDisponibilites - Valeur,
	NombreDisponibilites2 >=0.


diminuerNombreDisponibilitesBinome(IDBinome, [[ID|Y]|Z], Valeur, [[ID|Y]|Resultat]):-ID \= IDBinome,
	diminuerNombreDisponibilitesBinome(IDBinome, Z, Valeur, Resultat).

diminuerNombreDisponibilitesBinome(_, [], _, _):- false.




choisirDisponibiliteNd(ListeDisponibilites, ID, DATE, HEURE, SALLE):- member([ID, DATE, HEURE, SALLE], ListeDisponibilites).

preparerAlgorithme(ListeCompte):-lireFichier('./solveur_jurys.tsv'),
	lireFichier('./solveur_disponibilites.tsv'),
	initialiserListeCompteDisponibilites(ListeCompte).

lancerAlgorithme(R):-
	lancerMiseEnFormePredicatsDispo(ListeDisponibilites),
	obtenirListeBinome([],ListeBinomes),
	algorithme(ListeDisponibilites, ListeBinomes,[], R),!.

verifierDisponibiliteCreneau(DATE, HEURE, SALLE, ListeDisponibilites):-member([_, DATE, HEURE, SALLE], ListeDisponibilites).

verifierDisponibiliteBinome(ID, ListeBinomes):-member(ID, ListeBinomes).

algorithme(ListeDisponibilites, ListeBinomes, ListeAttribution, ListeResultat):- ListeBinomes \= [],
	choisirBinomeNd(ListeBinomes, _, [ID|Enseignants], -1),
	choisirDisponibiliteNd(ListeDisponibilites, ID, DATE, HEURE, SALLE),
	delete(ListeDisponibilites,[ID, DATE, HEURE, SALLE], ListeDisponibilites2),
	delete(ListeBinomes,[ID|_], ListeBinomes2),
	supprimerDisponibilitesBinomesConcurrents([ID|Enseignants], ListeBinomes2, ListeDisponibilites2, DATE, HEURE, ListeDisponibilites3, ListeBinomes3),
	verifierExistenceDisponibilites(ListeBinomes3, ListeDisponibilites3),
	algorithme(ListeDisponibilites3, ListeBinomes3, [[ID, DATE, HEURE, SALLE]|ListeAttribution], ListeResultat).

algorithme(_, [], ListeAttribution, ListeAttribution).

% Supprime les disponibilités d'un binôme concurrent au binôme ID (pour
% pas qu'un binôme concurrent prenne un créneau à la même heure)
% -> Cherche les binomes concurrents
% -> Supprime les disponibilités du binome concurrent
supprimerDisponibilitesBinomesConcurrents([ID|Enseignants], ListeBinomes, ListeDisponibilites, DATE, HEURE, ListeDisponibilitesResultat, ListeBinomesResultat):- supprimerDisponibilitesBinomes([ID|Enseignants], ListeBinomes, ListeDisponibilites, DATE, HEURE, ListeDisponibilitesResultat, ListeBinomesResultat).


supprimerDisponibilitesBinomes(Binome, [[ID, NombreDisponibilites|Enseignants]|Z], ListeDisponibilites, DATE, HEURE, ListeDisponibilitesResultat, [[ID,NombreDisponibilites2|Enseignants]|ListeBinomeResultat]):-incompatibilite(Binome, [ID|Enseignants]),
	length(ListeDisponibilites, TailleAvant),
	delete(ListeDisponibilites, [ID, DATE, HEURE, _], ListeDisponibilites2),
	length(ListeDisponibilites2, TailleApres),
	NombreSuppression is TailleAvant - TailleApres,
	NombreSuppression > 0,
	NombreDisponibilites2 is NombreDisponibilites - NombreSuppression,
	NombreDisponibilites2 >= 0,
	supprimerDisponibilitesBinomes(Binome, Z, ListeDisponibilites2, DATE, HEURE, ListeDisponibilitesResultat, ListeBinomeResultat).

supprimerDisponibilitesBinomes(Binome, [[ID, NombreDisponibilites|Enseignants]|Z], ListeDisponibilites, DATE, HEURE, ListeDisponibilitesResultat, [[ID,0|Enseignants]|ListeBinomeResultat]):-incompatibilite(Binome, [ID|Enseignants]),
	length(ListeDisponibilites, TailleAvant),
	delete(ListeDisponibilites, [ID, DATE, HEURE, _], ListeDisponibilites2),
	length(ListeDisponibilites2, TailleApres),
	NombreSuppression is TailleAvant - TailleApres,
	NombreSuppression > 0,
	NombreDisponibilites2 is NombreDisponibilites - NombreSuppression,
	NombreDisponibilites2 < 0,
	supprimerDisponibilitesBinomes(Binome, Z, ListeDisponibilites2, DATE, HEURE, ListeDisponibilitesResultat, ListeBinomeResultat).

supprimerDisponibilitesBinomes(Binome, [[ID, NombreDisponibilites|Enseignants]|Z], ListeDisponibilites, DATE, HEURE, ListeDisponibilitesResultat, [[ID,NombreDisponibilites|Enseignants]|ListeBinomeResultat]):-incompatibilite(Binome, [ID|Enseignants]),
	length(ListeDisponibilites, TailleAvant),
	delete(ListeDisponibilites, [ID, DATE, HEURE, _], ListeDisponibilites2),
	length(ListeDisponibilites2, TailleApres),
	NombreSuppression is TailleAvant - TailleApres,
	NombreSuppression =< 0,
	supprimerDisponibilitesBinomes(Binome, Z, ListeDisponibilites2, DATE, HEURE, ListeDisponibilitesResultat, ListeBinomeResultat).

supprimerDisponibilitesBinomes(Binome, [[ID, NombreDisponibilites|Enseignants]|Z], ListeDisponibilites, DATE, HEURE, ListeDisponibilitesResultat, [[ID,NombreDisponibilites|Enseignants]|ListeBinomeResultat]):- \+ incompatibilite(Binome, [ID|Enseignants]),
	supprimerDisponibilitesBinomes(Binome, Z, ListeDisponibilites, DATE, HEURE, ListeDisponibilitesResultat, ListeBinomeResultat).

supprimerDisponibilitesBinomes(_, [], ListeDisponibilites, _, _, ListeDisponibilites, []).

verifierExistenceDisponibilites([[X|_]|Y], ListeDisponibilites):- member([X|_], ListeDisponibilites),
	!, % Evite a member de renvoyer faux si on lui repose la question
	verifierExistenceDisponibilites(Y, ListeDisponibilites).
verifierExistenceDisponibilites([], _).

verifierExistenceDisponibilites([[X|_]|8], ListeDisponibilites):- \+ member([X|_], ListeDisponibilites),
	false.

initialiserListeCompteDisponibilites(R):- findall(ID, row(ID,_),ListeID),
	obtenirListeIDBinomes(ListeID, [], ListeIDSansDoublons), % Supprime les doublons de la liste
	remplirListeCompteDisponibilites([], ListeIDSansDoublons, R).

obtenirListeIDBinomes([X|Y], ListeEntree, ListeResultat):- member(X,ListeEntree),
	!,
	obtenirListeIDBinomes(Y, ListeEntree, ListeResultat).

obtenirListeIDBinomes([X|Y], ListeEntree, ListeResultat):- \+ member(X,ListeEntree),
	obtenirListeIDBinomes(Y, [X|ListeEntree], ListeResultat).

obtenirListeIDBinomes([], ListeEntree, ListeEntree).


remplirListeCompteDisponibilites(ListeEntree, [X|Y], ListeSortie):- findall(X, row(X, _, _, _), ListeDispo),
	!,
	length(ListeDispo, S),
	remplirListeCompteDisponibilites([[X,S]|ListeEntree], Y, ListeSortie).

remplirListeCompteDisponibilites(ListeEntree, [], ListeEntree).

