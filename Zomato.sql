-- SHOW VARIABLES LIKE "secure_file_priv";
/* USD_Rate Tabel imported using TABLE DATA IMPORT WIZARD */
	SELECT * FROM usd_rate;
    
    drop table zomato;
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

----------------------------------------
-- Date Table
create view Date_Table as select year(datekey) as Year, 
		month(datekey) as Month , 
		monthname(datekey) As Month_Name,
		concat("Q",quarter(datekey)) as Quarter,
        date_format(datekey, '%Y-%b') as 'YYYY-MMM',
        dayofweek(datekey) as Day_of_week,
        dayname(datekey) as Dayname,
        
	case when monthname(datekey)='January' then 'FM10' 
	when monthname(datekey)='February' then 'FM11'
	when monthname(datekey)='March' then 'FM12'
	when monthname(datekey)='April'then'FM1'
	when monthname(datekey)='May' then 'FM2'
	when monthname(datekey)='June' then 'FM3'
	when monthname(datekey)='July' then 'FM4'
	when monthname(datekey)='August' then 'FM5'
	when monthname(datekey)='September' then 'FM6'
	when monthname(datekey)='October' then 'FM7'
	when monthname(datekey)='November' then 'FM8'
	when monthname(datekey)='December'then 'FM9'
	end Financial_month,
    
case when monthname(datekey) in ('January' ,'February' ,'March' )then 'Q4'
when monthname(datekey) in ('April' ,'May' ,'June' )then 'Q1'
when monthname(datekey) in ('July' ,'August' ,'September' )then 'Q2'
else  'Q3' end as financial_quarter
from zomato;


#Q Total number of Restaurants
select count(*) from zomato;

#Cost in USD
create view USD_Cost as select restaurantID,round((z.Average_cost_for_two*u.usd_rate),2) as Cost_USD
from zomato z
left join usd_rate u 
on u.currency=z.currency;

#No. of restaurants based on city and country
create view restaurants_by_city as select City,count(*) from zomato
	group by city;
create view restaurants_by_country as select c.CountryName,count(*) as No_Of_Restaurants 
from zomato z
left join country c
on z.countrycode=c.countryID
	group by c.countryname;
    
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


#Has Table booking, Has online delivery                                             
create view has_Table_booking as select has_table_booking, 
	count(has_table_booking) as No_of_Restaurants,
    concat(round((count(*)/(select count(*) from zomato)*100),2),'%')
		as '%_of_Restaurants'
	from zomato group by has_table_booking;
    
/* Alternate approach 
/* create view Table_booking as SELECT 
    CONCAT(COUNT(CASE
                WHEN Has_Table_Booking = 'Yes' THEN 1
                ELSE NULL
            END) * 100 / COUNT(*),
            '%') AS Percentage_With_Table_Booking
FROM
    zomato; */
    
create view Online_delivery as SELECT 
    CONCAT(COUNT(CASE
                WHEN Has_Online_delivery = 'Yes' THEN 1
                ELSE NULL
            END) * 100 / COUNT(*),
            '%') AS Percentage_With_Online_delivery
FROM
    zomato;
    
 #Price bucket
 create view Price_Bucket as 
	select 
		case when price_range=1 then "0-500" 
        when price_range=2 then "500-3000" 
        when Price_range=3 then "3000-10000" 
        when Price_range=4 then ">10000" 
        end price_range,count(restaurantid) as No_of_Restaurants
from zomato 
group by price_range
order by Price_range;
    
    
    
-- VIEWS
select * from  Date_table;
select * from USD_Cost;
select * from restaurants_by_country;
select * from restaurants_by_city;
select * from Table_booking;
select * from Online_delivery;
select * from Price_Bucket;
select * from has_table_booking;