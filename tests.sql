-- Check for missing email addresses
SELECT
   COUNT(*) AS missing_email_count
FROM
   `basket-abandonment.emails.basket_abandonment`
WHERE
   email IS NULL;


-- Check for duplicate user_pseudo_id and event_timestamp pairs
SELECT
   user_pseudo_id,
   event_timestamp,
   COUNT(*) AS record_count
FROM
   `basket-abandonment.emails.basket_abandonment`
GROUP BY
   user_pseudo_id,
   event_timestamp
HAVING
   record_count > 1;