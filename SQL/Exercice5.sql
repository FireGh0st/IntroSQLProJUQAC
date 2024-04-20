DELIMITER $
DROP PROCEDURE IF EXISTS RapportAiresStationnement$
CREATE PROCEDURE RapportAiresStationnement()
BEGIN
    -- Déclaration des variables
    DECLARE fin INT DEFAULT 0;
    DECLARE univ_nom VARCHAR(45);
    DECLARE univ_id INT;
    DECLARE etu_count, esp_count, agt_count, all_count, plc_count, plc_handi_count, plc_disp_count, plc_res_count, res_moy_count, res_max_date, res_min_date INT;

    -- Déclaration du curseur
    DECLARE cur CURSOR FOR SELECT id_universite, nom_universite FROM universite;

    -- Déclaration du handler
    -- DECLARE CONTINUE HANDLER FOR NOT FOUND SET fin = 1;

    -- Ouverture du curseur
    OPEN cur;

    -- Boucle pour parcourir les universités
    read_loop: LOOP
        -- Récupération de l'id et du nom de l'université
        FETCH cur INTO univ_id, univ_nom;

        -- Si fin est à 1, on sort de la boucle
        IF fin = 1 THEN
            LEAVE read_loop;
        END IF;

        -- Calcul des statistiques pour l'université
        SELECT COUNT(*) INTO etu_count FROM etudiant WHERE id_universite = univ_id;
        SELECT COUNT(*) INTO esp_count FROM espace_stationnement WHERE id_universite = univ_id;
        SELECT COUNT(*) INTO agt_count
                        FROM espace_surveille es
                        JOIN espace_stationnement est ON es.id_espace_stationnement = est.id_espace_stationnement
                        JOIN universite u ON est.id_universite = u.id_universite
                        WHERE u.id_universite = univ_id;
        SELECT COUNT(*) INTO all_count FROM allee WHERE id_espace_stationnement IN (SELECT id_espace_stationnement FROM espace_stationnement WHERE id_universite = univ_id);
        SELECT COUNT(*) INTO plc_count FROM place WHERE id_allee IN (SELECT id_allee FROM allee WHERE id_espace_stationnement IN (SELECT id_espace_stationnement FROM espace_stationnement WHERE id_universite = univ_id));
        SELECT COUNT(*) INTO plc_handi_count FROM place WHERE id_allee IN (SELECT id_allee FROM allee WHERE id_espace_stationnement IN (SELECT id_espace_stationnement FROM espace_stationnement WHERE id_universite = univ_id)) AND type_de_place = 'personnes à mobilité réduite';
        SELECT COUNT(*) INTO plc_disp_count FROM place WHERE id_allee IN (SELECT id_allee FROM allee WHERE id_espace_stationnement IN (SELECT id_espace_stationnement FROM espace_stationnement WHERE id_universite = univ_id)) AND disponibilite = 'Oui';
        SELECT COUNT(*) INTO plc_res_count FROM place WHERE id_allee IN (SELECT id_allee FROM allee WHERE id_espace_stationnement IN (SELECT id_espace_stationnement FROM espace_stationnement WHERE id_universite = univ_id)) AND disponibilite = 'Non';
        SELECT AVG(nombre_reservations) INTO res_moy_count FROM (SELECT COUNT(*) as nombre_reservations FROM place_reservee WHERE id_place IN (SELECT id_place FROM place WHERE id_allee IN (SELECT id_allee FROM allee WHERE id_espace_stationnement IN (SELECT id_espace_stationnement FROM espace_stationnement WHERE id_universite = univ_id))) AND YEAR(date_heure_debut) = 2023 GROUP BY date_heure_debut) as subquery;
        SELECT date_heure_debut INTO res_max_date FROM place_reservee WHERE id_place IN (SELECT id_place FROM place WHERE id_allee IN (SELECT id_allee FROM allee WHERE id_espace_stationnement IN (SELECT id_espace_stationnement FROM espace_stationnement WHERE id_universite = univ_id))) AND YEAR(date_heure_debut) = 2023 GROUP BY date_heure_debut ORDER BY COUNT(*) DESC LIMIT 1;
        SELECT date_heure_debut INTO res_min_date FROM place_reservee WHERE id_place IN (SELECT id_place FROM place WHERE id_allee IN (SELECT id_allee FROM allee WHERE id_espace_stationnement IN (SELECT id_espace_stationnement FROM espace_stationnement WHERE id_universite = univ_id))) AND YEAR(date_heure_debut) = 2023 GROUP BY date_heure_debut ORDER BY COUNT(*) ASC LIMIT 1;

        -- Affichage des statistiques pour l'université
        SELECT univ_nom AS 'Nom de l\'université', etu_count AS 'Nombre d\'étudiants', esp_count AS 'Nombre d\'espaces de stationnement', agt_count AS 'Nombre d\'agents de surveillance', all_count AS 'Nombre d\'allées', plc_count AS 'Nombre de places', plc_handi_count AS 'Nombre de places pour handicapés', plc_disp_count AS 'Nombre de places disponibles', plc_res_count AS 'Nombre de places réservées', res_moy_count AS 'Nombre moyen de réservations en 2023', res_max_date AS 'Date ayant eu le plus de réservations', res_min_date AS 'Date ayant eu le moins de réservations';
    END LOOP;

    -- Fermeture du curseur
    CLOSE cur;
END$
DELIMITER ;

CALL RapportAiresStationnement();