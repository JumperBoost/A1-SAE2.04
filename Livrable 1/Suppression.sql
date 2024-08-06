ALTER TABLE DossiersPlaylists DROP CONSTRAINT fk_dossPlay_idD_vers_ctnPlay;
ALTER TABLE ConteneursPlaylists DROP CONSTRAINT fk_ctnPlay_idD_vers_dossPlay;
DROP SEQUENCE Seq_Prix;
DROP SEQUENCE Seq_Genres;
DROP SEQUENCE Seq_UtEvaluations;
DROP SEQUENCE Seq_ConteneursPlaylists;
DROP PROCEDURE proc_ast_increment_follower;
DROP PROCEDURE proc_ast_decrement_follower;
DROP PROCEDURE proc_tracks_increment_totalTk;
DROP PROCEDURE proc_tracks_decrement_totalTk;

DROP TABLE PlaylistsTracks;
DROP TABLE DossiersPlaylists;
DROP TABLE Playlists;
DROP TABLE ConteneursPlaylists;

DROP TABLE UtilisateursEvaluations;
DROP TABLE UtilisateursLike;
DROP TABLE UtilisateursHistorique;
DROP TABLE PremiumsPartage;
DROP TABLE PremiumsBloques;
DROP TABLE PremiumsAmis;
DROP TABLE UtilisateursSuivre;
DROP TABLE Premiums;
DROP TABLE Classiques;
DROP TABLE Utilisateurs;

DROP TABLE AlbumsParticipants;
DROP TABLE TracksInterpretes;
DROP TABLE Tracks;
DROP TABLE AlbumsCopyrights;
DROP TABLE Copyrights;
DROP TABLE Albums;

DROP TABLE PrixArtistes;
DROP TABLE Prix;
DROP TABLE CategoriesPrix;
DROP TABLE GenresArtistes;
DROP TABLE Genres;
DROP TABLE Artistes;