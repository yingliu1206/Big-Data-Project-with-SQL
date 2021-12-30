# 4-3  Create dimension table L_CANCELATION using CREATE TABLE statement. 
CREATE TABLE L_CANCELATION (
    Code VARCHAR(255) NOT NULL,
    Reason VARCHAR(255) NOT NULL
);

# Load data into dimension tables using INSERT statements.
Insert into L_CANCELATION (Code, Reason)
values('A', 'Carrier'), ('B', 'Weather'), ('C', 'National Air System'), ('D', 'Security');

# 5-1 Find maximal departure delay in minutes for each airline. Sort results from smallest to largest maximum delay. Output airline names and values of the delay.
select Reporting_Airline,
       DepDelayMinutes
from(
select Reporting_Airline,
       DepDelayMinutes,
       rank() over (partition by Reporting_Airline order by DepDelayMinutes desc) as ranking
from al_perf) a
where ranking = 1 and Reporting_Airline <> 'Reporting_Airline'
order by DepDelayMinutes; 
# 12 rows returned

# 5-2 Find maximal early departures in minutes for each airline. Sort results from largest to smallest. Output airline names.
select Reporting_Airline,
       -1*DepDelay as DepDelay
from(
select Reporting_Airline,
       DepDelay,
       rank() over (partition by Reporting_Airline order by DepDelay asc) as ranking
from al_perf) a
where ranking = 1 and Reporting_Airline <> 'Reporting_Airline'
order by DepDelay desc; 
# 12 rows returned

# 5-3 Rank days of the week by the number of flights performed by all airlines on that day ( 1 is the busiest). Output the day of the week names, number of flights and ranks in the rank increasing order.
select *,
       rank () over (order by Flights_sum desc) as ranking
from(
select DayOfWeek, 
       sum(Flights) as Flights_sum
from al_perf
where DayOfWeek <> 0
group by DayOfWeek) a;
# 7 rows returned

# 5-4 Find the airport that has the highest average departure delay among all airports. Consider 0 minutes delay for flights that departed early. Output one line of results: the airport name, code, and average delay.
select Origin as airport_name,
	   OriginAirportID as code,
       avg(DepDelayMinutes) as average_delay
from al_perf
group by OriginAirportID
order by average_delay desc
limit 1; 
# 1 row returned

# 5-5 For each airline find an airport where it has the highest average departure delay. Output an airline name, a name of the airport that has the highest average delay, and the value of that average delay.
select airline_name, airport_name, average_delay
from(
select Reporting_Airline as airline_name,
	   Origin as airport_name,
       avg(DepDelayMinutes) as average_delay,
       rank() over (partition by Reporting_Airline order by DepDelayMinutes desc) as ranking
from al_perf
where Reporting_Airline <> 'Reporting_Airline'
group by airline_name, OriginAirportID) a
where ranking = 1;
# 12 rows returned

# 5-6 a) Check if your dataset has any canceled flights.
select count(Cancelled) as cnt
from al_perf
where Cancelled = 1; 
# The dataset has 11007 canceled flights.

# b) If it does, what was the most frequent reason for each departure airport? Output airport name, the most frequent reason, and the number of cancelations for that reason.
select airport_name, reason, Cancellatio_num
from(
select Origin as airport_name, 
	   CancellationCode as reason,
       count(CancellationCode) as Cancellatio_num,
	   rank () over (partition by Origin order by (count(CancellationCode)) desc) as ranking
from al_perf
where Cancelled = 1
group by airport_name, CancellationCode) a
where ranking = 1;
# 247 rows returned

# 5-7 Build a report that for each day output average number of flights over the preceding 3 days.
select FlightDate, 
	   avg(flights_sum) over (order by FlightDate rows 3 preceding) as avg_Flights
from (
select FlightDate,
	   sum(Flights) as flights_sum
from al_perf
where FlightDate <> 'FlightDate'
group by FlightDate
order by FlightDate) a;
# 31 rows returned

