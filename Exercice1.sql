-- Exercice 1.1

DELIMITER $
DROP PROCEDURE IF EXISTS NouvelleAireStationnement$
CREATE PROCEDURE NouvelleAireStationnement(
    IN nom_universite VARCHAR(45),
    IN sigle VARCHAR(10),
    IN numero_civique VARCHAR(5),
    IN nom_rue VARCHAR(15),
    IN ville VARCHAR(45),
    IN province ENUM('Alberta','Colombie-Britannique','Île-du-Prince-Édouard','Manitoba','Nouveau-Brunswick','Nouvelle-Écosse','Ontario','Québec','Saskatchewan','Terre-Neuve-et-Labrador','Territoires du Nord-Ouest','Nunavut','Yukon'),
    IN code_postal VARCHAR(7)
)
BEGIN
    DECLARE id_universite INT;
    DECLARE id_espace INT;
    DECLARE id_allee INT;
    DECLARE i INT DEFAULT 1;
    DECLARE j INT DEFAULT 1;


    -- Créer une nouvelle université
    INSERT INTO universite(nom_universite, sigle, numero_civique, nom_rue, ville, province, code_postal)
    VALUES (nom_universite, sigle, numero_civique, nom_rue, ville, province, code_postal);

    SET id_universite = LAST_INSERT_ID();

    IF id_universite IS NOT NULL THEN
        -- Créer un nouvel espace de stationnement
        INSERT INTO espace_stationnement(id_universite, designation_espace_stationnement)
        VALUES (id_universite, 'Default');

        SET id_espace = LAST_INSERT_ID();

        -- Créer trois allées
        WHILE i <= 3
            DO
                INSERT INTO allee(id_espace_stationnement, designation_allee, sens_circulation, nombre_places_dispo ,tarif_horaire)
                VALUES (id_espace, CONCAT('Allee-', id_espace, '-', i), i, 10, 4.5);

                SET id_allee = LAST_INSERT_ID();

                -- Créer dix places dans chaque allée
                WHILE j <= 10
                    DO
                        INSERT INTO place(type_de_place, id_allee, disponibilite)
                        VALUES (IF(j <= 2, 'personnes à mobilité réduite', 'standard'), id_allee, 'Oui');

                        SET j = j + 1;
                    END WHILE;

                SET i = i + 1;
            END WHILE;
    END IF;
END$
DELIMITER ;

CALL NouvelleAireStationnement('Université de Montréal', 'UdeM', '2900', 'Edouard', 'Montréal', 'Québec', 'H3T 1J4');

-- Exercice 1.2

DROP TABLE IF EXISTS `log_aire_stationnement`;
CREATE TABLE `log_aire_stationnement` (
  `id_log` int(11) NOT NULL AUTO_INCREMENT,
  `nom_universite` varchar(45) NOT NULL,
  `sigle` varchar(10) NOT NULL,
  `date_heure_tentative` datetime NOT NULL,
  PRIMARY KEY (`id_log`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DELIMITER $
DROP TRIGGER IF EXISTS LogAireStationnement$
CREATE TRIGGER LogAireStationnement
AFTER INSERT ON espace_stationnement
FOR EACH ROW
BEGIN
  DECLARE nom_univ VARCHAR(45);
  DECLARE sigl VARCHAR(10);

  SELECT nom_universite, sigle INTO nom_univ, sigl
  FROM universite
  WHERE id_universite = NEW.id_universite;

  INSERT INTO log_aire_stationnement(nom_universite, sigle, date_heure_tentative)
  VALUES(nom_univ, sigl, NOW());
END$
DELIMITER ;

INSERT INTO espace_stationnement(designation_espace_stationnement,id_universite)
VALUES('Trigger', 1);
SELECT * FROM log_aire_stationnement;