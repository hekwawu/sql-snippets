-- Problem: Calculate MoM percentage change in revenue, rounded to the 2nd decimal point
-- Business Cases:
	-- Pretty much all businesses needed some type of Wow, MoM, QoQ analysis
	-- Script can easily be adjusted to have metrics added to make a whole table of trended metrics

-- Table schema is as follows (no code provided):
	id INT
	created_at DATE
	value INT
	purchase_id INT
	
-- Calculate totals by month
WITH month_total AS (
SELECT
    to_char(created_at,'YYYY-MM') as year_month, 
    sum(value) AS revenue
FROM sf_transactions
group by year_month
order by year_month),

-- Create view with lagged data view 
prev_month AS (
SELECT    
    year_month,
    revenue as curr_rev,
    LAG(revenue) OVER (ORDER BY year_month) AS prev_rev
FROM month_total)

-- Perform caalculations
SELECT
    year_month,
    round(
        ((curr_rev - prev_rev)::numeric / prev_rev::numeric)
        *100,2) AS revenue_diff_pct
FROM prev_month;
    
