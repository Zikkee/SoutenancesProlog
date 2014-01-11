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
	supprimerDisponibilitesBinomesConcurrents(ID, ListeDisponibilites2, DATE, HEURE, ListeDisponibilitesResultat),
	algorithme(ListeDisponibilitesResultat, ListeBinomes2, [[ID, DATE, HEURE, SALLE]|ListeAttribution], ListeResultat).

algorithme(_, [], ListeAttribution, ListeAttribution).

% Supprime les disponibilit�s d'un bin�me concurrent au bin�me ID (pour
% pas qu'un bin�me concurrent prenne un cr�neau � la m�me heure)
% -> Cherche les binomes concurrents
% -> Supprime les disponibilit�s du binome concurrent
supprimerDisponibilitesBinomesConcurrents(ID, ListeDisponibilites, DATE, HEURE, ListeDisponibilitesResultat):-trouverLesBinomesConcurrents(ID, ListeConcurrents),
	supprimerDisponibilitesBinomes(ListeConcurrents, ListeDisponibilites, DATE, HEURE, ListeDisponibilitesResultat).


supprimerDisponibilitesBinomes(ListeBinomes, ListeDisponibilites, DATE, HEURE, ListeDisponibilitesResultat):-member([X|Y], ListeBinomes),
	delete(ListeDisponibilites, [X, DATE, HEURE, _], ListeDisponibilites2),
	delete(ListeBinomes, [X|Y], ListeBinomes2),
	supprimerDisponibilitesBinomes(ListeBinomes2, ListeDisponibilites2, DATE, HEURE, ListeDisponibilitesResultat).

supprimerDisponibilitesBinomes([], ListeDisponibilites, _, _, ListeDisponibilites).

% Cherche les binomes concurrents � un binome donn�
% -> Cherche tous les autres bin�mes avec leurs enseignants attitr�s
% -> Cherche les enseignants du bin�me courant
% -> On cherche les bin�mes qui ont des profs en commun avec le binome
% donn�.
trouverLesBinomesConcurrents(ID, R):- trouverTousLesAutresBinomes(ID, ListeEnseignantsAutresBinomes),
	findall(Enseignant, row(ID, Enseignant), ListeEnseignantsBinome),
	chercherConcurrents([ID|ListeEnseignantsBinome], ListeEnseignantsAutresBinomes, [], R).

% Cherche les profs en commun entre deux bin�mes
% S�lectionne une liste de profs pour un bin�me
% Supprime la liste de ces enseignants de la liste principale
% Fait l'intersection entre la liste des enseignants du binome et la
% liste extraite plus haut. Si incompatibilit�,	on continue � cherche
% les concurrents
chercherConcurrents(ListeEnseignantsBinome, ListeEnseignantsAutresBinomes, ListeEntree, ListeResultat):- member(AutresEnseignants, ListeEnseignantsAutresBinomes),
	delete(ListeEnseignantsAutresBinomes, AutresEnseignants, L2),
	incompatibilite(AutresEnseignants, ListeEnseignantsBinome),
	chercherConcurrents(ListeEnseignantsBinome, L2, [AutresEnseignants|ListeEntree], ListeResultat).

chercherConcurrents(ListeEnseignantsBinome, ListeEnseignantsAutresBinomes,ListeEntree, ListeResultat):- member(AutresEnseignants, ListeEnseignantsAutresBinomes),
	delete(ListeEnseignantsAutresBinomes, AutresEnseignants, L2),
	\+ incompatibilite(ListeEnseignantsBinome, ListeEnseignantsAutresBinomes),
	chercherConcurrents(ListeEnseignantsBinome, L2, ListeEntree, ListeResultat).

chercherConcurrents(_, [], ListeEntree, ListeEntree).

% Cherche la liste des binomes, supprime de la liste des binomes l'id
% qui correspond � l'id pass� en param�tre puis cherche les enseignants
% des bin�mes dans la nouvelle liste
trouverTousLesAutresBinomes(ID, ListeEnseignants):-obtenirListeBinome([], ListeBinomes),
	delete(ListeBinomes, ID, ListeBinomes2),
	trouverLesEnseignantsDesBinomes(ListeBinomes2, [], ListeEnseignants).

% Cherche les enseignants des bin�mes
% Retourne une liste des binomes avec leurs enseignants
% S�lectionne un ID de bin�me parmi les binomes de la liste
% Cherche tous les enseignants du bin�me s�lectionn�
% Supprime de la liste des bin�mes le bin�me s�lectionn�
% Lancement de la r�cursivit� sur tous les autres bin�mes restants et
% concat�nation de la liste des enseignants du bin�me � la liste
% d'entree
trouverLesEnseignantsDesBinomes(ListeBinomes, ListeEntree, ListeResultat):-
	member(X, ListeBinomes),
	findall(Enseignant, row(X, Enseignant),L),
	delete(ListeBinomes, X, ListeBinomes2),
	trouverLesEnseignantsDesBinomes(ListeBinomes2, [[X|L]|ListeEntree], ListeResultat).

trouverLesEnseignantsDesBinomes([], ListeEntree, ListeEntree).
