view: users {
  sql_table_name: "PUBLIC"."USERS"
    ;;
  drill_fields: [id]
  set: Address {
    fields: [city, state, zip, country]
  }

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension: age {
    type: number
    sql: ${TABLE}."AGE" ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}."CITY" ;;
  }

  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}."COUNTRY" ;;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."CREATED_AT" ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}."EMAIL" ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: gender {
    type: string
    sql: ${TABLE}."GENDER" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: latitude {
    type: number
    sql: ${TABLE}."LATITUDE" ;;
  }

  dimension: longitude {
    type: number
    sql: ${TABLE}."LONGITUDE" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: traffic_source {
    type: string
    sql: ${TABLE}."TRAFFIC_SOURCE" ;;
  }

  dimension: zip {
    type: zipcode
    sql: ${TABLE}."ZIP" ;;
  }

  measure: count {
    type: count
    drill_fields: [id, last_name, first_name, events.count, order_items.count]
  }

  dimension: age_group {
    sql: CASE
        WHEN ${age} >= 15 and ${age} < 26 THEN '15 - 25'
        WHEN ${age} >= 26 and ${age} < 36 THEN '26 - 35'
        WHEN ${age} >= 36 and ${age} < 50 THEN '36-50'
        WHEN ${age} >= 50 and ${age} < 66 THEN '51-65'
        ELSE '66+'
        END ;;
  }

  dimension: new_user_90days {
    sql: CASE
        WHEN diff_months(now(),${created_date}) <= 3 THEN 'New users last 90 days'
        ELSE 'Longer-term customers'
        END ;;
  }

  dimension: new_user_30days {
    sql: CASE
        WHEN diff_months(now(),${created_date}) <= 1 THEN 'New users last 30 days'
        WHEN diff_months(now(),${created_date}) <= 2 and diff_months(now(),${created_date}) > 1 THEN 'New users last 30 days'
        ELSE 'Filter out'
        END ;;
  }
}
