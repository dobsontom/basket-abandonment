WITH
   base AS (
      SELECT
         ev.user_pseudo_id,
         CONCAT(
            ev.user_pseudo_id,
            CAST(
               (
                  SELECT
                     value.int_value
                  FROM
                     UNNEST (event_params)
                  WHERE
                     key = 'ga_session_id'
               ) AS STRING
            )
         ) AS session_id,
         ev.event_name,
         ev.event_timestamp,
         TIMESTAMP_MICROS(ev.event_timestamp) AS normal_timestamp,
         i.item_id,
         i.item_name
      FROM
         `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131` AS ev
         LEFT JOIN UNNEST (ev.items) AS i
   ),
   add_emails AS (
      SELECT
         b.*,
         e.email
      FROM
         base b
         INNER JOIN `basket-abandonment.emails.email_lookup` e ON b.user_pseudo_id = e.user_pseudo_id
   ),
   last_event_per_session AS (
      SELECT
         *,
         MAX(normal_timestamp) OVER (
            PARTITION BY
               session_id
         ) AS last_event_time
      FROM
         add_emails
   ),
   purchase_check AS (
      SELECT
         *,
         MAX(IF(event_name = 'purchase', 1, 0)) OVER (
            PARTITION BY
               session_id
         ) AS purchase_flag
      FROM
         last_event_per_session
   ),
   basket_contents AS (
      SELECT
         *,
         STRING_AGG(item_name) OVER (
            PARTITION BY
               session_id
         ) AS abandoned_products
      FROM
         purchase_check
      WHERE
         event_name = 'add_to_cart'
   )
SELECT
   *
FROM
   basket_contents;