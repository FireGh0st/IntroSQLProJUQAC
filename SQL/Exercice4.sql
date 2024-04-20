DELIMITER $
DROP FUNCTION IF EXISTS GenererIdentifiantEtudiant$
CREATE FUNCTION GenererIdentifiantEtudiant() RETURNS VARCHAR(10) DETERMINISTIC
BEGIN
    DECLARE nombre_etudiants INT;
    DECLARE identifiant_etudiant VARCHAR(10);

    -- Obtenir le nombre actuel d'étudiants
    SELECT COUNT(*) INTO nombre_etudiants FROM etudiant;

    -- Vérifier si le nombre d'étudiants est inférieur à 1 000 000
    IF nombre_etudiants >= 1000000 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Le nombre maximum d\'étudiants a été atteint.';
    END IF;

    -- Ajouter 1 au nombre d'étudiants pour obtenir un identifiant unique
    SET nombre_etudiants = nombre_etudiants + 1;

    -- Utiliser LPAD pour ajouter des zéros au début du nombre jusqu'à ce qu'il atteigne une longueur de 6 chiffres
    SET identifiant_etudiant = LPAD(nombre_etudiants, 6, '0');

    -- Concaténer le préfixe "ETU-" avec le nombre pour obtenir l'identifiant final
    SET identifiant_etudiant = CONCAT('ETU-', identifiant_etudiant);

    RETURN identifiant_etudiant;
END$
DELIMITER ;

DROP VIEW IF EXISTS Vue_Aires_Stationnement;
CREATE VIEW Vue_Aires_Stationnement AS
SELECT
    universite.nom_universite AS 'Nom de l\'université',
    espace_stationnement.designation_espace_stationnement AS 'Espace de stationnement',
    allee.designation_allee AS 'Allée',
    COUNT(DISTINCT CASE WHEN place.disponibilite = 'Oui' THEN place.id_place END) AS 'Nombre de places disponibles',
    COUNT(DISTINCT CASE WHEN place.disponibilite = 'Non' THEN place.id_place END) AS 'Nombre de places réservées'
FROM
    universite
JOIN
    espace_stationnement ON universite.id_universite = espace_stationnement.id_universite
JOIN
    allee ON espace_stationnement.id_espace_stationnement = allee.id_espace_stationnement
JOIN
    place ON allee.id_allee = place.id_allee

GROUP BY
    universite.nom_universite, espace_stationnement.designation_espace_stationnement, allee.designation_allee;


DELIMITER $
DROP EVENT IF EXISTS MettreAJourDisponibilite$
CREATE EVENT MettreAJourDisponibilite
ON SCHEDULE EVERY 5 MINUTE DO
BEGIN
    -- Identifier les places dont toutes les réservations sont terminées
    CREATE TEMPORARY TABLE PlacesDisponibles AS
    SELECT place.id_place
    FROM place
    LEFT JOIN place_reservee ON place.id_place = place_reservee.id_place
    WHERE place_reservee.date_heure_fin < NOW() OR place_reservee.date_heure_fin IS NULL
    GROUP BY place.id_place
    HAVING COUNT(place_reservee.date_heure_fin >= NOW() OR NULL) = 0;

    -- Mettre à jour la disponibilité des places identifiées
    UPDATE place
    SET disponibilite = 'Oui'
    WHERE id_place IN (SELECT id_place FROM PlacesDisponibles);

    -- Supprimer la table temporaire
    DROP TEMPORARY TABLE PlacesDisponibles;
END$
DELIMITER ;