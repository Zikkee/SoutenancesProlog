choisirBinomeNd(ListeBinomes, ID):- random_member(ID, ListeBinomes).

choisirDisponibiliteNd(ListeDisponibilites, ID, DATE, HEURE, SALLE):- member([ID, DATE, HEURE, SALLE], ListeDisponibilites).

lancerAlgorithme(R):- lireFichier('./solveur_jurys_test.tsv'),
	lireFichier('./solveur_disponibilites_test.tsv'),
	lancerMiseEnFormePredicatsDispo(ListeDisponibilites),
	obtenirListeBinome([],ListeBinomes),
	algorithme(ListeDisponibilites, ListeBinomes,[], R),!.

verifierDisponibiliteCreneau(DATE, HEURE, SALLE, ListeDisponibilites):-member([_, DATE, HEURE, SALLE], ListeDisponibilites).

verifierDisponibiliteBinome(ID, ListeBinomes):-member(ID, ListeBinomes).

algorithme(ListeDisponibilites, ListeBinomes, ListeAttribution, ListeResultat):- ListeBinomes \= [],
	choisirBinomeNd(ListeBinomes, ID),
	choisirDisponibiliteNd(ListeDisponibilites, ID, DATE, HEURE, SALLE),
	delete(ListeDisponibilites,[ID, DATE, HEURE, SALLE], ListeDisponibilites2),
	delete(ListeBinomes,ID, ListeBinomes2),
	algorithme(ListeDisponibilites3, ListeBinomes2, [[ID, DATE, HEURE, SALLE]|ListeAttribution], ListeResultat).

algorithme(_, [], ListeAttribution, ListeAttribution).

supprimerDisponibilitesBinomesConcurrents(ID, ListeDisponibilites, DATE, HEURE, ListeDisponibilitesResultat):-trouverLesBinomesConcurrents(ID, ListeConcurrents),
	supprimerDisponibilitesBinomes(ListeConcurrents, ListeDisponibilites, DATE, HEURE, ListeDisponibilitesResultat).

supprimerDisponibilitesBinomes(ListeBinomes, ListeDisponibilites, DATE, HEURE, ListeDisponibilitesResultat):-member([X|Y], ListeBinomes),
	delete(ListeDisponibilites, [X, DATE, HEURE, _], ListeDisponibilites2),
	delete(ListeBinomes, [X|Y], ListeBinomes2),
	supprimerDisponibilitesBinomes(ListeBinomes2, ListeDisponibilites2, DATE, HEURE, ListeDisponibilitesResultat).

supprimerDisponibilitesBinomes([], ListeDisponibilites, _, _, ListeDisponibilites).



trouverLesBinomesConcurrents(ID, R):- trouverTousLesAutresBinomes(ID, ListeEnseignantsAutresBinomes),
	findall(Enseignant, row(ID, Enseignant), ListeEnseignantsBinome),
	chercherConcurrents([ID|ListeEnseignantsBinome], ListeEnseignantsAutresBinomes, [], R).

chercherConcurrents(ListeEnseignantsBinome, ListeEnseignantsAutresBinomes, ListeEntree, ListeResultat):- member(AutresEnseignants, ListeEnseignantsAutresBinomes),
	delete(ListeEnseignantsAutresBinomes, AutresEnseignants, L2),
	incompatibilite(AutresEnseignants, ListeEnseignantsBinome),
	chercherConcurrents(ListeEnseignantsBinome, L2, [AutresEnseignants|ListeEntree], ListeResultat).

chercherConcurrents(ListeEnseignantsBinome, ListeEnseignantsAutresBinomes,ListeEntree, ListeResultat):- member(AutresEnseignants, ListeEnseignantsAutresBinomes),
	delete(ListeEnseignantsAutresBinomes, AutresEnseignants, L2),

	\+ incompatibilite(ListeEnseignantsBinome, ListeEnseignantsAutresBinomes),
	chercherConcurrents(ListeEnseignantsBinome, L2, ListeEntree, ListeResultat).

chercherConcurrents(_, [], ListeEntree, ListeEntree).


trouverTousLesAutresBinomes(ID, ListeEnseignants):-obtenirListeBinome([], ListeBinomes),
	delete(ListeBinomes, ID, ListeBinomes2),
	trouverLesEnseignantsDesBinomes(ListeBinomes2, [], ListeEnseignants).

trouverLesEnseignantsDesBinomes(ListeBinomes, ListeEntree, ListeResultat):-
	member(X, ListeBinomes),
	findall(Enseignant, row(X, Enseignant),L),
	delete(ListeBinomes, X, ListeBinomes2),
	trouverLesEnseignantsDesBinomes(ListeBinomes2, [[X|L]|ListeEntree], ListeResultat).

trouverLesEnseignantsDesBinomes([], ListeEntree, ListeEntree).


