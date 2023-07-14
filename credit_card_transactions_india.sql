-- Creating and using the schema

CREATE SCHEMA `credit_card_transaction_analysis` DEFAULT CHARACTER SET UTF8MB4;

USE `credit_card_transaction_analysis`; 

-- Data is imported through the table data import wizard
-- Path - /Users/mallikams/Documents/my_folder/Projects/Data_Projects/credit_card_spend/credit_card_transactions_india.sql

-- Data cleaning (DC)

-- DC 1. Changing the column names for convenience

SELECT * FROM credit_card_transactions_india;

ALTER TABLE credit_card_transactions_india
RENAME COLUMN `index` TO `id`;

ALTER TABLE credit_card_transactions_india
RENAME COLUMN `City` TO `city`;

ALTER TABLE credit_card_transactions_india
RENAME COLUMN `date` TO `tran_date`;

ALTER TABLE credit_card_transactions_india
RENAME COLUMN `Card Type` TO `card_type`;

ALTER TABLE credit_card_transactions_india
RENAME COLUMN `exp_type` TO `expense_type`;

ALTER TABLE credit_card_transactions_india
RENAME COLUMN `Gender` TO `gender`;

ALTER TABLE credit_card_transactions_india
RENAME COLUMN `Amount` TO `amount`;

SHOW FIELDS FROM credit_card_transactions_india;


SELECT * FROM credit_card_transactions_india;


-- DC 2. Trimming the columns

UPDATE `credit_card_transactions_india` SET `index` = TRIM(`index`);
UPDATE `credit_card_transactions_india` SET `city` = TRIM(`city`);
UPDATE `credit_card_transactions_india` SET `tran_date` = TRIM(`tran_date`);
UPDATE `credit_card_transactions_india` SET `card_type` = TRIM(`card_type`);
UPDATE `credit_card_transactions_india` SET `expense_type` = TRIM(`expense_type`);
UPDATE `credit_card_transactions_india` SET `gender` = TRIM(`gender`);
UPDATE `credit_card_transactions_india` SET `amount` = TRIM(`amount`);


SELECT * FROM credit_card_transactions_india;

-- DC 3. . Changing the format and then datatype (to DATE) of the tran_date column

-- DC 3A) Adding a column for tran_day and storing the day from the tran_date

ALTER TABLE credit_card_transactions_india
ADD COLUMN `tran_day`INT;

SELECT * FROM credit_card_transactions_india;



UPDATE credit_card_transactions_india
SET tran_day = substring_index(tran_date,'-',1);

SELECT * FROM credit_card_transactions_india;


-- DC 3B I) Adding a column for tran_month and storing the month from the tran_date


ALTER TABLE credit_card_transactions_india
ADD COLUMN `tran_month` INT;


SELECT * FROM credit_card_transactions_india;

-- DC 3B II) Changing the datatype from TEXT to VARCHAR so that digits can be stored

ALTER TABLE credit_card_transactions_india
MODIFY tran_month VARCHAR(10);


SELECT * FROM credit_card_transactions_india;

-- DC 3B III) Extracting the 3 letter month name

UPDATE credit_card_transactions_india
SET tran_month =
	CASE
		WHEN LENGTH(substring_index(tran_date,'-',1)) = 2 THEN RIGHT(substring_index(tran_date,'-',2),3)
        WHEN LENGTH(substring_index(tran_date,'-',1)) = 1 THEN RIGHT(substring_index(tran_date,'-',2),3)
	END;


SELECT * FROM credit_card_transactions_india;

-- DC 3B IV) Updating the digits for the respective months

UPDATE credit_card_transactions_india
SET tran_month =
	CASE
		WHEN tran_month = 'Jan' THEN 01
        WHEN tran_month = 'Feb' THEN 02
        WHEN tran_month = 'Mar' THEN 03
        WHEN tran_month = 'Apr' THEN 04
        WHEN tran_month = 'May' THEN 05
        WHEN tran_month = 'Jun' THEN 06
        WHEN tran_month = 'Jul' THEN 07
        WHEN tran_month = 'Aug' THEN 08
        WHEN tran_month = 'Sep' THEN 09
        WHEN tran_month = 'Oct' THEN 10
        WHEN tran_month = 'Nov' THEN 11
        WHEN tran_month = 'Dec' THEN 12
	END;

SELECT * FROM credit_card_transactions_india;

-- DC 3B IV) Adding a 0 for Jan to Sep months


UPDATE credit_card_transactions_india
SET tran_month =
	CASE
		WHEN LENGTH(tran_month) = 2 THEN tran_month
        WHEN LENGTH(tran_month) = 1 THEN CONCAT(0,tran_month)
	END;


SELECT * FROM credit_card_transactions_india;



-- DC 3C) Adding a column for tran_year and extracting year from tran_date

ALTER TABLE credit_card_transactions_india
ADD COLUMN `tran_year`INT;

SELECT * FROM credit_card_transactions_india;

UPDATE credit_card_transactions_india
SET tran_year = substring_index(tran_date,'-',-1);

SELECT * FROM credit_card_transactions_india;



-- DC 3D. Adding the prefix 20 in front of the year

UPDATE credit_card_transactions_india
SET tran_year = CONCAT('20',tran_year);

SELECT * FROM credit_card_transactions_india;

-- DC 3E. converting the date to the MySQL format - YYYY/MM/DD. 


UPDATE credit_card_transactions_india
SET tran_date = CONCAT(tran_year,'/',tran_month,'/',tran_day);

SELECT * FROM credit_card_transactions_india;



-- DC 3F. changing the datatype of the tran_date column to date

ALTER TABLE credit_card_transactions_india
MODIFY tran_date DATE;


SHOW FIELDS FROM credit_card_transactions_india;


SELECT * FROM credit_card_transactions_india;

-- DC 4. Removing ", India" from the city names


UPDATE credit_card_transactions_india
SET city =  REPLACE( city, ', India', ' ' );


UPDATE `credit_card_transactions_india`
SET `city` = TRIM(`city`);


SELECT * FROM credit_card_transactions_india;

-- DC 5.  SET id as primary KEY

ALTER TABLE credit_card_transactions_india
ADD PRIMARY KEY(`id`);

SELECT * FROM credit_card_transactions_india;


-- Data Analysis (DA)

-- DA Q1. - Write a query to print top 5 cities with highest spends 

SELECT
	city,
    SUM(amount) AS amt
FROM 
	credit_card_transactions_india
GROUP BY
	city
ORDER BY amt DESC
LIMIT 5;


-- DA Q2. Write a query to find the date range of the dataset

SELECT
	MIN(tran_date) AS min_date,
	MAX(tran_date) AS max_date
FROM 
	credit_card_transactions_india;

-- DA Q3. Write a query to find what is the maxmimum number of times the credit card types have been used for each city? 
-- Limit to 10 rows.

SELECT
	city,
COUNT(
	CASE
		WHEN card_type = 'Gold' THEN 1 
        ELSE NULL
	END
	   ) AS 'Gold', -- creates a pivot table with columns for gold, (in the following statements) silver, platinum, signature
COUNT(
	CASE
		WHEN card_type = 'Silver' THEN 1
        ELSE NULL
	END
	  ) AS 'Silver',
COUNT(
	CASE
		WHEN card_type = 'Signature' THEN 1
        ELSE NULL
	END
	  ) AS 'Signature',
COUNT(
	CASE
		WHEN card_type = 'Platinum' THEN 1
        ELSE NULL
	END
	  ) AS 'Platinum'
FROM
	credit_card_transactions_india
GROUP BY
	city
ORDER BY Gold DESC
LIMIT 10;

-- DA Q4. - Write a query to print highest spend month and amount spent in that month for each card type

SELECT
	card_type,
	tran_year,
    highest_spend_month,
    amount_spent
    
FROM 
(
	SELECT 
		card_type,
		tran_year,
		tran_month AS highest_spend_month,
		SUM(amount) AS amount_spent,
		RANK() OVER 
		(
			PARTITION BY
				card_type
			ORDER BY 
				SUM(amount) DESC
		
		) AS spend_rank -- the window function ranks the amount spent according to card type
	
    FROM 
		credit_card_transactions_india
	GROUP BY
		card_type,
        tran_year,
        highest_spend_month
)  AS highest_spend_rank -- the subquery creates a table which groups the partitions the data by card_type,
-- groups the data by card_type, tran_year, tran_month and orders the data by the highest amount first

WHERE spend_rank = 1
GROUP BY 
	card_type,
	tran_year,
    highest_spend_month
ORDER BY
    amount_spent DESC;


-- DA Q5. Write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type. 
-- (example format : Delhi , bills, Fuel)


-- to find the highest expense
WITH E_high AS
(
	SELECT
		city,
		expense_type,
		SUM(amount) AS total_amount,
		RANK() OVER (
			PARTITION BY city
			ORDER BY SUM(amount) DESC
			) AS highest_expense_type 
	FROM credit_card_transactions_india
	GROUP BY city, expense_type
),

-- to find the lowest expense

E_low AS
(
	SELECT
		city,
		expense_type,
		SUM(amount) AS total_amount,
		RANK() OVER (
			PARTITION BY city
			ORDER BY SUM(amount) ASC
			) AS lowest_expense_type
	FROM credit_card_transactions_india
	GROUP BY city, expense_type
)

-- collating these to ge the names of cities and the highest, lowest expenses

SELECT
	DISTINCT E_high.city,
	E_high.expense_type as highest_expense,
	E_low.expense_type as lowest_expense
FROM
	E_high,
    E_low
WHERE lowest_expense_type = 1
AND highest_expense_type = 1
AND E_high.city = E_low.city
ORDER BY city;


-- DA Q6. Which city took least number of days to reach its 500th transaction after first transaction in that city

SELECT * FROM credit_card_transactions_india;


WITH fivehun_tran_date AS (

SELECT
	*,
    ROW_NUMBER() OVER (
		PARTITION BY city
        ORDER BY tran_date) AS rn
FROM credit_card_transactions_india) -- to rank transactions according to each city from 1 to the max. num of transactions


SELECT
	city,
--     MIN(tran_date) AS first_tran_date,
--     MAX(tran_date) AS five_hundredth_tran_date,
    DATEDIFF(MAX(tran_date), MIN(tran_date)) AS days_to_500_transactions
	
FROM fivehun_tran_date
WHERE rn in (1,500)
GROUP BY city
HAVING COUNT(*) = 2
ORDER BY days_to_500_transactions ASC
LIMIT 1;

-- DA Q7. WAQ to find the credit card type with minimum expenditure, grouped by city

SELECT 
 	city,
	card_type, 
    expenses
FROM (  SELECT
 			city,
			card_type,
			SUM(amount) AS expenses,
             RANK() OVER
             (
 				PARTITION BY city
				ORDER BY SUM(amount) ASC
			 ) AS rnk_exp -- ranks the expenditure for each city from l,owest to highest
 		FROM
			credit_card_transactions_india
		GROUP BY 
			city,
            card_type
	 ) AS rnk_expenses
WHERE 
	rnk_exp = 1 -- to get the minimum value of expenditure for each city
GROUP BY
	city, card_type;


