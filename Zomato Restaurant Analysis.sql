/*
 Q1. Build a Data Model using the Sheets in the Excel File
 */
CREATE DATABASE ZOMATO;
use ZOMATO;
select*from zomata;
select*from zomata_sql ;
select*from zomata_sqll ;

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
CREATE TABLE Calendar (
    DateKey DATE ,
    Year INT,
    MonthNo INT,
    MonthFullName VARCHAR(20),
    Quarter VARCHAR(5),
    YearMonth VARCHAR(8),
    WeekdayNo INT,
    WeekdayName VARCHAR(20),
    FinancialMonth INT,
    FinancialQuarter INT
);
INSERT INTO Calendar (DateKey, Year, MonthNo, MonthFullName, Quarter, YearMonth, WeekdayNo, WeekdayName, FinancialMonth, FinancialQuarter)
SELECT
    Datekey_Opening AS DateKey,
    YEAR(Datekey_Opening) AS Year,
    MONTH(Datekey_Opening) AS MonthNo,
    MONTHNAME(Datekey_Opening) AS MonthFullName,
    CONCAT('Q', QUARTER(Datekey_Opening)) AS Quarter,
    CONCAT(YEAR(Datekey_Opening), '-', LPAD(MONTH(Datekey_Opening), 2, '0')) AS YearMonth,
    DAYOFWEEK(Datekey_Opening) AS WeekdayNo,
    DAYNAME(Datekey_Opening) AS WeekdayName,
    IF(MONTH(Datekey_Opening) < 4, MONTH(Datekey_Opening) + 8, MONTH(Datekey_Opening) - 3) AS FinancialMonth,
    IF(MONTH(Datekey_Opening) < 4, QUARTER(Datekey_Opening) + 3, QUARTER(Datekey_Opening) - 1) AS FinancialQuarter
FROM zomata;
select*from Calendar;

/*
Q3. Convert the Average cost for 2 column into USD dollars (currently the Average cost for 2 in local currencies
*/
SELECT
    z.Average_Cost_for_two,
    z.Currency,
    z.Average_Cost_for_two * e.USD_Rate AS Average_Cost_for_two_USD
FROM
    zomata z
JOIN
    zomata_sqll e ON z.Currency = e.Currency;

/*
Q4.Find the Numbers of Resturants based on City and Country.
*/
SELECT
    z.City,
    s.Countryname,
    (SELECT COUNT(*) FROM zomata WHERE City = z.City) AS NumRestaurants
FROM
    (SELECT DISTINCT City FROM zomata) z
CROSS JOIN
    (SELECT DISTINCT Countryname FROM zomata_sql) s
GROUP BY
    z.city,
    s.countryname;

/*
Q5.Numbers of Resturants opening based on Year , Quarter , Month
*/
SELECT
    YEAR(c.DateKey) AS Year,
    QUARTER(c.DateKey) AS Quarter,
    MONTH(c.DateKey) AS Month,
    COUNT(*) AS NumOpenings
FROM
    zomata z
JOIN
    calendar c ON z.Datekey_Opening = c.DateKey
GROUP BY
    YEAR(c.DateKey),
    QUARTER(c.DateKey),
    MONTH(c.DateKey);

/*
Q6. Count of Resturants based on Average Ratings
*/
SELECT
    ROUND(AVG(Rating), 1) AS AvgRating,
    COUNT(*) AS NumRestaurants
FROM
    zomata
GROUP BY
    ROUND(Rating, 1);

/*
Q7. Create buckets based on Average Price of reasonable size and find out how many resturants falls in each buckets
*/
SELECT
    CASE
        WHEN Average_Cost_for_two <= 20 THEN 'Low'
        WHEN Average_Cost_for_two > 20 AND Average_Cost_for_two <= 50 THEN 'Medium'
        WHEN Average_Cost_for_two > 50 AND Average_Cost_for_two <= 100 THEN 'High'
        ELSE 'Very High'
    END AS PriceBucket,
    COUNT(*) AS NumRestaurants
FROM
    zomata
GROUP BY
    PriceBucket;

/*
Q8.Percentage of Resturants based on "Has_Table_booking"
*/
SELECT
    Has_Table_booking,
    COUNT(*) AS NumRestaurants,
    (COUNT(*) / (SELECT COUNT(*) FROM zomata)) * 100 AS Percentage
FROM
    zomata
GROUP BY
    Has_Table_booking;

/*
Q9.Percentage of Resturants based on "Has_Online_delivery"
*/
SELECT
    Has_Online_delivery,
    COUNT(*) AS NumRestaurants,
    (COUNT(*) / (SELECT COUNT(*) FROM zomata)) * 100 AS Percentage
FROM
    zomata
GROUP BY
    Has_Online_delivery;

/*
10. Develop Charts based on Cusines, City, Ratings ( Candidate have to think about new KPI to analyse)
*/
-- 1>Cuisines Analysis:
SELECT Cuisines, COUNT(*) AS NumRestaurants
FROM zomata
GROUP BY Cuisines
ORDER BY NumRestaurants DESC
LIMIT 10;

-- 2> City Analysis
SELECT City, COUNT(*) AS NumRestaurants
FROM zomata
GROUP BY City
ORDER BY NumRestaurants DESC
LIMIT 10;

-- 3> Rating Analysis
SELECT Rating, COUNT(*) AS NumRestaurants
FROM zomata
GROUP BY Rating;
