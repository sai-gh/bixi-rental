use bixi;

# 1.1 The total number of trips for the year of 2016
SELECT 
    COUNT(*) AS trips_2016
FROM
    trips
WHERE
    start_date LIKE '%2016%'; -- used string matching to filter out data


#1.2 The total number of trips for the year of 2017.
SELECT 
    COUNT(*) AS trips_2017
FROM
    trips
WHERE
    start_date LIKE '%2017%'; -- used string matching to filter out data

#1.3 The total number of trips for the year of 2016 broken down by month.
SELECT 
    MONTH(start_date) AS month, COUNT(*) AS trips_2016
FROM
    trips
WHERE
    start_date LIKE '%2016%'
GROUP BY MONTH(start_date); -- used string matching along side with group by month funtion to filter out data


#1.4 The total number of trips for the year of 2017 broken down by month.
SELECT 
    MONTH(start_date) AS month, COUNT(*) AS trips_2017
FROM
    trips
WHERE
    start_date LIKE '%2017%'
GROUP BY MONTH(start_date); -- used string matching along side with group by month funtion to filter out data


#1.5 The average number of trips a day for each year-month combination in the dataset.
SELECT 
    YEAR(start_date) AS year,
    MONTHNAME(start_date) AS month,
    COUNT(*) / 30.5 AS average_trips_per_day -- had a lot of troble on this one, at the end ended up deviding by 30.45 to get an aproximation
FROM
    Trips
GROUP BY YEAR , MONTH;

#1.6 Save your query results from the previous question (Q1.5) by creating a table called 'working_table1'.

drop table if exists working_table1; -- always drop table, jsut copy pasted the previous funtion and it made all the outcomes into a table
CREATE TABLE working_table1 AS SELECT YEAR(start_date) AS year,
    MONTHNAME(start_date) AS month,
    COUNT(*) / 30.5 AS average_trips_per_day FROM
    Trips
GROUP BY YEAR , MONTH;

#2.1 The total number of trips in the year 2017 broken down by membership status (member/non-member).
SELECT 
    COUNT(*) AS trips, is_member
FROM
    trips
WHERE
    start_date LIKE '%2017%' -- same as 1.2 ans jsut grouped by 'is_member' to show count in respective rows
GROUP BY is_member;

#2.2 The percentage of total trips by members for the year 2017 broken down by month.
SELECT 
    member_table.month,
    ROUND((total_trips_member / total_trips_2017) * 100) AS percentage -- made the 2 tables created below devide and times it by 100 to get the percentage value
FROM
    (SELECT 
        MONTH(start_date) AS month, COUNT(*) AS total_trips_member
    FROM
        trips
    WHERE
        YEAR(start_date) = 2017
            AND is_member = 1
    GROUP BY month) AS member_table -- did a nested join as a subquery to get a tepm table of all the members from 2017
        JOIN
    (SELECT 
        MONTH(start_date) AS month, COUNT(*) AS total_trips_2017
    FROM
        trips
    WHERE
        YEAR(start_date) = 2017
    GROUP BY month) 
    AS total_table  -- did a nested join as a subquery to get total trips from 2017
    ON member_table.month = total_table.month;

#3.1 At which time(s) of the year is the demand for Bixi bikes at its peak?
SELECT 
    MONTHNAME(start_date) AS month, COUNT(*) AS trips_2016_2017
FROM
    trips
GROUP BY month
ORDER BY trips_2016_2017 DESC; -- jsut count all and separate by month and find peek


#3.2 If you were to offer non-members a special promotion in an attempt to convert them to members, when would you do it? Describe the promotion and explain the motivation and your reasoning behind it.
SELECT 
    MONTHNAME(start_date) AS month, COUNT(*) AS trips_2016_2017
FROM
    trips
WHERE
    is_member = 0 --  similar as before just filtered to only non members
GROUP BY month
ORDER BY trips_2016_2017 DESC
LIMIT 3;
 -- Bases of the data we should give promotions to non-members at july because that is the peek month, more riders meaning more conversion chance.
 
 #4.1 What are the names of the 5 most popular starting stations? Determine the answer without using a subquery.
 SELECT DISTINCT
    s.code, s.name, COUNT(*) AS station_used
FROM
    trips t
        INNER JOIN -- join both tables to get all the information
    stations s ON t.start_station_code = s.code
GROUP BY s.code , s.name
ORDER BY station_used DESC
LIMIT 5; -- limit to 5 to show top 5 stations
 
 #4.2 Solve the same question as Q4.1, but now use a subquery. Is there a difference in query run time between 4.1 and 4.2? Why or why not?
 
SELECT 
    s.code, s.name, station_info.station_used
FROM
    (SELECT 
        t.start_station_code, COUNT(*) AS station_used -- tbh i jsued moved stuff around and put it into a subquery format and somehow it shaved off a lot of time
    FROM
        trips t
    GROUP BY start_station_code) AS station_info
        INNER JOIN
    stations s ON station_info.start_station_code = s.code
GROUP BY s.code , s.name
ORDER BY station_info.station_used DESC
LIMIT 5;
 -- there is a bid run time differnce, to be aproximate for me it was ~6 sec
 
 #5 How is the number of starts and ends distributed for the station Mackay / de Maisonneuve throughout the day?
 
 SELECT 
    CASE
        WHEN HOUR(start_date) BETWEEN 7 AND 11 THEN 'morning'
        WHEN HOUR(start_date) BETWEEN 12 AND 16 THEN 'afternoon'
        WHEN HOUR(start_date) BETWEEN 17 AND 21 THEN 'evening'
        ELSE 'night'
    END AS time_of_day,
    COUNT(*) AS start_station
FROM
    trips t
        JOIN
    stations s ON t.start_station_code = s.code -- did a join so we can match the info from both tables to refarece to the start time
WHERE
    s.name = 'Mackay / de Maisonneuve' -- used name to filter
GROUP BY time_of_day
ORDER BY start_station DESC;

SELECT 
    CASE
        WHEN HOUR(end_date) BETWEEN 7 AND 11 THEN 'morning'
        WHEN HOUR(end_date) BETWEEN 12 AND 16 THEN 'afternoon'
        WHEN HOUR(end_date) BETWEEN 17 AND 21 THEN 'evening'
        ELSE 'night'
    END AS time_of_day,
    COUNT(*) AS end_station
FROM
    trips t
        JOIN
    stations s ON t.start_station_code = s.code -- did a join so we can match the info from both tables to refarece to the end time
WHERE
    s.name = 'Mackay / de Maisonneuve'
GROUP BY time_of_day
ORDER BY end_station DESC;

#5.2 Explain and interpret your results from above. Why do you think these patterns in Bixi usage occur for this station? Put forth a hypothesis and justify your rationale.
 -- after reviewing the numbers, we can assume that the station 'Mackay / de Maisonneuve' is located in a city, thus people are not taking long rides, renting the bicks around afternoon and returning at evening, 
 -- same with peole getting off work and renting around evenning to give it back at night time.
 
 #6 List all stations for which at least 10% of trips are round trips. Round trips are those that start and end in the same station. This time we will only consider stations with at least 500 starting trips. (Please include answers for all steps outlined here)
 
 #6.1 First, write a query that counts the number of starting trips per station.
 SELECT DISTINCT
    s.code, s.name, station_info.station_used
FROM
    (SELECT 
        t.start_station_code, COUNT(*) AS station_used -- same as 4.2 ans
    FROM
        trips t
    GROUP BY start_station_code) AS station_info
        INNER JOIN
    stations s ON station_info.start_station_code = s.code
GROUP BY s.code , s.name
ORDER BY station_info.station_used DESC;
 
#6.2 Second, write a query that counts, for each station, the number of round trips.
 SELECT DISTINCT
    s.code, s.name, round_trip.station_used
FROM
    (SELECT 
        t.start_station_code, COUNT(*) AS station_used
    FROM
        trips t
    WHERE
        t.start_station_code = t.end_station_code -- same as last jsut made sure both start and end stations codes match, meaning its a round trip
    GROUP BY start_station_code) AS round_trip
        INNER JOIN
    stations s ON round_trip.start_station_code = s.code
GROUP BY s.code , s.name
ORDER BY round_trip.station_used DESC;
 
 #6.3 Combine the above queries and calculate the fraction of round trips to the total number of starting trips for each station.
SELECT 
    round_table.code,
    round_table.name,
    round_station_used / starting_station_used AS fraction
FROM
    (SELECT DISTINCT
        s.code, s.name, station_info.starting_station_used
    FROM
        (SELECT 
        t.start_station_code, COUNT(*) AS starting_station_used
    FROM
        trips t
    GROUP BY start_station_code) AS station_info
    INNER JOIN stations s ON station_info.start_station_code = s.code
    GROUP BY s.code , s.name) AS total_table
        JOIN -- as it says, jsut combined the last 2 ans and made sure to devide roundtrips by total starting trips
    (SELECT DISTINCT
        s.code, s.name, round_trip.round_station_used
    FROM
        (SELECT 
        t.start_station_code, COUNT(*) AS round_station_used
    FROM
        trips t
    WHERE
        t.start_station_code = t.end_station_code
    GROUP BY start_station_code) AS round_trip
    INNER JOIN stations s ON round_trip.start_station_code = s.code
    GROUP BY s.code , s.name) AS round_table ON round_table.code = total_table.code
ORDER BY fraction DESC;
 
 #6.4 Filter down to stations with at least 500 trips originating from them and having at least 10% of their trips as round trips.
 SELECT 
    round_table.code, round_table.name
FROM
    (SELECT DISTINCT
        s.code, s.name, station_info.starting_station_used
    FROM
        (SELECT 
        t.start_station_code, COUNT(*) AS starting_station_used
    FROM
        trips t
    GROUP BY start_station_code) AS station_info
    INNER JOIN stations s ON station_info.start_station_code = s.code
    GROUP BY s.code , s.name) AS total_table
        JOIN
    (SELECT DISTINCT
        s.code, s.name, round_trip.round_station_used
    FROM
        (SELECT 
        t.start_station_code, COUNT(*) AS round_station_used
    FROM
        trips t
    WHERE
        t.start_station_code = t.end_station_code
    GROUP BY start_station_code) AS round_trip
    INNER JOIN stations s ON round_trip.start_station_code = s.code
    GROUP BY s.code , s.name) AS round_table ON round_table.code = total_table.code
WHERE
    starting_station_used >= 500
        AND round_station_used / starting_station_used >= 0.1; -- almost identical to the last one, jsut added the where clause to further filter.
 
 #6.5 Where would you expect to find stations with a high fraction of round trips? Describe why and justify your reasoning.
 -- from the date we can assume that a lot of stations in monteal have high fractions of round trips, looking into it montreal does makes it easer for people to use bikes as transportation.