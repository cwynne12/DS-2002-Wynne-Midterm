

CREATE DATABASE `sakila_dw` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

use sakila_dw; 

CREATE TABLE `dim_customer` (
  `customer_key` int NOT NULL AUTO_INCREMENT,
  `customer_id` smallint unsigned NOT NULL ,
  `store_id` tinyint unsigned NOT NULL,
  `first_name` varchar(45) NOT NULL,
  `last_name` varchar(45) NOT NULL,
  `email` varchar(50) DEFAULT NULL,
  `address_id` smallint  NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `create_date` datetime NOT NULL,
  `last_update` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`customer_key`),
  KEY  `customer_id` (  `customer_id`), 
  KEY `idx_fk_store_id` (`store_id`),
  KEY `idx_fk_address_id` (`address_id`),
  KEY `idx_last_name` (`last_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `dim_inventory` (
  `inventory_key`int NOT NULL AUTO_INCREMENT, 
  `inventory_id` mediumint unsigned NOT NULL,
  `film_id` smallint unsigned NOT NULL,
  `store_id` tinyint unsigned NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`inventory_key`),
  KEY `idx_fk_film_id` (`film_id`),
  KEY `idx_store_id_film_id` (`store_id`,`film_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `dim_film` (
  `film_key` int NOT NULL AUTO_INCREMENT, 
  `film_id` smallint unsigned NOT NULL ,
  `title` varchar(128) NOT NULL,
  `description` text,
  `release_year` year DEFAULT NULL,
  `language_id` tinyint unsigned NOT NULL,
  `original_language_id` tinyint unsigned DEFAULT NULL,
  `rental_duration` tinyint unsigned NOT NULL DEFAULT '3',
  `rental_rate` decimal(4,2) NOT NULL DEFAULT '4.99',
  `length` smallint unsigned DEFAULT NULL,
  `replacement_cost` decimal(5,2) NOT NULL DEFAULT '19.99',
  `rating` enum('G','PG','PG-13','R','NC-17') DEFAULT 'G',
  `special_features` set('Trailers','Commentaries','Deleted Scenes','Behind the Scenes') DEFAULT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`film_key`),
  KEY `idx_title` (`title`),
  KEY `idx_fk_language_id` (`language_id`),
  KEY `idx_fk_original_language_id` (`original_language_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `dim_payment` (
  `payment_key` int NOT NULL AUTO_INCREMENT, 
  `payment_id` smallint unsigned NOT NULL,
  `customer_id` smallint unsigned NOT NULL,
  `staff_id` tinyint unsigned NOT NULL,
  `rental_id` int DEFAULT NULL,
  `amount` decimal(5,2) NOT NULL,
  `payment_date` datetime NOT NULL,
  `last_update` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`payment_key`),
  KEY `idx_fk_staff_id` (`staff_id`),
  KEY `idx_fk_customer_id` (`customer_id`),
  KEY `fk_payment_rental` (`rental_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `dim_category` (
 `category_key` int NOT NULL AUTO_INCREMENT, 
 `category_id` tinyint unsigned NOT NULL,
  `name` varchar(25) NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`category_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `dim_store` (
  `store_key` int NOT NULL AUTO_INCREMENT, 
  `store_id` tinyint unsigned NOT NULL ,
  `manager_staff_id` tinyint unsigned NOT NULL,
  `address_id` smallint unsigned NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`store_key`),
  UNIQUE KEY `idx_unique_manager` (`manager_staff_id`),
  KEY `idx_fk_address_id` (`address_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `dim_address` (
  `address_key` int NOT NULL AUTO_INCREMENT, 
  `address_id` smallint unsigned NOT NULL ,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL /*!80003 SRID 0 */,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_key`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

## now want to create fact table

CREATE TABLE `fact_rental` (
  `fact_rental_key` int NOT NULL AUTO_INCREMENT,
  `rental_id` int NOT NULL,
  `rental_date` datetime NOT NULL,
  `inventory_id` mediumint unsigned NOT NULL,
  `return_date` datetime NOT NULL, 
  `customer_id` smallint unsigned NOT NULL, 
  `amount` decimal(5,2) NOT NULL,
  PRIMARY KEY (`fact_rental_key`),
  KEY `idx_fk_inventory_id` (`inventory_id`),
  KEY `idx_fk_customer_id` (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



##### SELECT AND INSERT DATA INTO TABLES 

#ADDRESS
TRUNCATE TABLE sakila_dw.dim_address;

INSERT INTO `sakila_dw`.`dim_address`
(`address_id`,
`address`,
`address2`,
`district`,
`city_id`,
`postal_code`,
`phone`,
`location`,
`last_update`) 
SELECT 
`address_id`,
`address`,
`address2`,
`district`,
`city_id`,
`postal_code`,
`phone`,
`location`,
`last_update`
FROM `sakila`.`address`;

SELECT * FROM sakila_dw.dim_address; 


#CATEGORY  
TRUNCATE TABLE sakila_dw.dim_category;
INSERT INTO `sakila_dw`.`dim_category`
(`category_id`,
`name`,
`last_update`)
SELECT `category`.`category_id`,
    `category`.`name`,
    `category`.`last_update`
FROM `sakila`.`category`;
SELECT * FROM sakila_dw.dim_category; 

# FILM 
INSERT INTO `sakila_dw`.`dim_film`
(`film_id`,
`title`,
`description`,
`release_year`,
`language_id`,
`original_language_id`,
`rental_duration`,
`rental_rate`,
`length`,
`replacement_cost`,
`rating`,
`special_features`,
`last_update`)
SELECT `film`.`film_id`,
    `film`.`title`,
    `film`.`description`,
    `film`.`release_year`,
    `film`.`language_id`,
    `film`.`original_language_id`,
    `film`.`rental_duration`,
    `film`.`rental_rate`,
    `film`.`length`,
    `film`.`replacement_cost`,
    `film`.`rating`,
    `film`.`special_features`,
    `film`.`last_update`
FROM `sakila`.`film`;

SELECT * FROM sakila_dw.dim_film; 

#CUSTOMER
TRUNCATE TABLE sakila_dw.dim_customer; 
INSERT INTO `sakila_dw`.`dim_customer`
(`customer_id`,
`store_id`,
`first_name`,
`last_name`,
`email`,
`address_id`,
`active`,
`create_date`,
`last_update`)
SELECT `customer`.`customer_id`,
    `customer`.`store_id`,
    `customer`.`first_name`,
    `customer`.`last_name`,
    `customer`.`email`,
    `customer`.`address_id`,
    `customer`.`active`,
    `customer`.`create_date`,
    `customer`.`last_update`
FROM `sakila`.`customer`;
SELECT * FROM sakila_dw.dim_customer; 


#INVENTORY 
TRUNCATE TABLE sakila_dw.dim_inventory; 
INSERT INTO `sakila_dw`.`dim_inventory`
(`inventory_id`,
`film_id`,
`store_id`,
`last_update`)
SELECT `inventory`.`inventory_id`,
    `inventory`.`film_id`,
    `inventory`.`store_id`,
    `inventory`.`last_update`
FROM `sakila`.`inventory`;
SELECT * FROM sakila_dw.dim_inventory ; 

#PAYMENT
TRUNCATE TABLE sakila_dw.dim_payment; 
INSERT INTO `sakila_dw`.`dim_payment`
(`payment_id`,
`customer_id`,
`staff_id`,
`rental_id`,
`amount`,
`payment_date`,
`last_update`)
SELECT `payment`.`payment_id`,
    `payment`.`customer_id`,
    `payment`.`staff_id`,
    `payment`.`rental_id`,
    `payment`.`amount`,
    `payment`.`payment_date`,
    `payment`.`last_update`
FROM `sakila`.`payment`;

SELECT * FROM sakila_dw.dim_payment; 

#STORE 
TRUNCATE TABLE sakila_dw.dim_store; 
INSERT INTO `sakila_dw`.`dim_store`
(`store_id`,
`manager_staff_id`,
`address_id`,
`last_update`)
SELECT `store`.`store_id`,
    `store`.`manager_staff_id`,
    `store`.`address_id`,
    `store`.`last_update`
FROM `sakila`.`store`;
SELECT * FROM sakila_dw.dim_store; 

# insert into fact table 

INSERT INTO `sakila_dw`.`fact_rental`
(`rental_id`
,`rental_date`
,`inventory_id`
,`customer_id`
, `amount`
, `return_date`
)
SELECT
r.rental_id AS RentalID
, r.rental_date 
, i.inventory_id 
, r.customer_id 
, p.amount AS Amount
, r.return_date
FROM sakila.rental as r 
RIGHT OUTER JOIN sakila.payment as p
ON r.rental_id = p.rental_id
INNER JOIN sakila.inventory as i
ON r.inventory_id = i.inventory_id
WHERE r.return_date IS NOT NULL; 


#Validate 

SELECT * FROM sakila_dw.fact_rental; 








