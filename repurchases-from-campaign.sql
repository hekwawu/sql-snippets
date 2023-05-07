-- Problem: Determine the volume of users who made purchases of other products following their first day and first product.
-- Business cases:
	-- Monitoring success of a marketing campaign 
	-- Can be tweaked to encompass x amount of days during and following marketing campaign
  
-- Assumptions:
  -- Marketing campaign doesn't start until one day after the initial in-app purchase so users that only made one or multiple purchases on the first day do not count
  -- We don't count users that over time purchase only the products they purchased on the first day.
      -- Consider how this may need to be tweaked to account repeat purchases of same product
      
 with rnks as (
    select
        user_id,
        created_at,
        RANK() over(partition by user_id order by created_at)  as date_rnk, ## This will help us filter out users who only buy on one day
        RANK() over(partition by user_id, product_id order by created_at)  as prod_buys ## Counts repeat purchases on the same day. The user/product combo creates a unique buy_id
    from
        marketing_campaign
)

select
    COUNT(DISTINCT user_id) as count
from
    rnks
    WHERE date_rnk > 1 ## Narrows down to only repeat buyeers
        and prod_buys = 1; ## Filters out users who bought the same product over multiple days

