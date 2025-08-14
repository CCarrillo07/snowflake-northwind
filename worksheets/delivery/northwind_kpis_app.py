import streamlit as st
import altair as alt
from snowflake.snowpark.context import get_active_session
import pandas as pd
import math

# Initialize Snowflake session
session = get_active_session()

st.title("📊 Northwind KPIs Dashboard")

def load_view(view_name):
    df = session.table(view_name).to_pandas()
    df.columns = [col.lower() for col in df.columns]
    return df

# -----------------------------
# Top 10 Products by Revenue

st.header("Top 10 Products by Revenue")

top10_products_df = load_view("analytics.v_top10_products_by_revenue")
top10_products_df['product_name'] = top10_products_df['product_name'].astype(str)
top10_products_df['total_revenue'] = pd.to_numeric(top10_products_df['total_revenue'], errors='coerce')

chart_top10 = alt.Chart(top10_products_df).mark_bar(color='#29B5E8').encode(
    x=alt.X('total_revenue:Q', title='Total Revenue ($)'),
    y=alt.Y('product_name:N', sort='-x', title='Product'),
    tooltip=['product_name', 'total_revenue']
).properties(
    width=700,
    height=400
)

st.altair_chart(chart_top10, use_container_width=True)

# -----------------------------
# Product-level Sales Summary with max revenue slider filter
prod_sales_df = load_view("analytics.v_product_sales_summary")
prod_sales_df['product_name'] = prod_sales_df['product_name'].astype(str)
prod_sales_df['total_revenue'] = pd.to_numeric(prod_sales_df['total_revenue'], errors='coerce')
prod_sales_df['total_units_sold'] = pd.to_numeric(prod_sales_df['total_units_sold'], errors='coerce')

st.header("Product-level Sales Summary")

max_revenue = st.slider(
    "Maximum Total Revenue to Display ($)", 
    min_value=0, 
    max_value=int(math.ceil(prod_sales_df['total_revenue'].max())), 
    value=int(prod_sales_df['total_revenue'].max()),
    step=1000
)

filtered_prod_sales = prod_sales_df[prod_sales_df['total_revenue'] <= max_revenue]

chart_prod_sales = alt.Chart(filtered_prod_sales).mark_bar(color='#6A4C93').encode(
    x=alt.X('total_revenue:Q', title='Total Revenue ($)'),
    y=alt.Y('product_name:N', sort='-x', title='Product'),
    tooltip=['product_name', 'total_units_sold', 'total_revenue']
).properties(
    width=700,
    height=600
)

st.altair_chart(chart_prod_sales, use_container_width=True)


# -----------------------------
# Revenue per Category
revenue_category_df = load_view("analytics.v_revenue_per_category")
revenue_category_df['category_name'] = revenue_category_df['category_name'].astype(str)
revenue_category_df['total_revenue'] = pd.to_numeric(revenue_category_df['total_revenue'], errors='coerce')

st.header("Revenue per Category")

chart_revenue_cat = alt.Chart(revenue_category_df).mark_bar(color='#FF6F61').encode(
    x=alt.X('total_revenue:Q', title='Total Revenue ($)'),
    y=alt.Y('category_name:N', sort='-x', title='Category'),
    tooltip=['category_name', 'total_revenue']
).properties(
    width=700,
    height=400
)

st.altair_chart(chart_revenue_cat, use_container_width=True)

# -----------------------------
# Units Sold per Category
units_sold_df = load_view("analytics.v_units_sold_per_category")
units_sold_df['category_name'] = units_sold_df['category_name'].astype(str)
units_sold_df['total_units_sold'] = pd.to_numeric(units_sold_df['total_units_sold'], errors='coerce')

st.header("Units Sold per Category")

chart_units_sold = alt.Chart(units_sold_df).mark_bar(color='#0072CE').encode(
    x=alt.X('total_units_sold:Q', title='Total Units Sold'),
    y=alt.Y('category_name:N', sort='-x', title='Category'),
    tooltip=['category_name', 'total_units_sold']
).properties(
    width=700,
    height=400
)

st.altair_chart(chart_units_sold, use_container_width=True)
