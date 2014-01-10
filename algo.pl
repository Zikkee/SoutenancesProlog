choisirBinomeNd(ListeBinomes, ID):- random_member(ID, ListeBinomes).

choisirDisponibiliteNd(ListeDisponibilites, ID, DATE, HEURE, SALLE):-random_member([ID, DATE, HEURE, SALLE], ListeDisponibilites).

lancerAlgorithme(R):- lancerMiseEnFormePredicatsDispo(ListeDisponibilites),
	obtenirListeBinome([],ListeBinomes),
	algorithme(ListeDisponibilites, ListeBinomes,[], R),!.

verifierDisponibiliteCreneau(DATE, HEURE, SALLE, ListeDisponibilites):-member([_, DATE, HEURE, SALLE], ListeDisponibilites).

verifierDisponibiliteBinome(ID, ListeBinomes):-member(ID, ListeBinomes).


algorithme(ListeDisponibilites, ListeBinomes, ListeAttribution, ListeResultat):- ListeBinomes \= [],
	choisirBinomeNd(ListeBinomes, ID),
	choisirDisponibiliteNd(ListeDisponibilites, ID, DATE, HEURE, SALLE),
	delete(ListeDisponibilites,[ID, DATE, HEURE, SALLE], ListeDisponibilites2),
	delete(ListeBinomes,ID, ListeBinomes2),
	algorithme(ListeDisponibilites2, ListeBinomes2, [[ID, DATE, HEURE, SALLE]|ListeAttribution], ListeResultat).

algorithme(_, [], ListeAttribution, ListeAttribution).
