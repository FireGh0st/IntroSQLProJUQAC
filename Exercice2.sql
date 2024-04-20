DELIMITER $
DROP PROCEDURE IF EXISTS NouvelEtudiant$
CREATE PROCEDURE NouvelEtudiant(
    IN nom VARCHAR(45),
    IN prenom VARCHAR(60),
    IN cperm VARCHAR(15),
    IN nplaque VARCHAR(10),
    IN email VARCHAR(55),
    IN phone VARCHAR(10),
    IN suppr TINYINT(1),
    IN univ INT
)
BEGIN
    /*
    DECLARE id VARCHAR(10);
    DECLARE rand INT(6) ZEROFILL;
    set rand = FLOOR(0 + (RAND() * 999999));
    set id = CONCAT('ETU-',rand);

    WHILE EXISTS(SELECT * FROM etudiant WHERE id_etudiant=id)
    */

    DECLARE id VARCHAR(10);
    set id = (SELECT GenererIdentifiantEtudiant());

    IF nom IS NULL OR
       prenom IS NULL OR
       cperm IS NULL OR
       nplaque IS NULL OR
       email IS NULL OR
       phone IS NULL OR
       suppr IS NULL OR
       univ IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Les informations d\'etudiant ne peuvent pas etre nulles';
    end if ;

    IF NOT cperm REGEXP '[A-Z]{4}([0-2][0-9]|3[0-1])(0[0-9]|1[0-2])[0-9]{4}' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Code permanent invalide';
    end if ;

    IF NOT nplaque REGEXP '([A-Z]|[0-9]){3}([ A-Z]|[0-9]){1}([A-Z]|[0-9]){3}' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Numero de plaque invalide';
    end if ;

    IF NOT email REGEXP '.*@.*\..*' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email invalide';
    end if ;

    IF NOT phone REGEXP '[+0-9][0-9]*' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Numero de bigot invalide';
    end if ;

    IF (SELECT COUNT(*) FROM universite WHERE id_universite=univ) < 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'L\'universite n\'existe pas';
    end if ;

    INSERT INTO etudiant(nom_etudiant, prenom_etudiant, code_permanent, numero_plaque, courriel_etudiant, telephone_etudiant, supprime, id_universite, id_etudiant)
    VALUES(nom, prenom, cperm, nplaque, email, phone, suppr, univ, id);

end $

DELETE FROM etudiant WHERE nom_etudiant='pochart';
CALL NouvelEtudiant('pochart', 'clement', 'POCC05020400', 'NTM ARD', 'clement.pochart@epita.fr', NULL, 0, 1);
CALL NouvelEtudiant('hatton', 'lilian', 'HATL05020400', 'NTM,BATARD', 'lilian.hatton@epita.fr', '0612243462', 0, 1);

DELIMITER $
DROP PROCEDURE IF EXISTS AfficherEtudiant$
CREATE PROCEDURE AfficherEtudiant(
    IN id VARCHAR(10)
)
BEGIN
    SELECT * FROM etudiant WHERE id_etudiant=id;
end $
CALL AfficherEtudiant('ETU-000002');

DELIMITER $
DROP PROCEDURE IF EXISTS ModifierEtudiant$
CREATE PROCEDURE ModifierEtudiant(
    IN id VARCHAR(10),
    IN nom VARCHAR(45),
    IN prenom VARCHAR(60),
    IN cperm VARCHAR(15),
    IN nplaque VARCHAR(10),
    IN email VARCHAR(55),
    IN phone VARCHAR(10),
    IN univ INT
)
BEGIN

    IF cperm IS NOT NULL AND NOT cperm REGEXP '[A-Z]{4}([0-2][0-9]|3[0-1])(0[0-9]|1[0-2])[0-9]{4}' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Code permanent invalide';
    end if ;

    IF nplaque IS NOT NULL AND NOT nplaque REGEXP '([A-Z]|[0-9]){3}([ A-Z]|[0-9]){1}([A-Z]|[0-9]){3}' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Numero de plaque invalide';
    end if ;

    IF email IS NOT NULL AND NOT email REGEXP '.*@.*\..*' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email invalide';
    end if ;

    IF phone IS NOT NULL AND NOT phone REGEXP '[+0-9][0-9]*' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Numero de bigot invalide';
    end if ;

    IF univ IS NOT NULL AND (SELECT COUNT(*) FROM universite WHERE id_universite=univ) < 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'L\'universite n\'existe pas';
    end if ;

    IF nom IS NOT NULL THEN UPDATE etudiant SET nom_etudiant=nom WHERE id_etudiant=id;
    IF prenom IS NOT NULL THEN UPDATE etudiant SET prenom_etudiant=prenom WHERE id_etudiant=id;
    IF cperm IS NOT NULL THEN UPDATE etudiant SET code_permanent=cperm WHERE id_etudiant=id;
    IF nplaque IS NOT NULL THEN UPDATE etudiant SET numero_plaque=nplaque WHERE id_etudiant=id;
    IF email IS NOT NULL THEN UPDATE etudiant SET courriel_etudiant=email WHERE id_etudiant=id;
    IF phone IS NOT NULL THEN UPDATE etudiant SET telephone_etudiant=phone WHERE id_etudiant=id;
    IF univ IS NOT NULL THEN UPDATE etudiant SET id_universite=univ WHERE id_etudiant=id;

end $

DELIMITER $
DROP PROCEDURE IF EXISTS SupprimerEtudiant$
CREATE PROCEDURE SupprimerEtudiant(
    IN id VARCHAR(10)
)
BEGIN
    UPDATE etudiant
    SET supprime=1
    WHERE id_etudiant=id;
end $

CALL SupprimerEtudiant('ETU-000002');