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

    INSERT INTO etudiant(nom_etudiant, prenom_etudiant, code_permanent, numero_plaque, courriel_etudiant, telephone_etudiant, supprime, id_universite, id_etudiant)
    VALUES(nom, prenom, cperm, nplaque, email, phone, suppr, univ, id);

end $

DELETE FROM etudiant WHERE nom_etudiant='pochart';
CALL NouvelEtudiant('pochart', 'clement', 'POCC05020400', 'NTM,BATARD', 'clement.pochart@epita.fr', '0612245462', 0, 1);
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
    IN suppr TINYINT(1),
    IN univ INT
)
BEGIN
    UPDATE etudiant
    
    SET nom_etudiant=nom,
        prenom_etudiant=prenom,
        code_permanent=cperm,
        numero_plaque=nplaque,
        courriel_etudiant=email,
        telephone_etudiant=phone,
        supprime=suppr,
        id_universite=univ

    WHERE id_etudiant=id;
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