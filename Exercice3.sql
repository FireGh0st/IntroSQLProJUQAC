DELIMITER $
DROP PROCEDURE IF EXISTS ReserverPlaceStationnement$
CREATE PROCEDURE ReserverPlaceStationnement(
    IN id_etu INT,
    IN date_debut DATETIME,
    IN heure_debut TIME,
    IN date_fin DATETIME,
    IN heure_fin TIME
)
BEGIN
    DECLARE id_espace INT;
    DECLARE id_allee INT;
    DECLARE id_pla INT;
    DECLARE montant_a_payer DECIMAL(5,2);
    DECLARE cours_existe INT;
    DECLARE etudiant_info VARCHAR(255);
    DECLARE plaque VARCHAR(10);

    -- Validate data
    IF id_etu IS NULL OR date_debut IS NULL OR date_fin IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Data validation failed: Missing mandatory data.';
    END IF;

    -- Check if the student has a course during the reserved parking hours
    SELECT COUNT(*) INTO cours_existe
    FROM cours, etudiant, cours_suivi
    WHERE id_etu = etudiant.id_etudiant AND cours.id_cours = cours_suivi.id_cours AND
    ((heure_debut BETWEEN cours_suivi.heure_debut AND cours_suivi.heure_fin) OR (heure_fin BETWEEN cours_suivi.heure_debut AND cours_suivi.heure_fin));

    IF cours_existe = 0 THEN
        -- Get student info and car plate number
        SELECT CONCAT(nom_etudiant, ' ', prenom_etudiant), plaque INTO etudiant_info, plaque
        FROM etudiant
        WHERE id_etu = etudiant.id_etudiant;

        -- Create if not exists a parking violation table
        CREATE TABLE IF NOT EXISTS violation_stationnement(
            id_violation INT AUTO_INCREMENT PRIMARY KEY,
            id_etudiant INT,
            nom_prenom VARCHAR(255),
            plaque VARCHAR(10),
            date_tentative DATETIME
        );



        -- Create a parking violation record

        INSERT INTO violation_stationnement(id_etudiant, nom_prenom, plaque, date_tentative)
        VALUES(id_etudiant, etudiant_info, plaque, NOW());
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No course during the reserved parking hours.';
    END IF;

    -- Find an available parking space
    SELECT id_place INTO id_pla
    FROM place
    WHERE disponibilite = 'Oui'
    LIMIT 1;

    IF id_pla IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No available parking spaces.';
    END IF;

    -- Update the number of available spaces
    /* UPDATE allee, place
    SET nombre_places_dispo = nombre_places_dispo - 1
    WHERE place.id_allee = id_allee;*/

    -- Display reservation details
    SELECT espace_stationnement.designation_espace_stationnement AS 'Espace de stationnement', allee.designation_allee AS 'Allée', place.id_place AS 'Place', place.type_de_place AS 'Type de place', montant_a_payer AS 'Montant à payer', date_debut AS 'Date et heure d\'arrivée', date_fin AS 'Date et heure de départ'
    FROM espace_stationnement
    JOIN allee ON espace_stationnement.id_espace_stationnement = allee.id_espace_stationnement
    JOIN place ON allee.id_allee = place.id_allee
    WHERE place.id_place = id_pla;
END$
DELIMITER ;


-- Trigger to update the number of available spaces after a reservation is made
DELIMITER $
DROP TRIGGER IF EXISTS UpdateAvailableSpaces$
CREATE TRIGGER UpdateAvailableSpaces
AFTER INSERT ON place_reservee
FOR EACH ROW
BEGIN
    UPDATE allee
    SET nombre_places_dispo = nombre_places_dispo - 1
    WHERE id_allee = (SELECT id_allee FROM place WHERE id_place = NEW.id_place);
END$
DELIMITER ;

-- Test the procedure

CALL ReserverPlaceStationnement(1, '2021-12-01', '08:00:00', '2021-12-01', '09:00:00');