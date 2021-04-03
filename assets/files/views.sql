--BEGIN TRANSACTION
    DROP VIEW IF EXISTS distinctListings;
    CREATE VIEW distinctListings(COUNT) as 
        SELECT COUNT(*) from (SELECT id from listings2015 
        union SELECT id from listings2017 
        union SELECT id from listings2019) ;

    --cleaning
    DROP VIEW IF EXISTS processedDatePriceAvailable15;
    CREATE VIEW processedDatePriceAvailable15(listing_id, available, price, month, year, date, neighbourhood, neighbourhood_cleansed, rating) as 
        select c.listing_id, 
            case c.available when 't' then 1 else 0 end as available,  
            cast(substr(l.price, 2) as integer)*(available - 1)*(-1) as price,
            substr(date, 6, 2) as month,
            substr(date, 1, 4) as year,
            date, 
            neighbourhood,
            neighbourhood_cleansed,
            review_scores_rating from calendar2015 as c inner join listings2015 as l on c.listing_id = l.id;
    DROP VIEW IF EXISTS processedDatePriceAvailable17;
    CREATE VIEW processedDatePriceAvailable17(listing_id, available, price, month, year, date, neighbourhood, neighbourhood_cleansed, rating) as 
        select c.listing_id, 
            case c.available when 't' then 1 else 0 end as available,  
            cast(substr(l.price, 2) as integer)*(available - 1)*(-1) as price,
            substr(date, 6, 2) as month,
            substr(date, 1, 4) as year,
            date,
            neighbourhood, 
            neighbourhood_cleansed,
            review_scores_rating  from calendar2017 as c inner join listings2017 as l on c.listing_id = l.id;
    DROP VIEW IF EXISTS processedDatePriceAvailable19;
    CREATE VIEW processedDatePriceAvailable19(listing_id, available, price,adjusted_price, month, year, date, neighbourhood, neighbourhood_cleansed, rating) as 
        select c.listing_id, 
            case c.available when 't' then 1 else 0 end as available,  
            cast(substr(l.price, 2) as integer)*(available - 1)*(-1) as price,
            cast(substr(c.adjusted_price, 2) as integer)*(available - 1)*(-1)  as adjusted_price,
            substr(date, 6, 2) as month,
            substr(date, 1, 4) as year,
            date,
            neighbourhood, 
            neighbourhood_cleansed,
            review_scores_rating  from calendar2019 as c inner join listings2019 as l on c.listing_id = l.id;
    --end cleaning
    
   
    DROP VIEW IF EXISTS neighbourhoodCounts;
    CREATE VIEW neighbourhoodCounts(neighbourhood, year, month, count) as
        select neighbourhood_cleansed, year, month, count(distinct listing_id) as count from processedDatePriceAvailable15 group by neighbourhood_cleansed, year, month
        union all
        select neighbourhood_cleansed, year, month, count(distinct listing_id) as count from processedDatePriceAvailable17 group by neighbourhood_cleansed, year, month
        union all
        select neighbourhood_cleansed, year, month, count(distinct listing_id) as count from processedDatePriceAvailable19 group by neighbourhood_cleansed, year, month;
    --Question 2
    DROP VIEW IF EXISTS rentByNeighbourhoodCleansed;
    CREATE VIEW rentByNeighbourhoodCleansed(total, average, month, year, neighbourhood_cleansed, averageDay, count) as
        select sum(total), cast(sum(total) as float)/cast(count as float), data.month, data.year, neighbourhood_cleansed, sum(averageDay), count from 
        (select sum(price) as total, avg(price) as averageDay, month, year, neighbourhood_cleansed from processedDatePriceAvailable15 group by listing_id, month, year 
        union all
        select sum(price) as total, AVG(price) as averageDay, month, year, neighbourhood_cleansed from processedDatePriceAvailable17 group by listing_id, month, year
        union all
        select sum(price) as total, AVG(price) as averageDay, month, year, neighbourhood_cleansed from processedDatePriceAvailable19 group by listing_id, month, year 
        ) as data inner join neighbourhoodCounts as n on neighbourhood_cleansed = neighbourhood and data.year = n.year and data.month = n.month group by neighbourhood_cleansed, data.year, data.month;
    DROP VIEW IF EXISTS averageRentByNeighbourhoodPerMonth;
    CREATE VIEW averageRentByNeighbourhoodPerMonth as
        select avg(total), neighbourhood_cleansed from rentByNeighbourhoodCleansed group by neighbourhood_cleansed;


    DROP VIEW IF EXISTS ratingsCount;
    CREATE VIEW ratingsCount(rating, year, count) as
        select rating, year, count(distinct listing_id) as count from processedDatePriceAvailable15 group by year, rating
        union all
        select rating, year, count(distinct listing_id) as count from processedDatePriceAvailable17 group by year, rating
        union all
        select rating, year, count(distinct listing_id) as count from processedDatePriceAvailable19 group by year, rating;
    
    --Question 4
    DROP VIEW IF EXISTS rentByRating;
    CREATE VIEW rentByRating(total, average, year, rating, averageDay) as
        select sum(total), cast(sum(total) as float)/cast(count as float), data.year, data.rating, sum(averageDay) from 
        (select sum(price) as total, year, avg(price) as averageDay,rating from processedDatePriceAvailable15 group by listing_id, year, rating 
        union all
        select sum(price) as total, year, avg(price) as averageDay, rating from processedDatePriceAvailable17 group by listing_id, year, rating
        union all
        select sum(price) as total, year, avg(price) as averageDay, rating from processedDatePriceAvailable19 group by listing_id, year, rating 
        ) as data inner join ratingsCount as r on data.rating = r.rating and data.year = r.year group by data.year, data.rating;





    --Question 5
    DROP VIEW IF EXISTS impact;
    CREATE VIEW impact(x, y) AS
        select AVG(review_scores_rating) as x, AVG(availability_365) as y FROM
            (SELECT id, review_scores_rating, availability_365 FROM listings2015 
            UNION ALL 
            SELECT id, review_scores_rating, availability_365 FROM listings2017
            UNION ALL
            SELECT id, review_scores_rating, availability_365 FROM listings2019) 
            GROUP BY id;


    DROP VIEW IF EXISTS linreg;
    CREATE VIEW linreg(slope, intercept) AS 
        select slope,  y_bar_max - x_bar_max * slope as intercept 
            from (
                select sum((x - x_bar) * (y - y_bar)) / sum((x - x_bar) * (x - x_bar)) as slope,
                max(x_bar) as x_bar_max,
                max(y_bar) as y_bar_max    
                from (
                    select x, avg(x) over () as x_bar,
                    y, avg(y) over () as y_bar
                    from impact
                )
            );
    
    --Question 6
    DROP VIEW IF EXISTS listingLocations;
    CREATE VIEW listingLocations(id, latitude, longitude) as
        SELECT id, latitude, longitude from listings2015
        UNION
        SELECT id, latitude, longitude from listings2017
        UNION
        SELECT id, latitude, longitude from listings2019;

    DROP VIEW IF EXISTS distanceSFSU;
    CREATE VIEW distanceSFSU as 
        SELECT id, 
        ((latitude - 37.7241) * (latitude - 37.7241) + (longitude + 122.4799) * (longitude + 122.4799)) as dist,
        'San Francisco State University' as broker
        from listingLocations;
    
    --ALTER TABLE distanceSFSU 
    --ADD broker VARCHAR(256); 
    --UPDATE distanceSFSU
    --SET broker = 'San Francisco State University';
    
    DROP VIEW IF EXISTS distanceUCSF;
    CREATE VIEW distanceUCSF as 
        SELECT id, 
        ((latitude - 37.7627) * (latitude - 37.7627) + (longitude + 122.4579) * (longitude + 122.4579)) as dist,
        'UCSF' as broker
        from listingLocations;
    
    --ALTER TABLE distanceUCSF
    --ADD broker VARCHAR(256); 
    --UPDATE distanceUCSF
    --SET broker = 'UCSF';

    DROP VIEW IF EXISTS distanceSTC;
    CREATE VIEW distanceSTC as 
        SELECT id, 
        ((latitude - 37.7897) * (latitude - 37.7897) + (longitude + 122.3960) * (longitude + 122.3960)) as dist,
        'Salesforce Transit Center' as broker
        from listingLocations;
    
    --ALTER TABLE distanceSTC 
    --ADD broker VARCHAR(256); 
    --UPDATE distanceSTC
    --SET broker = 'Salesforce Transit Center';
    
    DROP VIEW IF EXISTS distanceSFCH;
    CREATE VIEW distanceSFCH as 
        SELECT id, 
        ((latitude - 37.7443) * (latitude - 37.7443) + (longitude + 122.4296) * (longitude + 122.4296)) as dist,
        'San Francisco City Hall' as broker
        from listingLocations;
    
   -- ALTER TABLE distanceSFCH 
    --ADD broker VARCHAR(256); 
    --UPDATE distanceSFCH
    --SET broker = 'San Francisco City Hall';

    DROP VIEW IF EXISTS closestBroker;
    CREATE VIEW closestBroker as 
        with distances as (select * from distanceSFSU
         UNION ALL
         select * from distanceUCSF
         UNION ALL
         select * from distanceSTC
         UNION ALL
         select * from distanceSFCH     
        ), mins as (select id, min(dist) as min from distances group by id)
        SELECT distances.id, dist, broker FROM 
        distances
        inner join mins on distances.id = mins.id where dist = min
        --where not exists (select 1 from distances as dist1 where distances.id = dist1.id and distances.dist > dist1.dist)
        ;
    DROP VIEW IF EXISTS countBroker;
    CREATE VIEW countBroker as
        select broker, count(distinct id) from closestBroker group by broker;
     --Question 3
    DROP VIEW IF EXISTS mostPopular;
    CREATE VIEW mostPopular(listing_id, available, count, neighbourhood) as 
        --select listing_id, neighbourhood_cleansed from 
        
        with counts as (select listing_id, sum(available) as available, sum(count) as count, neighbourhood_cleansed from 
                (select listing_id, sum(available) as available, count(*) as count, neighbourhood_cleansed from processedDatePriceAvailable15 group by listing_id 
                union all  
                select listing_id, sum(available) as available, count(*) as count, neighbourhood_cleansed from processedDatePriceAvailable17 group by listing_id 
                union all 
                select listing_id, sum(available) as available, count(*) as count, neighbourhood_cleansed from processedDatePriceAvailable19 group by listing_id 
                ) group by listing_id)
        select listing_id, available/count,count, neighbourhood_cleansed from counts where not exists 
                (select 1 from counts as c2 where c2.available/c2.count < counts.available/counts.count and c2.neighbourhood_cleansed = counts.neighbourhood_cleansed) order by count desc;
    
    --select * from mostPopular;

    -- alternatively
    DROP VIEW IF EXISTS lessAvailable;
    CREATE VIEW lessAvailable(id, available, neighbourhood) as
    with listings as (SELECT id, availability_365, neighbourhood_cleansed from listings2015 
        union SELECT id, availability_365, neighbourhood_cleansed from listings2017 
        union SELECT id, availability_365, neighbourhood_cleansed from listings2019), mins as 
        (select min(availability_365) as min, neighbourhood_cleansed from listings group by neighbourhood_cleansed)
    select listings.id, min, listings.neighbourhood_cleansed from listings inner join mins on listings.neighbourhood_cleansed = mins.neighbourhood_cleansed where availability_365 = min;

    DROP VIEW IF EXISTS availability;
    CREATE VIEW availability(neighbourhood, year, month, available) as
        select neighbourhood_cleansed, year, month, avg(available) as available from processedDatePriceAvailable15 group by neighbourhood_cleansed, year, month
        union all
        select neighbourhood_cleansed, year, month, avg(available) as available from processedDatePriceAvailable17 group by neighbourhood_cleansed, year, month
        union all
        select neighbourhood_cleansed, year, month, avg(available) as available from processedDatePriceAvailable19 group by neighbourhood_cleansed, year, month
    ;
    

--COMMIT