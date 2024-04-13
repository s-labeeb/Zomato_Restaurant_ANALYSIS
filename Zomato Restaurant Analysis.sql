-- SHOW VARIABLES LIKE "secure_file_priv";
/* USD_Rate Tabel imported using TABLE DATA IMPORT WIZARD */
SELECT * FROM usd_rate;

/* IMPORTING COUNTRY TABLE from Excel */

create table Country
(
CountryId int,
CountryName varchar(50)
);

Load data infile 'Zomato_Country.csv' into table country
fields terminated by ',' /*.csv file*/
Ignore 1 lines; 	/*First line of Excel file Contains Headers */

select * from country;

/* IMPORTING MAIN TABLE (Restaurant info.) from Excel*/

create table Zomato 
(
RestaurantID bigint,
restaurantName varchar(100),
CountryCode int,
city varchar(50),
Locality varchar(50),
Cuisines varchar(100),
Currency varchar(50),
Has_table_booking varchar (50),
Has_online_delivery varchar(50),
Is_delivering_now varchar(50),
Price_range int,
Votes int,
Average_Cost_for_two int,
Rating double,
Datekey date
);
select count(*) from zomato;

LOAD DATA INFILE 'Zomato_.csv' Into Table Zomato
fields terminated by ','
Ignore 1 lines;

#Q Total number of Restaurants
select count(*) from zomato;

/*Q2. Build a Calendar Table using the Columns Datekey_Opening ( Which has Dates from Minimum Dates and Maximum Dates)
  Add all the below Columns in the Calendar Table using the Formulas.
   A.Year
   B.Monthno
   C.Monthfullname
   D.Quarter(Q1,Q2,Q3,Q4)
   E. YearMonth ( YYYY-MMM)
   F. Weekdayno
   G.Weekdayname
   H.FinancialMOnth ( April = FM1, May= FM2  …. March = FM12)
   I. Financial Quarter ( Quarters based on Financial Month FQ-1 . FQ-2..)
   */

create view Date_Table as
SELECT
    Datekey_Opening AS DateKey,
    YEAR(Datekey_Opening) AS Year,
    MONTH(Datekey_Opening) AS MonthNo,
    MONTHNAME(Datekey_Opening) AS Month_Name,
    CONCAT('Q', QUARTER(Datekey_Opening)) AS Quarter,
   date_format(datekey, '%Y-%b') as YearMonth,
    DAYOFWEEK(Datekey_Opening) AS WeekdayNo,
    DAYNAME(Datekey_Opening) AS WeekdayName,
    IF(MONTH(Datekey_Opening) < 4, MONTH(Datekey_Opening) + 8, MONTH(Datekey_Opening) - 3) AS FinancialMonth,
    IF(MONTH(Datekey_Opening) < 4, QUARTER(Datekey_Opening) + 3, QUARTER(Datekey_Opening) - 1) AS FinancialQuarter
FROM zomato;


/*
Q3. Convert the Average cost for 2 columns into USD dollars (currently the Average cost for 2 in local currencies
*/
create view 
  USD_Cost as 
select restaurantID,round((z.Average_cost_for_two*u.usd_rate),2) as Cost_USD
from zomato z
left join usd_rate u 
on u.currency=z.currency;

/*
Q4.Find the Numbers of Restaurants based on City and Country.
*/
create view 
  restaurants_by_city as 
  select City,count(*) as No_Of_Restaurants from zomato
	group by city;

create view restaurants_by_country 
  as select c.CountryName,count(*) as No_Of_Restaurants 
from zomato z
left join country c
on z.countrycode=c.countryID
	group by c.countryname;

/*
Q5.Numbers of restaurants opening based on Year, Quarter, Month
*/
#Opening year
SELECT YEAR(Datekey) AS Year, COUNT(*) AS Yearwise_Restaurants_Opening
FROM zomato
GROUP BY YEAR(Datekey);


#Opening month
SELECT Monthname(Datekey) AS Month, COUNT(*) AS Monthwise_Restaurants_Opening
FROM zomato
GROUP BY monthname(Datekey);


#Opening Quarter
SELECT Quarter(Datekey) AS Quarter, COUNT(*) AS Quarterwise_Restaurants_Opening
FROM zomato
GROUP BY Quarter(Datekey);

/*
Q6. Count of Restaurants based on Average Ratings
*/
SELECT
    ROUND(AVG(Rating), 1) AS AvgRating,
    COUNT(*) AS NumRestaurants
FROM
    zomato
GROUP BY
    ROUND(Rating, 1);

/*
Q7. Create buckets based on Average Price of reasonable size and find out how many restaurants fall in each bucket
*/
create view Price_Bucket as
SELECT
    CASE
        WHEN Average_Cost_for_two <= 20 THEN 'Low'
        WHEN Average_Cost_for_two > 20 AND Average_Cost_for_two <= 50 THEN 'Medium'
        WHEN Average_Cost_for_two > 50 AND Average_Cost_for_two <= 100 THEN 'High'
        ELSE 'Very High'
    END AS PriceBucket,
    COUNT(*) AS NumRestaurants
FROM
    zomato
GROUP BY
    PriceBucket;

/*
Q8.Percentage of Restaurants based on "Has_Table_booking"
*/
create view has_Table_booking as 
  select has_table_booking, 
	count(has_table_booking) as No_of_Restaurants,
    concat(round((count(*)/(select count(*) from zomato)*100),2),'%')
		as '%_of_Restaurants'
	from zomato group by has_table_booking;
    
-- Alternate approach 
/* create view Table_booking as SELECT 
    CONCAT(COUNT(CASE
                WHEN Has_Table_Booking = 'Yes' THEN 1
                ELSE NULL
            END) * 100 / COUNT(*),
            '%') AS Percentage_With_Table_Booking
FROM
    zomato; */
    

/* Q9.Percentage of Restaurants based on "Has_Online_delivery" */

SELECT
    Has_Online_delivery,
    COUNT(*) AS NumRestaurants,
    (COUNT(*) / (SELECT COUNT(*) FROM zomato)) * 100 AS Percentage
FROM
    zomato
GROUP BY
    Has_Online_delivery;

/*
KPI to analyse)
*/
-- 1>Cuisines Analysis:
SELECT Cuisines, COUNT(*) AS NumRestaurants
FROM zomato
GROUP BY Cuisines
ORDER BY NumRestaurants DESC
LIMIT 10;

-- 2> City Analysis
SELECT City, COUNT(*) AS NumRestaurants
FROM zomato
GROUP BY City
ORDER BY NumRestaurants DESC
LIMIT 10;

-- 3> Rating Analysis
SELECT Rating, COUNT(*) AS NumRestaurants
FROM zomato
GROUP BY Rating;

-- VIEWS
select * from  Date_table;
select * from USD_Cost;
select * from restaurants_by_country;
select * from restaurants_by_city;
select * from Table_booking;
select * from Online_delivery;
select * from Price_Bucket;
select * from has_table_booking;
