choisirBinomeNd(ListeBinomes, [ID|X]):- random_member([ID|X], ListeBinomes).

choisirDisponibiliteNd(ListeDisponibilites, ID, DATE, HEURE, SALLE):- member([ID, DATE, HEURE, SALLE], ListeDisponibilites).

preparerAlgorithme(_):-lireFichier('./solveur_jurys_test.tsv'),
	lireFichier('./solveur_disponibilites_test.tsv').

lancerAlgorithme(R):-
	lancerMiseEnFormePredicatsDispo(ListeDisponibilites),
	obtenirListeBinome([],ListeBinomes),
	algorithme(ListeDisponibilites, ListeBinomes,[], R),!.

verifierDisponibiliteCreneau(DATE, HEURE, SALLE, ListeDisponibilites):-member([_, DATE, HEURE, SALLE], ListeDisponibilites).

verifierDisponibiliteBinome(ID, ListeBinomes):-member(ID, ListeBinomes).

algorithme(ListeDisponibilites, ListeBinomes, ListeAttribution, ListeResultat):- ListeBinomes \= [],
	choisirBinomeNd(ListeBinomes, [ID|Enseignants]),
	choisirDisponibiliteNd(ListeDisponibilites, ID, DATE, HEURE, SALLE),
	delete(ListeDisponibilites,[ID, DATE, HEURE, SALLE], ListeDisponibilites2),
	delete(ListeBinomes,[ID|_], ListeBinomes2),
	supprimerDisponibilitesBinomesConcurrents([ID|Enseignants], ListeBinomes2, ListeDisponibilites2, DATE, HEURE, ListeDisponibilitesResultat),
	algorithme(ListeDisponibilitesResultat, ListeBinomes2, [[ID, DATE, HEURE, SALLE]|ListeAttribution], ListeResultat).

algorithme(_, [], ListeAttribution, ListeAttribution).

% Supprime les disponibilités d'un binôme concurrent au binôme ID (pour
% pas qu'un binôme concurrent prenne un créneau à la même heure)
% -> Cherche les binomes concurrents
% -> Supprime les disponibilités du binome concurrent
supprimerDisponibilitesBinomesConcurrents([ID|Enseignants], ListeBinomes, ListeDisponibilites, DATE, HEURE, ListeDisponibilitesResultat):- obtenirBinomesConcurrents([ID|Enseignants], ListeBinomes, [], ListeConcurrents),
	supprimerDisponibilitesBinomes(ListeConcurrents, ListeDisponibilites, DATE, HEURE, ListeDisponibilitesResultat).


supprimerDisponibilitesBinomes(ListeBinomes, ListeDisponibilites, DATE, HEURE, ListeDisponibilitesResultat):-member(X, ListeBinomes),
	delete(ListeDisponibilites, [X, DATE, HEURE, _], ListeDisponibilites2),
	delete(ListeBinomes, X, ListeBinomes2),
	supprimerDisponibilitesBinomes(ListeBinomes2, ListeDisponibilites2, DATE, HEURE, ListeDisponibilitesResultat).

supprimerDisponibilitesBinomes([], ListeDisponibilites, _, _, ListeDisponibilites).

