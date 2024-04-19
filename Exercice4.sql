DELIMITER $
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