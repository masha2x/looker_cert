view: order_items {
  sql_table_name: "PUBLIC"."ORDER_ITEMS"
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
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

  dimension_group: delivered {
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
    sql: ${TABLE}."DELIVERED_AT" ;;
  }

  dimension: inventory_item_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."INVENTORY_ITEM_ID" ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension_group: returned {
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
    sql: ${TABLE}."RETURNED_AT" ;;
  }

  dimension: sale_price {
    type: number
    sql: ${TABLE}."SALE_PRICE" ;;
  }

  dimension_group: shipped {
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
    sql: ${TABLE}."SHIPPED_AT" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."USER_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: total_sale_price {
    type:  sum
    label: "Total Sale Price"
    description: "Total sales from items sold"
    sql: ${sale_price} ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: avg_sale_price {
    type:  average
    label: "Average Sale Price"
    description: "Average sale price of items sold"
    sql: ${sale_price} ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: cumul_sale_price {
    type:  running_total
    label: "Cumulative Total Sales"
    description: "Cumulative total sales from items sold (also known as a running total)"
    sql: ${sale_price} ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_gross_revenue {
    type:  sum
    label: "Total Gross Revenue"
    description: "Total revenue from completed sales (cancelled and returned orders excluded)"
    sql: ${sale_price} ;;
    value_format_name: usd
    drill_fields: [detail*]
    filters: [status: "-Cancelled, -Returned"]
  }

  dimension: diff {
    type:  number
    description: "Difference between the total revenue from completed sales and the cost of the goods that were sold"
    sql: ${sale_price}-${inventory_items.cost} ;;
    value_format_name: usd
  }

  measure: total_diff {
    type:  sum
    label: "Total Gross Margin Amount"
    description: "Total difference between the total revenue from completed sales and the cost of the goods that were sold"
    sql: ${diff} ;;
    value_format_name: usd
    drill_fields: [detail*]
    filters: [status: "Complete"]
  }

  measure: total_avg {
    type:  average
    label: "Average Gross Margin"
    description: "Average difference between the total revenue from completed sales and the cost of the goods that were sold"
    sql: ${diff} ;;
    value_format_name: usd
    drill_fields: [detail*]
    filters: [status: "Complete"]
  }

  measure: gross_margin_pers {
    type: number
    label: "Gross Margin %"
    description: "Total Gross Margin Amount / Total Gross Revenue"
    sql:  ${total_diff}/nullif(${total_gross_revenue},1);;
    drill_fields: [detail*]
    value_format_name: percent_2
  }

  measure: num_returned {
    label: "Number of Items Returned"
    description: "Number of items that were returned by dissatisfied customers"
    type: count
    filters: [status: "Returned"]
    drill_fields: [detail*]
  }

  measure: ret_rate {
    label: "Number of Items Returned"
    description: "Number of items that were returned by dissatisfied customers"
    type: number
    sql: ${num_returned} / nullif(${count},1) ;;
    drill_fields: [detail*]
  }

  measure: cust_num_ret {
    label: "Number of Customers Returning Items"
    description: "Number of users who have returned an item at some point"
    type: count_distinct
    sql: ${users.id} ;;
    filters: [status: "Returned"]
    drill_fields: [detail*]
  }

  measure: pers_cust_w_ret {
    label: "% of Users with Returns"
    description: "Number of Customer Returning Items / total number of customers"
    drill_fields: [detail*]
    sql: ${cust_num_ret} / nullif(${users.count},1) ;;
    type: number
    value_format_name: percent_2
  }

  measure: avg_spent_cust {
    label: "Average Spend per Customer"
    description: "Total Sale Price / total number of customers"
    type:  number
    drill_fields: [detail*]
    sql: ${total_sale_price} / nulif(${users.count},1) ;;
  }


  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      inventory_items.product_name,
      inventory_items.id,
      users.last_name,
      users.id,
      users.first_name
    ]
  }
}
