CREATE OR REPLACE TABLE `basket-abandonment.basket_abandonment.basket_abandonment` AS (
   WITH
      events_data AS (
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
            `basket-abandonment.basket_abandonment.events_12_2020` AS ev
            LEFT JOIN UNNEST (ev.items) AS i
      ),
      add_emails AS (
         SELECT
            ev.*,
            em.email
         FROM
            events_data ev
            INNER JOIN `basket-abandonment.basket_abandonment.email_lookup` em ON ev.user_pseudo_id = em.user_pseudo_id
      ),
      session_last_event AS (
         SELECT
            *,
            MAX(normal_timestamp) OVER (
               PARTITION BY
                  session_id
            ) AS last_event_dttm
         FROM
            add_emails
      ),
      session_purchase_status AS (
         SELECT
            *,
            MAX(IF(event_name = 'purchase', 1, 0)) OVER (
               PARTITION BY
                  user_pseudo_id,
                  session_id
            ) AS purchase_flag
         FROM
            session_last_event
      ),
      session_basket_contents AS (
         SELECT
            *,
            STRING_AGG(item_id) OVER (
               PARTITION BY
                  session_id
            ) AS abandoned_products
         FROM
            session_purchase_status
         WHERE
            event_name = 'add_to_cart'
      ),
      session_abandoned_status AS (
         SELECT
            *,
            UNIX_MICROS(TIMESTAMP_ADD(last_event_dttm, INTERVAL 45 MINUTE)) AS abandon_timestamp,
            CASE
               WHEN purchase_flag = 0
               AND TIMESTAMP_ADD(last_event_dttm, INTERVAL 45 MINUTE) < CURRENT_TIMESTAMP() THEN TRUE
               ELSE FALSE
            END AS abandoned_flag
         FROM
            session_basket_contents
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
                  abandon_timestamp
            ) AS abandon_count
         FROM
            session_abandoned_status
         WHERE
            abandoned_flag = TRUE
         GROUP BY
            email,
            user_pseudo_id,
            abandon_timestamp,
            abandoned_products
      )
   SELECT
      email,
      user_pseudo_id,
      abandoned_products,
      abandon_timestamp,
      abandon_count
   FROM
      final_output
   ORDER BY
      user_pseudo_id ASC,
      abandon_count ASC
);