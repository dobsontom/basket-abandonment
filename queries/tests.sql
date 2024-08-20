-- Check for missing email addresses
SELECT
   COUNT(*) AS missing_email_count
FROM
   `basket-abandonment.basket_abandonment.basket_abandonment`
WHERE
   email IS NULL;


-- Check for duplicate user_pseudo_id and event_timestamp pairs
SELECT
   user_pseudo_id,
   abandon_timestamp,
   COUNT(*) AS record_count,
   CASE
      WHEN COUNT(*) > 1 THEN ERROR('Potential Duplication') AS ERROR(error_message)
      ELSE 'No Duplication'
   END AS error_on_duplicate
FROM
   `basket-abandonment.basket_abandonment.basket_abandonment`
GROUP BY
   user_pseudo_id,
   abandon_timestamp;
