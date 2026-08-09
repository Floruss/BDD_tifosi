-- ----------------------------------------------------------------------------
-- 1. CRÉATION DE LA BASE DE DONNÉES
-- ----------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS tifosi
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE tifosi;

-- ----------------------------------------------------------------------------
-- 2. CRÉATION DE L'UTILISATEUR DE LA BASE ET ATTRIBUTION DES DROITS
-- ----------------------------------------------------------------------------
CREATE USER IF NOT EXISTS 'tifosi'@'localhost' IDENTIFIED BY 'MotDePasseFort!2024';

GRANT ALL PRIVILEGES ON tifosi.* TO 'tifosi'@'localhost';

FLUSH PRIVILEGES;

-- ----------------------------------------------------------------------------
-- 3. SUPPRESSION DES TABLES SI ELLES EXISTENT DÉJÀ
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS contient;
DROP TABLE IF EXISTS achete;
DROP TABLE IF EXISTS comprend;
DROP TABLE IF EXISTS menu;
DROP TABLE IF EXISTS client;
DROP TABLE IF EXISTS boisson;
DROP TABLE IF EXISTS focaccia;
DROP TABLE IF EXISTS marque;
DROP TABLE IF EXISTS ingredient;

-- ----------------------------------------------------------------------------
-- 4. TABLES DE RÉFÉRENCE (entités "indépendantes" du MCD)
-- ----------------------------------------------------------------------------
-- Table INGREDIENT -----------------------------------------------------------
CREATE TABLE ingredient (
    id_ingredient INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nom VARCHAR(50) NOT NULL,
    CONSTRAINT pk_ingredient PRIMARY KEY (id_ingredient),
    CONSTRAINT uq_ingredient_nom UNIQUE (nom)
);

-- Table MARQUE ----------------------------------------------------------------
CREATE TABLE marque (
    id_marque INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nom VARCHAR(50) NOT NULL,
    CONSTRAINT pk_marque PRIMARY KEY (id_marque),
    CONSTRAINT uq_marque_nom UNIQUE (nom)
);

-- Table FOCACCIA --------------------------------------------------------------
CREATE TABLE focaccia (
    id_focaccia INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nom VARCHAR(50) NOT NULL,
    prix DECIMAL(5,2) NOT NULL,
    CONSTRAINT pk_focaccia PRIMARY KEY (id_focaccia),
    CONSTRAINT uq_focaccia_nom UNIQUE (nom),
    CONSTRAINT ck_focaccia_prix CHECK (prix > 0)
);

-- Table CLIENT ----------------------------------------------------------------
CREATE TABLE client (
    id_client INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nom VARCHAR(50) NOT NULL,
    email VARCHAR(150) NOT NULL,
    code_postal INT UNSIGNED NOT NULL,
    CONSTRAINT pk_client PRIMARY KEY (id_client),
    CONSTRAINT uq_client_email UNIQUE (email)
);

-- ----------------------------------------------------------------------------
-- 5. TABLE DÉPENDANTE : BOISSON
-- ----------------------------------------------------------------------------
-- Relation "appartient" : une boisson appartient à exactement une marque
-- (cardinalité 1,1 côté boisson) ; une marque possède 0 à n boissons.
-- => clé étrangère id_marque obligatoire.
-- ----------------------------------------------------------------------------
CREATE TABLE boisson (
    id_boisson INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nom VARCHAR(50) NOT NULL,
    id_marque INT UNSIGNED NOT NULL,
    CONSTRAINT pk_boisson PRIMARY KEY (id_boisson),
    CONSTRAINT uq_boisson_nom UNIQUE (nom),
    CONSTRAINT fk_boisson_marque
        FOREIGN KEY (id_marque) REFERENCES marque (id_marque)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- ----------------------------------------------------------------------------
-- 6. TABLE DÉPENDANTE : MENU
-- ----------------------------------------------------------------------------
-- Relation "est_constituee" : un menu est constitué d'exactement une focaccia
-- (cardinalité 1,1 côté menu) ; une focaccia peut entrer dans 0 à n menus.
-- => clé étrangère id_focaccia obligatoire.
-- ----------------------------------------------------------------------------
CREATE TABLE menu (
    id_menu INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nom VARCHAR(50) NOT NULL,
    prix DECIMAL(5,2) NOT NULL,
    id_focaccia INT UNSIGNED NOT NULL,
    CONSTRAINT pk_menu PRIMARY KEY (id_menu),
    CONSTRAINT uq_menu_nom UNIQUE (nom),
    CONSTRAINT ck_menu_prix CHECK (prix > 0),
    CONSTRAINT fk_menu_focaccia
        FOREIGN KEY (id_focaccia) REFERENCES focaccia (id_focaccia)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- ----------------------------------------------------------------------------
-- 7. TABLES DE JONCTION (relations plusieurs-à-plusieurs du MCD)
-- ----------------------------------------------------------------------------
-- Relation "comprend" (ingredient <--> focaccia), porteuse de l'attribut
CREATE TABLE comprend (
    id_focaccia INT UNSIGNED NOT NULL,
    id_ingredient INT UNSIGNED NOT NULL,
    quantite INT UNSIGNED NOT NULL,
    CONSTRAINT pk_comprend PRIMARY KEY (id_focaccia, id_ingredient),
    CONSTRAINT ck_comprend_quantite CHECK (quantite > 0),
    CONSTRAINT fk_comprend_focaccia
        FOREIGN KEY (id_focaccia) REFERENCES focaccia (id_focaccia)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_comprend_ingredient
        FOREIGN KEY (id_ingredient) REFERENCES ingredient (id_ingredient)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- Relation "achete" (client <--> menu), porteuse de l'attribut "date_achat"
CREATE TABLE achete (
    id_client INT UNSIGNED NOT NULL,
    id_menu INT UNSIGNED NOT NULL,
    date_achat DATE NOT NULL,
    CONSTRAINT pk_achete PRIMARY KEY (id_client, id_menu, date_achat),
    CONSTRAINT fk_achete_client
        FOREIGN KEY (id_client) REFERENCES client (id_client)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_achete_menu
        FOREIGN KEY (id_menu) REFERENCES menu (id_menu)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- Relation "contient" (menu <--> boisson) : boissons proposées avec un menu.
CREATE TABLE contient (
    id_menu         INT UNSIGNED    NOT NULL,
    id_boisson      INT UNSIGNED    NOT NULL,
    CONSTRAINT pk_contient PRIMARY KEY (id_menu, id_boisson),
    CONSTRAINT fk_contient_menu
        FOREIGN KEY (id_menu) REFERENCES menu (id_menu)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_contient_boisson
        FOREIGN KEY (id_boisson) REFERENCES boisson (id_boisson)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

