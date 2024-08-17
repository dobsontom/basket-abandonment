WITH
   base AS (
      SELECT
         user_pseudo_id,
         event_name,
         event_timestamp,
         TIMESTAMP_MICROS(event_timestamp) AS normal_timestamp,
         i.item_id,
         i.item_name,
         i.quantity
      FROM
         `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131` AS e
         LEFT JOIN UNNEST (e.items) AS i
   ),
   add_emails AS (
      SELECT
         *
      FROM
         base b
         LEFT JOIN `basket-abandonment.emails.email_lookup` e ON b.user_pseudo_id = e.user_pseudo_id
   )
SELECT
   *
FROM
   add_emails;