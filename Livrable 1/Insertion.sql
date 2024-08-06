/*
 Relations Artistes
 */

INSERT INTO Artistes (idArtiste, nomArtiste, populariteArtiste)
SELECT DISTINCT idArtist, name, popularity FROM Artists_Temp;

INSERT INTO Genres (nomGenre)
SELECT DISTINCT genre FROM Artists_Temp
WHERE genre IS NOT NULL;

INSERT INTO GenresArtistes
SELECT DISTINCT idArtist, idGenre FROM Artists_Temp at
JOIN Genres g ON at.genre = g.nomGenre;

INSERT INTO CategoriesPrix
SELECT DISTINCT category FROM Artists_Temp
WHERE category IS NOT NULL;

INSERT INTO Prix (nomPrix, nomCategorie)
SELECT DISTINCT award, category FROM Artists_Temp
WHERE award IS NOT NULL AND category IS NOT NULL;

INSERT INTO PrixArtistes
SELECT DISTINCT idPrix, year, idArtist FROM Artists_Temp at
JOIN Prix p ON at.award = p.nomPrix
WHERE year IS NOT NULL AND idArtist IS NOT NULL;


/*
 Relations Albums
 */

INSERT INTO Albums (idAlbum, nomAlbum, labelAlbum, typeAlbum, anneeAlbum)
SELECT DISTINCT idAlbum, name, label, type, year FROM Albums_Temp;

INSERT INTO Copyrights
SELECT DISTINCT idCopyright, copyright FROM Albums_Temp;

INSERT INTO AlbumsCopyrights
SELECT DISTINCT idAlbum, idCopyright FROM Albums_Temp;


/*
 Relations Tracks
 */

INSERT INTO Tracks
SELECT DISTINCT idTrack, name, idAlbum, popularity, danceAbility, energy, key_signature, loudness, "mode",
                speechiness, acousticness, instrumentalness, liveness, valence, tempo, duration_ms FROM Tracks_Temp;

INSERT INTO TracksInterpretes
SELECT DISTINCT idTrack, idArtist FROM Tracks_Temp;

INSERT INTO AlbumsParticipants
SELECT DISTINCT idAlbum, idArtist FROM Albums_Temp;


/*
 Relations Utilisateurs
 */

INSERT INTO Utilisateurs
SELECT DISTINCT idUser, pseudo, dateOfBirth, gender, timePlaying, idCurrentTrack FROM Users_Temp;

INSERT INTO Classiques
SELECT DISTINCT idUser FROM Users_Temp
WHERE name IS NULL;

INSERT INTO Premiums
SELECT DISTINCT idUser, name, surname FROM Users_Temp
WHERE name IS NOT NULL;

INSERT INTO UtilisateursSuivre
SELECT DISTINCT idUser, idArtistFollow FROM Users_Temp
WHERE idArtistFollow IS NOT NULL;

INSERT INTO PremiumsAmis
SELECT DISTINCT idUserPremium, idUserFriend FROM Friends_Temp;

INSERT INTO PremiumsBloques
SELECT DISTINCT idUserPremium, idUserBlocked FROM Users_Blocked_Temp;

INSERT INTO PremiumsPartage
SELECT DISTINCT idUser, idUserShare, idTrack FROM Share_Temp;

INSERT INTO UtilisateursHistorique
SELECT DISTINCT idUser, idTrack, dateListen FROM Tracks_Temp
WHERE dateListen IS NOT NULL;

INSERT INTO UtilisateursLike
SELECT DISTINCT idUser, idTrack, dateLike FROM Likes_Temp;

INSERT INTO UtilisateursEvaluations (idUtilisateur, idTrack, note)
SELECT DISTINCT idUser, idTrack, note FROM Evaluations_Temp;


/*
 Relations Playlists
 */

-- Insérer les conteneurs sans parent
INSERT INTO ConteneursPlaylists (nomConteneur, typeConteneur, idUtilisateur)
SELECT DISTINCT nameElement, type, idUser FROM Playlists_Temp;

-- Insérer le conteneur type & affecter les parents aux conteneurs
DECLARE
    id INTEGER;
BEGIN
    FOR x IN (SELECT DISTINCT idUser, nameElement, nameElementParent, type FROM Playlists_Temp) LOOP
        SELECT idConteneur INTO id FROM ConteneursPlaylists WHERE nomConteneur = x.nameElement AND idUtilisateur = x.idUser;

        -- Insertion du conteneur type
        IF x.type = 'Playlist' THEN
            INSERT INTO Playlists VALUES (id);
        ELSIF x.type = 'Folder' THEN
            INSERT INTO DossiersPlaylists VALUES (id);
        END IF;
    END LOOP;

    FOR x IN (SELECT DISTINCT idUser, nameElement, nameElementParent, type FROM Playlists_Temp) LOOP
        SELECT idConteneur INTO id FROM ConteneursPlaylists WHERE nomConteneur = x.nameElement AND idUtilisateur = x.idUser;

        -- Affectation du parent
        UPDATE ConteneursPlaylists SET idDossierParent = (SELECT idConteneur FROM ConteneursPlaylists WHERE nomConteneur = x.nameElementParent AND idUtilisateur = x.idUser)
        WHERE x.nameElementParent IS NOT NULL AND idConteneur = (id);
    END LOOP;
END;

INSERT INTO PlaylistsTracks
SELECT DISTINCT idConteneur, ordre, idTrack FROM Playlists_Temp pt
JOIN ConteneursPlaylists cp ON pt.nameElement = cp.nomConteneur
WHERE type = 'Playlist' AND idUtilisateur = idUser
ORDER BY ordre;
-- L'insertion de cette requête prend environ 2 minutes


COMMIT;