-- Problem: SQL query that reports fraction of users that logged in again on the day after the day they first logged in, rounded to 2 decimal places
-- Business cases:
	-- Tracking consecutive visitors to your site
	-- Can be tweaked to show number of logins within x amount of days
	
-- Schema:
	player_id INT,
	device_id INT,
	event_date DATE,
	games_played INT
	
-- Primary Key = player_id, event_date

-- Set up (optional):

Create table Activity (player_id int, device_id int, event_date date, games_played int);

insert into Activity (player_id, device_id, event_date, games_played) values ('1', '2', '2016-03-01', '5');
insert into Activity (player_id, device_id, event_date, games_played) values ('1', '2', '2016-03-02', '6');
insert into Activity (player_id, device_id, event_date, games_played) values ('2', '3', '2017-06-25', '1');
insert into Activity (player_id, device_id, event_date, games_played) values ('3', '1', '2016-03-02', '0');
insert into Activity (player_id, device_id, event_date, games_played) values ('3', '4', '2018-07-03', '5');

-- Make table with all relevant dates
with days as (
	select
		player_id,
		event_date,
		-- consecutive date
		date(event_date + interval '1 day') as consec_date,
		-- next recorded date
		lead(event_date) over (partition by player_id
			order by event_date) as next_date,
		-- row number to show order of logins
		row_number() over(partition by player_id
			order by event_date) as logins
	from
		Activity)

-- Execute division, make sure everything is cast as a number for division
select 
	round(
		-- Use dates and order to filter qualified players
		(select
		count(distinct player_id)
		from days
		where next_date = consec_date
			and logins = 1
	)::numeric /
	-- Count total numer of players
	(count(distinct player_id)::numeric), 2) as fraction
from
	days;



-- If you just wanted to see percent of users with consecutive logins (not considering first date parameter):

-- Create table showing date differences
with days as (
	select
		player_id,
		event_date,
		-- Consecutive data
		date(event_date + interval '1 day') as consec_date,
		-- Next recorded date
		LEAD(event_date) over (partition by player_id
			order by event_date) as next_date
	from Activity),

-- Determine your totals, not necesssary to do here but makes the final function easier cleaner.
	-- Also returns integers so you can see if something happened
totals as (
select 
	(select
		COUNT(distinct player_id)
	from days
	where next_date = consec_date) as qual_plays,
	count(distinct player_id) as all_plays
from days)


-- Execute division
select
	round(
		qual_plays::numeric/
		all_plays::numeric,2) as fraction
from totals;


