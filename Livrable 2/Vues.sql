/*
 SAE 2.04 - Livrable 2 (Vues)
 Groupe S1-4 (Julien RENAUD, Milwenn FRANCEUS--COINTREL, Héloïse RIGAUX, Alexandre DESCHANEL)
 */


/*
 VUE NUMERO 1
 */

-- Récupérer le nombre d'interprètes par morceau
CREATE OR REPLACE VIEW TracksNbInterpretes AS 
    SELECT idTrack, COUNT(*) AS nbInterpretes 
    FROM TracksInterpretes 
    GROUP BY idTrack;

-- Récupérer le nombre d'écoutes par morceau (Rmq: 2 écoutes d'un même utilisateur compte pour deux écoutes)
CREATE OR REPLACE VIEW TracksNbEcoutes AS 
    SELECT idTrack, COUNT(*) AS nbEcoutes 
    FROM UtilisateursHistorique 
    GROUP BY idTrack;

-- Récupérer le nombre d'écoutes par morceau actuellement écoutés (Rmq: 2 écoutes d'un même utilisateur compte pour deux écoutes)
CREATE OR REPLACE VIEW TracksNbEcoutesEnCours AS 
    SELECT idTrackLast, COUNT(*) AS nbEcoutesEnCours 
    FROM Utilisateurs
    WHERE idTrackLast IS NOT NULL
    GROUP BY idTrackLast;

-- Récupérer la moyenne des notes par morceau
CREATE OR REPLACE VIEW TracksEvaluationMoyenne AS 
    SELECT idTrack, SUM(note)/COUNT(*) AS noteMoyenne
    FROM UtilisateursEvaluations
    GROUP BY idTrack;

-- Récupérer le nombre de likes par morceau
CREATE OR REPLACE VIEW TracksNbLikes AS 
    SELECT idTrack, COUNT(*) AS nbLikes 
    FROM UtilisateursLike
    GROUP BY idTrack;

-- Récupérer le nombre de playlists par morceau contenu dans au moins une playlist
CREATE OR REPLACE VIEW TracksNbPlaylists AS 
    SELECT idTrack, COUNT(*) AS NbPlaylists 
    FROM PlaylistsTracks 
    GROUP BY idTrack;

-- Récupérer le nombre de playlists par morceau contenu dans au moins une playlist et pour lequel il est en première position
CREATE OR REPLACE VIEW TracksNbTopOfPlaylists AS
    SELECT idTrack, COUNT(*) AS NbTopOfPlaylists 
    FROM PlaylistsTracks
    WHERE ordre = 1
    GROUP BY idTrack;

-- Récupérer le nombre de partages par morceau
CREATE OR REPLACE VIEW TracksNbPartages AS 
    SELECT idTrack, COUNT(*) AS nbPartages 
    FROM PremiumsPartage
    GROUP BY idTrack;

-- FINAL:
-- Récupérer le nombre d'interprètes, le nombre d'écoutes, le nombre d'écoutes en cours, la note moyenne, le nombre de likes, le nombre de playlists,
-- le nomnre de playlists où le morceau est en première position et le nombre de partages pour chaque morceau
CREATE OR REPLACE VIEW TracksInfo AS 
    SELECT t.idTrack, NVL(nbInterpretes, 0) AS nbInterpretes,
        NVL(nbEcoutes, 0) AS nbEcoutes, 
        NVL(nbEcoutesEnCours, 0) AS nbEcoutesEnCours, 
        NVL(noteMoyenne, 0) AS noteMoyenne,
        NVL(nbLikes, 0) AS nbLikes, 
        NVL(NbPlaylists, 0) AS NbPlaylists, 
        NVL(NbTopOfPlaylists, 0) AS NbTopOfPlaylists, 
        NVL(nbPartages, 0) AS nbPartages
    FROM Tracks t 
    LEFT JOIN TracksNbInterpretes t1 ON t.idTrack = t1.idTrack 
    LEFT JOIN TracksNbEcoutes t2 ON t.idTrack = t2.idTrack 
    LEFT JOIN TracksNbEcoutesEnCours t3 ON t.idTrack = t3.idTrackLast
    LEFT JOIN TracksEvaluationMoyenne t4 ON t.idTrack = t4.idTrack 
    LEFT JOIN TracksNbLikes t5 ON t.idTrack = t5.idTrack 
    LEFT JOIN TracksNbPlaylists t6 ON t.idTrack = t6.idTrack
    LEFT JOIN TracksNbTopOfPlaylists t7 ON t.idTrack = t7.idTrack
    LEFT JOIN TracksNbPartages t8 ON t.idTrack = t8.idTrack;


/*
 VUE NUMERO 2
 */

-- 1re solution: Récupérer le morceau le moins écouté et le morceau le plus écoute pour chaque album
-- Sans utilisation de notre trigger (il n y a pas d'albums sans tracks)
CREATE OR REPLACE VIEW AlbumsInfoMinMax AS 
    SELECT DISTINCT idAlbum,
    LAST_VALUE(t.idTrack) OVER (
        PARTITION BY idAlbum ORDER BY nbEcoutes DESC
        RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS moinsEcoute,
    FIRST_VALUE(t.idTrack) OVER (
        PARTITION BY idAlbum ORDER BY nbEcoutes DESC
        ROWS UNBOUNDED PRECEDING
    ) AS plusEcoute
    FROM Tracks t
    LEFT JOIN TracksNbEcoutes t2 ON t.idTrack = t2.idTrack;

-- 1re solution: Récupérer le nombre de morceaux dans un album
CREATE OR REPLACE VIEW AlbumsInfoNbMorceaux AS 
    SELECT idAlbum, NVL(COUNT(*), 0) AS nbMorceaux 
    FROM Tracks t
    GROUP BY idAlbum;

-- FINAL: 1re solution - Récupérer le nombre de morceaux, le morceau le moins écouté et le morceau le plus écoute pour chaque album
CREATE OR REPLACE VIEW AlbumsInfo AS 
    SELECT a.idAlbum, nbMorceaux, moinsEcoute, plusEcoute
    FROM AlbumsInfoMinMax a 
    JOIN AlbumsInfoNbMorceaux a2 ON a.idAlbum = a2.idAlbum;

-- FINAL: 2e solution - Récupérer le nombre de morceaux, le morceau le moins écouté et le morceau le plus écoute pour chaque album
-- Avec utilisation de notre trigger (via l'attribut 'totalTracks')
CREATE OR REPLACE VIEW AlbumsInfoBis AS 
    SELECT DISTINCT a.idAlbum, totalTracks,
    LAST_VALUE(t.idTrack) OVER (
        PARTITION BY a.idAlbum ORDER BY nbEcoutes DESC
        RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS moinsEcoute,
    FIRST_VALUE(t.idTrack) OVER (
        PARTITION BY a.idAlbum ORDER BY nbEcoutes DESC
        ROWS UNBOUNDED PRECEDING
    ) AS plusEcoute
    FROM Tracks t
    LEFT JOIN TracksNbEcoutes t2 ON t.idTrack = t2.idTrack
    LEFT JOIN Albums a ON a.idAlbum = t.idAlbum;


/*
 VUE NUMERO 3
 */

-- Récupérer le jour et mois de naissance pour chaque utilisateur
CREATE OR REPLACE VIEW UtilisateursJourMoisNaissance AS    
    SELECT idUtilisateur, EXTRACT(MONTH FROM dateNaissance) * 100 + EXTRACT(DAY FROM dateNaissance) AS jourMoisNaissance
    FROM Utilisateurs;

-- Récupérer le jour et mois de naissance & signe astrologique pour chaque utilisateur
CREATE OR REPLACE VIEW UtilisateursSignesAstro AS 
    SELECT idUtilisateur, jourMoisNaissance,
        CASE 
            WHEN jourMoisNaissance >= 120 AND jourMoisNaissance <= 218 THEN 'Verseau'
            WHEN jourMoisNaissance >= 219 AND jourMoisNaissance <= 320 THEN 'Poissons'
            WHEN jourMoisNaissance >= 321 AND jourMoisNaissance <= 419 THEN 'Bélier'
            WHEN jourMoisNaissance >= 420 AND jourMoisNaissance <= 520 THEN 'Taureau'
            WHEN jourMoisNaissance >= 521 AND jourMoisNaissance <= 621 THEN 'Gémeaux'
            WHEN jourMoisNaissance >= 622 AND jourMoisNaissance <= 722 THEN 'Cancer'
            WHEN jourMoisNaissance >= 723 AND jourMoisNaissance <= 822 THEN 'Lion'
            WHEN jourMoisNaissance >= 823 AND jourMoisNaissance <= 922 THEN 'Vierge'
            WHEN jourMoisNaissance >= 923 AND jourMoisNaissance <= 1023 THEN 'Balance'
            WHEN jourMoisNaissance >= 1024 AND jourMoisNaissance <= 1121 THEN 'Scorpion'
            WHEN jourMoisNaissance >= 1122 AND jourMoisNaissance <= 1221 THEN 'Sagittaire'
            ELSE 'Capricorne'
        END AS signeAstrologique
    FROM UtilisateursJourMoisNaissance;

-- FINAL: Récupérer le morceau le plus écouté pour chaque signe astrologique
CREATE OR REPLACE VIEW TrackPlusEcouteParAstro AS
    SELECT signeAstrologique, idTrack
    FROM UtilisateursHistorique uh
    JOIN UtilisateursSignesAstro u ON uh.idUtilisateur = u.idUtilisateur
    GROUP BY signeAstrologique, idTrack
    HAVING COUNT(*) = (
        SELECT MAX(COUNT(*)) FROM UtilisateursHistorique uh
        JOIN UtilisateursSignesAstro u ON uh.idUtilisateur = u.idUtilisateur
        GROUP BY signeAstrologique, idTrack
    );


/*
 VUE NUMERO 4
 */

-- Récupérer la sommes des écoutes accumulées par un artiste
CREATE OR REPLACE VIEW TracksNbEcoutesParArtistes AS 
    SELECT idArtiste, SUM(nbEcoutes) AS nbEcoutesTotal 
    FROM Tracks t
    JOIN TracksNbEcoutes t2 ON t.idTrack = t2.idTrack 
    JOIN AlbumsParticipants ap ON t.idAlbum = ap.idAlbum
    GROUP BY idArtiste;

-- Récupérer le rang des artistes (en fonction du nombre de morceaux ecoutés de l'artiste) par genre
CREATE OR REPLACE VIEW TracksNbEcoutesParGenre AS 
    SELECT g.idGenre, nomGenre, t.idArtiste, RANK() OVER (PARTITION BY g.idGenre ORDER BY nbEcoutesTotal DESC) AS rang 
    FROM TracksNbEcoutesParArtistes t
    JOIN GenresArtistes ga ON t.idArtiste = ga.idArtiste
    JOIN Genres g ON g.idGenre = ga.idGenre
    ORDER BY rang;

-- FINAL: Récupérer les 3 artistes les plus écoutés par genre (il peut avoir des exaequo : ex deux sont premiers, du coup 1-1-3 (pas de deuxieme))
CREATE OR REPLACE VIEW TracksNbEcoutesParGenreTop3 AS 
    SELECT idGenre, nomGenre, idArtiste, rang
    FROM TracksNbEcoutesParGenre
    WHERE rang < 4
    ORDER BY idGenre, rang;


/*
 VUE NUMERO 5
 */

-- Récupérer tous les morceaux contenus dans les playlists des utilisateurs
CREATE OR REPLACE VIEW UtTracksInPlaylistOwned AS 
    SELECT idUtilisateur, p.idPlaylist, idTrack
    FROM ConteneursPlaylists cp 
    JOIN Playlists p ON cp.idConteneur = p.idPlaylist
    JOIN PlaylistsTracks pt ON pt.idPlaylist = p.idPlaylist;

-- Récupérer le nombre de morceaux présents dans les playlists, regroupés par playlist et par utilisateurs
CREATE OR REPLACE VIEW UtInfoPratique AS 
    SELECT uh.idUtilisateur, uh.idTrack, idPlaylist, COUNT(*) AS nbEcoutes
    FROM UtTracksInPlaylistOwned u 
    JOIN UtilisateursHistorique uh 
    ON u.idUtilisateur = uh.idUtilisateur
    WHERE u.idTrack = uh.idTrack
    GROUP BY uh.idUtilisateur, uh.idTrack, idPlaylist;
    
-- Récupérer le chemin des playlists
CREATE OR REPLACE VIEW PlaylistsPath AS     
    WITH Relations(parent, fils, label, idInit) AS (
        SELECT idDossierParent,
        idConteneur,
        nomConteneur, 
        idConteneur --stocker idPlaylistI
        FROM ConteneursPlaylists WHERE typeConteneur = 'Playlist'
        UNION ALL 
        SELECT idDossierParent,
        idConteneur,
        CONCAT(CONCAT(nomConteneur, '/'), label),
        idInit
        FROM Relations, ConteneursPlaylists
        WHERE Relations.parent = ConteneursPlaylists.idConteneur)
    SELECT idInit As idPlaylist, label AS chemin FROM Relations WHERE parent IS NULL;


-- FINAL: Récupérer pour chaque utilisateur, le pseudo de l'utilisateur et le nom du morceau le plus écouté parmi ceux qui se trouvent dans ses playlists
CREATE OR REPLACE VIEW UtInfo AS 
    SELECT pseudo, nomTrack, chemin
    FROM UtInfoPratique ut 
    JOIN Utilisateurs u ON ut.idUtilisateur = u.idUtilisateur
    JOIN Tracks t ON t.idTrack = ut.idTrack
    JOIN PlaylistsPath p ON p.idPlaylist = ut.idPlaylist 
    WHERE (u.idUtilisateur, nbEcoutes) IN (
        SELECT idUtilisateur, MAX(nbEcoutes) 
        FROM UtInfoPratique
        GROUP BY idUtilisateur
    );


/*
 VUE NUMERO 6
 */

-- Récupérer seulement les utilisateurs premiums ayant partagés au moins une Track avec un autre ami premium
CREATE OR REPLACE VIEW MorceauxBrutPartagesAvecAmis AS
    SELECT p.idUtilisateur, idUtilisateurAmi, idTrack FROM Premiums p
    LEFT JOIN PremiumsPartage pp ON p.idUtilisateur=pp.idUtilisateur
    LEFT JOIN PremiumsAmis pa ON pp.idUtilisateur=pa.idUtilisateur
    WHERE idUtilisateurPartage = idUtilisateurAmi;

-- FINAL: Récupérer le nombre de morceaux partagés d'un utilisateur premium avec un ami premium
CREATE OR REPLACE VIEW MorceauxPartagesAvecAmis AS
    SELECT p.idUtilisateur, COUNT(mb.idUtilisateur) AS nbMorceaux FROM Premiums p
    LEFT JOIN MorceauxBrutPartagesAvecAmis mb ON p.idUtilisateur=mb.idUtilisateur
    GROUP BY p.idUtilisateur
    ORDER BY nbMorceaux DESC, idUtilisateur;


/*
 VUE NUMERO 7
 */

-- Récupérer l'heure d'historique
CREATE OR REPLACE VIEW EcoutesInfo AS
    SELECT idUtilisateur, idTrack, EXTRACT(HOUR FROM dateEcoute) AS heure
    FROM UtilisateursHistorique uh;

-- Récupérer le nombre d'écoutes par heure
CREATE OR REPLACE VIEW EcoutesParHeure AS
    SELECT heure, COUNT(*) AS nbEcoutes FROM EcoutesInfo
    GROUP BY heure;

-- Récupérer le nombre d'écoutes par moment de la journée
CREATE OR REPLACE VIEW EcoutesParMoment AS
    SELECT 'nuit' AS moment, SUM(nbEcoutes) AS nbEcoutes FROM EcoutesParHeure
    WHERE heure >= 0 AND heure < 6
    UNION
    SELECT 'matin' AS moment, SUM(nbEcoutes) AS nbEcoutes FROM EcoutesParHeure
    WHERE heure >= 6 AND heure < 12
    UNION
    SELECT 'après-midi' AS moment, SUM(nbEcoutes) AS nbEcoutes FROM EcoutesParHeure
    WHERE heure >= 12 AND heure < 18
    UNION
    SELECT 'soir' AS moment, SUM(nbEcoutes) AS nbEcoutes FROM EcoutesParHeure
    WHERE heure >= 18 AND heure < 24;

-- FINAL: Récupérer le moment le plus écouté de la journée
CREATE OR REPLACE VIEW MomentPlusEcoute AS
    SELECT moment FROM EcoutesParMoment
    WHERE nbEcoutes = (SELECT MAX(nbEcoutes) FROM EcoutesParMoment);

/*
 VUE NUMERO 8
 */

-- FINAL: Récupérer la moyenne des notes de chaque morceau pour chaque utilisateur ayant évalués
CREATE OR REPLACE VIEW MoyenneTrackEvaluations AS
    SELECT idUtilisateur, idTrack, AVG(note) AS moyenne FROM UtilisateursEvaluations
    GROUP BY idUtilisateur, idTrack;


/*
 VUE NUMERO 9
 */

-- FINAL: Récupérer la médiane des moyennes des évaluations des Tracks pour chaque morceau
CREATE OR REPLACE VIEW MedianeParmiMoyenneTrack AS
    SELECT idTrack, MEDIAN(moyenne) AS mediane FROM MoyenneTrackEvaluations
    GROUP BY idTrack;


/*
 VUE NUMERO 10
 */

-- Récupérer l'écart type pour tous les morceaux
CREATE OR REPLACE VIEW EcartTypeEvaluationsTrack AS
    SELECT idTrack, STDDEV(note) AS ecartType FROM UtilisateursEvaluations
    GROUP BY idTrack;

-- FINAL: Récupérer le morceau avec le plus gros écart type
CREATE OR REPLACE VIEW TrackAvecPlusGrandEcartType AS
    SELECT idTrack FROM EcartTypeEvaluationsTrack
    WHERE ecartType = (SELECT MAX(ecartType) FROM EcartTypeEvaluationsTrack)
    AND ROWNUM <= 1; -- Dans le cas qu'il y est plusieurs morceaux avec le plus gros ET, on se limite qu'au premier trouvé
