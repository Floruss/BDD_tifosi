USE tifosi;

-- ----------------------------------------------------------------------------
-- Requête 1 : Afficher la liste des noms des focaccias par ordre
--             alphabétique croissant.
-- ----------------------------------------------------------------------------
-- Résultat attendu : Américaine, Emmentalaccia, Gorgonzollaccia, Hawaienne,
--                     Mozaccia, Paysanne, Raclaccia, Tradizione (8 lignes)
-- Résultat obtenu   : conforme au résultat attendu.
-- Écart             : aucun.
-- ----------------------------------------------------------------------------
SELECT nom
FROM focaccia
ORDER BY nom ASC;


-- ----------------------------------------------------------------------------
-- Requête 2 : Afficher le nombre total d'ingrédients.
-- ----------------------------------------------------------------------------
-- Résultat attendu : 25
-- Résultat obtenu   : 25.
-- Écart             : aucun.
-- ----------------------------------------------------------------------------
SELECT COUNT(*) AS nombre_total_ingredients
FROM ingredient;


-- ----------------------------------------------------------------------------
-- Requête 3 : Afficher le prix moyen des focaccias.
-- ----------------------------------------------------------------------------
-- Résultat attendu : 10.38 € (moyenne des 8 prix, arrondie à 2 décimales)
-- Résultat obtenu   : 10.38.
-- Écart             : aucun (résultat brut 10.375, arrondi conformément
--                     au format DECIMAL(5,2) des prix).
-- ----------------------------------------------------------------------------
SELECT ROUND(AVG(prix), 2) AS prix_moyen_focaccia
FROM focaccia;


-- ----------------------------------------------------------------------------
-- Requête 4 : Afficher la liste des boissons avec leur marque, triée par
--             nom de boisson.
-- ----------------------------------------------------------------------------
-- Résultat attendu (12 lignes) : Capri-sun/Coca-cola, Coca-cola original/
-- Coca-cola, Coca-cola zéro/Coca-cola, Eau de source/Cristalline, Fanta
-- citron/Coca-cola, Fanta orange/Coca-cola, Lipton Peach/Pepsico, Lipton
-- zéro citron/Pepsico, Monster energy ultra blue/Monster, Monster energy
-- ultra gold/Monster, Pepsi/Pepsico, Pepsi Max Zéro/Pepsico.
-- Résultat obtenu   : conforme au résultat attendu.
-- Écart             : aucun.
-- ----------------------------------------------------------------------------
SELECT B.nom, M.nom
FROM boisson B
    INNER JOIN marque M ON B.id_marque = M.id_marque
ORDER BY B.nom ASC;


-- ----------------------------------------------------------------------------
-- Requête 5 : Afficher la liste des ingrédients pour une Raclaccia.
-- ----------------------------------------------------------------------------
-- Résultat attendu (7 lignes) : Ail, Base Tomate, Champignon, Cresson,
--                               Parmesan, Poivre, Raclette.
-- Résultat obtenu   : conforme au résultat attendu.
-- Écart             : aucun.
-- ----------------------------------------------------------------------------
SELECT I.nom
FROM ingredient I
    INNER JOIN comprend C ON I.id_ingredient = C.id_ingredient
    INNER JOIN focaccia F ON F.id_focaccia = C.id_focaccia
WHERE F.nom = 'Raclaccia';


-- ----------------------------------------------------------------------------
-- Requête 6 : Afficher le nom et le nombre d'ingrédients pour chaque
--             focaccia.
-- ----------------------------------------------------------------------------
-- Résultat attendu : Américaine=8, Emmentalaccia=7, Gorgonzollaccia=8, Hawaienne=9
--                    Mozaccia=10, Paysanne=12, Raclaccia=7 ,Tradizione=9.
-- Résultat obtenu   : conforme au résultat attendu.
-- Écart             : aucun.
-- ----------------------------------------------------------------------------
SELECT F.nom, COUNT(C.id_ingredient) AS nombre_ingredients
FROM focaccia F
INNER JOIN comprend C ON F.id_focaccia = C.id_focaccia
GROUP BY F.id_focaccia, F.nom
ORDER BY F.nom ASC;


-- ----------------------------------------------------------------------------
-- Requête 7 : Afficher le nom de la focaccia qui a le plus d'ingrédients.
-- ----------------------------------------------------------------------------
-- Résultat attendu : Paysanne (12 ingrédients).
-- Résultat obtenu   : conforme au résultat attendu.
-- Écart             : aucun.
-- ----------------------------------------------------------------------------
SELECT F.nom, COUNT(C.id_ingredient) AS nombre_ingredients
FROM focaccia F
INNER JOIN comprend C ON F.id_focaccia = C.id_focaccia
GROUP BY F.id_focaccia, F.nom
ORDER BY nombre_ingredients DESC
LIMIT 1;


-- ----------------------------------------------------------------------------
-- Requête 8 : Afficher la liste des focaccias qui contiennent de l'ail.
-- ----------------------------------------------------------------------------
-- Résultat attendu (4 lignes) : Mozaccia, Gorgonzollaccia, Raclaccia 
--                               Paysanne.
-- Résultat obtenu   : conforme au résultat attendu.
-- Écart             : aucun.
-- ----------------------------------------------------------------------------
SELECT DISTINCT F.nom
FROM focaccia F
INNER JOIN comprend C ON F.id_focaccia = C.id_focaccia
INNER JOIN ingredient I ON I.id_ingredient = C.id_ingredient
WHERE I.nom = 'Ail';


-- ----------------------------------------------------------------------------
-- Requête 9 : Afficher la liste des ingrédients inutilisés (c'est-à-dire
--             n'entrant dans la composition d'aucune focaccia).
-- ----------------------------------------------------------------------------
-- Résultat attendu (2 lignes) : Salami, Tomate cerise.
-- Résultat obtenu   : conforme au résultat attendu.
-- Écart             : aucun.
-- ----------------------------------------------------------------------------
SELECT I.nom
FROM ingredient I
LEFT JOIN comprend C ON I.id_ingredient = C.id_ingredient
WHERE C.id_ingredient IS NULL;


-- ----------------------------------------------------------------------------
-- Requête 10 : Afficher la liste des focaccias qui n'ont pas de
--              champignons.
-- ----------------------------------------------------------------------------
-- Résultat attendu (2 lignes) : Américaine, Hawaienne.
-- Résultat obtenu   : conforme au résultat attendu.
-- Écart             : aucun.
-- ----------------------------------------------------------------------------
SELECT F.nom
FROM focaccia F
WHERE F.id_focaccia NOT IN (
    SELECT C.id_focaccia
    FROM comprend C
        INNER JOIN ingredient I ON I.id_ingredient = C.id_ingredient
    WHERE I.nom = 'Champignon'
);
