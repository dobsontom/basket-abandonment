WITH
   base AS (
      SELECT
         user_pseudo_id,
         event_name,
         event_timestamp,
         TIMESTAMP_MICROS(event_timestamp) AS normal_timestamp,
         ep.key AS event_param_key,
         ep.value.string_value AS event_param_string_value,
         ep.value.int_value AS event_param_int_value,
         ep.value.double_value AS event_param_double_value,
         i.item_id,
         i.item_name,
         i.quantity
      FROM
         `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131` AS e
         LEFT JOIN UNNEST (e.event_params) AS ep
         LEFT JOIN UNNEST (e.items) AS i
   )
SELECT
   *
FROM
   base;