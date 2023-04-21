-- Problem: Calculate average user session time. Session = (page exit) - (page load)
-- Business cases:
  -- Tracking on average how long people are on the site
  -- How long are users taking between actions?
  
-- Assumptions:
  -- Use latest page load and earliest page exit as primary metrics. 
      -- This isn't realistic your users may come back multiple times within a day. In that case the below code can be adjusted to action to use "session_id" or some tpe of primary key to identify action
      -- Additionally this script does not account for bounces, which occur when users land on a load and exit a page without other actions being recorded.
          -- Bounce metrics are heavily tied to the web tracking in place; smart organizations will record an action if users stay on a page for at least 30 secs
      
-- Schema for table web_data:
      user_id: INT
      timestamp: timestamp
      action: varchar
         -- Includes values 'page_load', 'page_exit', 'scroll_down','scroll_up'
 
-- Use a self-join to make a CTE that breaks out each action's timestamp into its own column 
-- One version of the table t1, will have the exit times, while table t2 will have the load times
with sessions as (
    SELECT
        t1.user_id,
        t1.timestamp::date as day,
        min(t2.timestamp) as exit_time, -- Prompt said use earliest exit time available
        max(t1.timestamp) as load_time -- Prompt said use latest load time available
    from web_data as t1
    join web_data as t2 on t2.user_id = t1.user_id
    where
        t1.action = 'page_load'
        and t2.action = 'page_exit'
        and t2.timestamp > t1.timestamp -- This qualifier ensures there was an exit time on that day, which helps us manage tracking errors or outliers
    group by
        t1.user_id,
        day
    )
    
  -- Why the need for self-join?
  -- Putting both times in one table would've required CASE or IF statements, which would have had NULL as their else value. 
  -- This would've made the subtraction part unnecessarily complicated. The self-joins make it easy to create fully populated columns for each action.
  
  -- Select the average difference between the two times
  select
      user_id,
      avg(exit_time - load_time) as average_duration
  from sessions
  group by user_id;
