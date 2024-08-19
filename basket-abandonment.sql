WITH
   base AS (
      SELECT
         ev.user_pseudo_id,
         CONCAT(
            ev.user_pseudo_id,
            (
               SELECT
                  value.int_value
               FROM
                  UNNEST (event_params)
               WHERE
                  key = 'ga_session_id'
            )
         ) AS session_id,
         ev.event_name,
         ev.event_timestamp,
         TIMESTAMP_MICROS(ev.event_timestamp) AS normal_timestamp,
         i.item_id,
         i.item_name
      FROM
         `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_12_2020` AS ev
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
         ) AS last_event_dttm
      FROM
         add_emails
   ),
   purchase_status AS (
      SELECT
         *,
         MAX(IF(event_name = 'purchase', 1, 0)) OVER (
            PARTITION BY
               user_pseudo_id,
               session_id
         ) AS purchase_flag,
         STRING_AGG(event_name) OVER (
            PARTITION BY
               session_id
         ) AS events
      FROM
         last_event_per_session
   ),
   basket_contents AS (
      SELECT
         *,
         STRING_AGG(item_id) OVER (
            PARTITION BY
               session_id
         ) AS abandoned_products
      FROM
         purchase_status
      WHERE
         event_name = 'add_to_cart'
   ),
   abandoned_status AS (
      SELECT
         *,
         TIMESTAMP_ADD(last_event_dttm, INTERVAL 45 MINUTE) AS abandon_timestamp,
         CASE
            WHEN purchase_flag = 0
            AND TIMESTAMP_ADD(last_event_dttm, INTERVAL 45 MINUTE) < CURRENT_TIMESTAMP() THEN TRUE
            ELSE FALSE
         END AS abandoned_flag
      FROM
         basket_contents
   ),
   final_output AS (
      SELECT
         email,
         user_pseudo_id,
         abandoned_products,
         abandon_timestamp,
         ROW_NUMBER() OVER (
            PARTITION BY
               user_pseudo_id
            ORDER BY
               normal_timestamp
         ) AS abandon_count
      FROM
         abandoned_status
   )
SELECT
   *
FROM
   final_output;