-- Databricks notebook source
-- DBTITLE 1,Cell 1
-------------------------------------------------------------------------
-- User_Profile Table
------------------------------------------------------------------------
-- to get an overview of how the data is recorded in the table before any analysis on it
SELECT * 
FROM `brightlearn`.`bright_tv`.`user_profile` 
LIMIT 10;

-- how big is the data 
SELECT COUNT (*) AS num_rows,
        COUNT (DISTINCT UserID) AS num_subscribers
FROM `brightlearn`.`bright_tv`.`user_profile`;

-- checking for duplicates
SELECT  UserID,
        COUNT (*) AS count_duplicates
FROM `brightlearn`.`bright_tv`.`user_profile`
GROUP BY UserID
HAVING COUNT (*) >1;

-- Checking if there is any row where userID is NULL
SELECT COUNT (*) AS COUNT_NULL
FROM `brightlearn`.`bright_tv`.`user_profile`
WHERE UserID IS NULL; 
---------------------------------------------------
-- Checking and correcting the various genders
---------------------------------------------------
SELECT DISTINCT gender
FROM `brightlearn`.`bright_tv`.`user_profile`;

SELECT COUNT(*)
FROM `brightlearn`.`bright_tv`.`user_profile`
WHERE gender = ' ';

SELECT COUNT (DISTINCT UserID) AS subscribers,
    CASE
        WHEN gender = ' ' THEN 'Unknown'
        WHEN gender = 'None' THEN 'Unknown'
        ELSE gender
    END AS gender_gp
FROM `brightlearn`.`bright_tv`.`user_profile`
GROUP BY gender_gp; 
------------------------------------------------
-- Checking and correcting the various race
------------------------------------------------
SELECT DISTINCT Race
FROM `brightlearn`.`bright_tv`.`user_profile`;

SELECT
    COUNT (DISTINCT UserID) AS Subs_per_race,
    CASE
        WHEN Race = 'other' THEN 'None'
             WHEN Race = ' ' THEN 'None'
        ELSE Race
    END AS Race_New
FROM `brightlearn`.`bright_tv`.`user_profile`
GROUP BY Race_New; 

------------------------------------------------
-- Checking and correcting the Province
------------------------------------------------
SELECT DISTINCT Province
FROM `brightlearn`.`bright_tv`.`user_profile`;

SELECT DISTINCT 
    CASE
        WHEN Province = ' ' THEN 'Uncategorized'
        WHEN Province = 'None' THEN 'Uncategorized'
        ELSE Province
    END AS Region
FROM `brightlearn`.`bright_tv`.`user_profile`;
------------------------------------------------
-- Checking and correcting the Age
------------------------------------------------
SELECT MIN (Age) As Min_age, ---= 0
        MAX (Age) AS Max_age, ---= 114
        AVG (Age) AS Average_age ---= 28
FROM `brightlearn`.`bright_tv`.`user_profile`;

SELECT COUNT(*) AS Count_Null
FROM `brightlearn`.`bright_tv`.`user_profile`
WHERE Age IS NULL;

SELECT COUNT(DISTINCT UserID) AS Subs_Count,
    CASE
        WHEN age BETWEEN 0 AND 4 THEN 'Infant'
        WHEN age BETWEEN 5 AND 12 THEN 'Child'
        WHEN age BETWEEN 13 AND 18 THEN 'Teenager'
        WHEN age BETWEEN 19 AND 35 THEN 'Youth'
        WHEN age BETWEEN 36 AND 59 THEN 'Adult'
        WHEN age BETWEEN 60 AND 74 THEN 'Senior'
        WHEN age >= 75 THEN 'Elderly'
    END AS age_group
FROM `brightlearn`.`bright_tv`.`user_profile`
GROUP BY age_group; 

------------------------------------------------
-- Combining all exploratory data query from user profile into one query
------------------------------------------------

WITH user_profile AS (
SELECT UserID,
    CASE
        WHEN gender = ' ' THEN 'Unknown'
        WHEN gender = 'None' THEN 'Unknown'
        ELSE gender
    END AS Gender_gp,

    CASE
        WHEN Race = 'other' THEN 'None'
             WHEN Race = ' ' THEN 'None'
        ELSE Race
    END AS Race_New,

    CASE
        WHEN Province = ' ' THEN 'Uncategorized'
        WHEN Province = 'None' THEN 'Uncategorized'
        ELSE Province
    END AS Region,

    CASE
        WHEN age BETWEEN 0 AND 4 THEN 'Infant'
        WHEN age BETWEEN 5 AND 12 THEN 'Child'
        WHEN age BETWEEN 13 AND 18 THEN 'Teenager'
        WHEN age BETWEEN 19 AND 35 THEN 'Youth'
        WHEN age BETWEEN 36 AND 59 THEN 'Adult'
        WHEN age BETWEEN 60 AND 74 THEN 'Senior'
        WHEN age >= 75 THEN 'Elderly'
    END AS Age_group,

    CASE
        WHEN (Email IS NOT NULL) AND (email != ' ') AND (email != 'None') THEN 1
        ELSE 0
    END AS Email_flag,

    CASE
        WHEN (`Social Media Handle` IS NOT NULL) AND (`Social Media Handle` != ' ') AND (`Social Media Handle` != 'None') THEN 1
        ELSE 0
    END AS social_media_flag

FROM `brightlearn`.`bright_tv`.`user_profile`
)

SELECT *
FROM user_profile;

-- COMMAND ----------

-- DBTITLE 1,Cell 3
-- ---------------------------------------------
-- viewership table
-----------------------------------------------

-- overview of the viewership table
SELECT *
FROM brightlearn.bright_tv.viewership
LIMIT 10;

----------------------------------------------
-- verifying total subscriber and comparing active subs and active users
----------------------------------------------
SELECT  COUNT (*) AS total_sub,
        COUNT(COALESCE (UserID0, userid4)) AS active_subs,
        COUNT(DISTINCT COALESCE (UserID0, userid4)) AS active_users
FROM brightlearn.bright_tv.viewership;

-----------------------------------------------
-- checking the channel names and correcting errors
-----------------------------------------------
SELECT DISTINCT Channel2
FROM brightlearn.bright_tv.viewership;

SELECT DISTINCT
    CASE 
        WHEN Channel2 IN ('SawSee', 'Sawsee') THEN 'SawSee'
        WHEN Channel2 IN ('Supersport Live Events', 'Live on SuperSport', 'SuperSport Live Events', 'DStv Events 1') THEN 'Live Events'
        WHEN Channel2 = 'E! Entertainment' THEN 'Entertainment'
        ELSE Channel2
    END AS TV_Channel
FROM brightlearn.bright_tv.viewership;

-----------------------------------------------
-- TIME FUNCTION ON RECORD DATE
-----------------------------------------------

SELECT
    COALESCE (UserID0, userid4) AS userid,
    TO_CHAR(RecordDate2, 'yyyymm') AS Month_id,
    To_DATE(RecordDate2) AS watch_date,
    TO_CHAR(RecordDate2, 'dd') AS day_of_week,

    DAYNAME(RecordDate2) AS day_name,
    CASE
        WHEN day_name IN ('Sat', 'Sun') THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_class,

    MONTHNAME(RecordDate2) AS month_name,

    date_format(RecordDate2, 'hh:mm:ss') AS watch_time,
    HOUR(RecordDate2) AS hour_of_day,
    date_format(`Duration 2`, 'hh:mm:ss') AS watch_time,

    CASE 
        WHEN Channel2 IN ('SawSee', 'Sawsee') THEN 'SawSee'
        WHEN Channel2 IN ('Supersport Live Events', 'Live on SuperSport', 'SuperSport Live Events', 'DStv Events 1') THEN 'Live Events'
        WHEN Channel2 = 'E! Entertainment' THEN 'Entertainment'
        ELSE Channel2
    END AS TV_Channel

 FROM brightlearn.bright_tv.viewership
 LIMIT 5;


-- COMMAND ----------

----------------------------------------------------
-- Combining the viewership table witht the user_profile table
----------------------------------------------------

----------------------------------------------------
-- Viewership table
----------------------------------------------------

WITH viewership AS (
SELECT
    COALESCE (UserID0, userid4) AS userid,

    CASE 
        WHEN Channel2 IN ('SawSee', 'Sawsee') THEN 'SawSee'
        WHEN Channel2 IN ('Supersport Live Events', 'Live on SuperSport', 'SuperSport Live Events', 'DStv Events 1') THEN 'Live Events'
        WHEN Channel2 = 'E! Entertainment' THEN 'Entertainment'
        ELSE Channel2
    END AS TV_Channel,

    TO_CHAR(RecordDate2, 'yyyymm') AS Month_id,
     MONTHNAME(RecordDate2) AS month_name,

    To_DATE(RecordDate2) AS watch_date,
    TO_CHAR(RecordDate2, 'dd') AS day_of_week,
    DAYNAME(RecordDate2) AS day_name,
    CASE
        WHEN day_name IN ('Sat', 'Sun') THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_class,

    HOUR(RecordDate2) AS hour_of_day,
    date_format(RecordDate2, 'hh:mm:ss') AS watch_time,
    date_format(`Duration 2`, 'hh:mm:ss') AS duration

 FROM brightlearn.bright_tv.viewership
),

------------------------------------------------------------------------------
-- User_profile table
------------------------------------------------------------------------------
user_profile AS (
SELECT UserID,
    CASE
        WHEN gender = ' ' THEN 'Unknown'
        WHEN gender = 'None' THEN 'Unknown'
        ELSE gender
    END AS Gender_gp,

    CASE
        WHEN Race = 'other' THEN 'None'
             WHEN Race = ' ' THEN 'None'
        ELSE Race
    END AS Race_New,

    CASE
        WHEN Province = ' ' THEN 'Uncategorized'
        WHEN Province = 'None' THEN 'Uncategorized'
        ELSE Province
    END AS Region,

    CASE
        WHEN age BETWEEN 0 AND 4 THEN 'Infant'
        WHEN age BETWEEN 5 AND 12 THEN 'Child'
        WHEN age BETWEEN 13 AND 18 THEN 'Teenager'
        WHEN age BETWEEN 19 AND 35 THEN 'Youth'
        WHEN age BETWEEN 36 AND 59 THEN 'Adult'
        WHEN age BETWEEN 60 AND 74 THEN 'Senior'
        WHEN age >= 75 THEN 'Elderly'
    END AS Age_group,

    CASE
        WHEN (Email IS NOT NULL) AND (email != ' ') AND (email != 'None') THEN 1
        ELSE 0
    END AS Email_flag,

    CASE
        WHEN (`Social Media Handle` IS NOT NULL) AND (`Social Media Handle` != ' ') AND (`Social Media Handle` != 'None') THEN 1
        ELSE 0
    END AS social_media_flag

FROM `brightlearn`.`bright_tv`.`user_profile`
)

-----------------------------------------------------------------------------------------------------------------
-- Using a left Join to combined the tables
----------------------------------------------------------------------------------------------------------------
SELECT *
FROM viewership AS v
LEFT JOIN user_profile AS u
ON v.userid = u.UserID
;


