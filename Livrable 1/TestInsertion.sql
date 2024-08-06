INSERT INTO Utilisateurs(idUtilisateur, pseudo, dateNaissance) VALUES (1, '1', '12-12-1212');
INSERT INTO Utilisateurs(idUtilisateur, pseudo, dateNaissance) VALUES (2, '2', '12-12-1212');

INSERT INTO Premiums(idUtilisateur, nomPremium) VALUES (1, 'ONE');
INSERT INTO Premiums(idUtilisateur, nomPremium) VALUES (2, 'TWO');

--Trigger Block
INSERT INTO PremiumsAmis VALUES (1, 2);
INSERT INTO PremiumsBloques VALUES (1, 2);

DELETE FROM PremiumsAmis WHERE idUtilisateur = 1;
DELETE FROM PremiumsBloques WHERE idUtilisateur = 1;

--Trigger Ami
INSERT INTO PremiumsBloques VALUES (1, 2);
INSERT INTO PremiumsAmis VALUES (1, 2);

--Trigger Ordre
INSERT INTO Albums (idalbum, nomalbum, labelalbum, typealbum, anneealbum) VALUES ('7GqKsFVvsP3SVNQmrmGZSG', 'TEST', 'TEST', 'album', '2024');
INSERT INTO TRACKS_TEMP (idTrack, nomTrack, idAlbum) VALUES ('7GqKsFVvsP3SVNQmrmGZS1', 'test1', '7GqKsFVvsP3SVNQmrmGZSG');
INSERT INTO TRACKS_TEMP (idTrack, nomTrack, idAlbum) VALUES ('7GqKsFVvsP3SVNQmrmGZS2', 'test2', '7GqKsFVvsP3SVNQmrmGZSG');
INSERT INTO TRACKS_TEMP (idTrack, nomTrack, idAlbum) VALUES ('7GqKsFVvsP3SVNQmrmGZS3', 'test3', '7GqKsFVvsP3SVNQmrmGZSG');
INSERT INTO ConteneursPlaylists VALUES (1, 'Playlist', NULL, 1);
INSERT INTO Playlists VALUES (1, 'playlist1 de 1');
INSERT INTO PlaylistsTracks VALUES (1, 0, '7GqKsFVvsP3SVNQmrmGZS1'); 
INSERT INTO PlaylistsTracks VALUES (1, 1, '7GqKsFVvsP3SVNQmrmGZS1'); 
INSERT INTO PlaylistsTracks VALUES (1, 2, '7GqKsFVvsP3SVNQmrmGZS1'); 
INSERT INTO PlaylistsTracks VALUES (1, 3, '7GqKsFVvsP3SVNQmrmGZS2'); 
INSERT INTO PlaylistsTracks VALUES (1, 2, '7GqKsFVvsP3SVNQmrmGZS2'); 

--RESET
DELETE FROM PlaylistsTracks WHERE idPlaylist=1;
DELETE FROM Playlists WHERE idPlaylist = 1;
DELETE FROM ConteneursPlaylists WHERE idConteneur = 1;
DELETE FROM TRACKS_TEMP WHERE idAlbum = '7GqKsFVvsP3SVNQmrmGZSG';
DELETE FROM Albums WHERE idAlbum = '7GqKsFVvsP3SVNQmrmGZSG';
DELETE FROM PremiumsAmis WHERE idUtilisateur = 1;
DELETE FROM PremiumsBloques WHERE idUtilisateur = 1;
DELETE FROM Premiums WHERE idUtilisateur = 1;
DELETE FROM Premiums WHERE idUtilisateur = 2;
DELETE FROM Utilisateurs WHERE idUtilisateur = 1;
DELETE FROM Utilisateurs WHERE idUtilisateur = 2;