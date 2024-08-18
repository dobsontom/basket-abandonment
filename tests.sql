-- Check for missing email addresses
SELECT
  COUNT(*) AS missing_email_count
FROM
  `your_project.your_dataset.your_table`
WHERE
  email IS NULL;


  -- Check for duplicate user_pseudo_id and event_timestamp pairs
SELECT
  user_pseudo_id,
  event_timestamp,
  COUNT(*) AS record_count
FROM
  `your_project.your_dataset.your_table`
GROUP BY
  user_pseudo_id, event_timestamp
HAVING
  record_count > 1;