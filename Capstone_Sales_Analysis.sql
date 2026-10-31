
--1 DATA CLEANING
-- Standardize city names using TRIM and UPPER

SELECT
    order_id,
    order_date,
    customer_id,
    product_sku,
    units_sold,
    gross_revenue,
    shipping_city AS original_city,
    TRIM(UPPER(shipping_city)) AS cleaned_city

FROM public.capstone_sales_staging

ORDER BY order_id;

--2: CORPORATE PRODUCT PROFITABILITY

SELECT
    p.product_name,
    p.category,
    SUM(s.units_sold) AS total_units_sold,
    SUM(s.gross_revenue) AS total_revenue,
    SUM(s.units_sold * p.unit_cost) AS total_cogs,
    SUM(s.gross_revenue - (s.units_sold * p.unit_cost))
        AS total_net_profit

FROM public.capstone_sales_staging s

INNER JOIN public.capstone_products p
ON s.product_sku = p.product_sku

GROUP BY
    p.product_name,
    p.category

ORDER BY total_net_profit DESC;

--3: TEMPORAL SALES ANALYSIS

SELECT
    EXTRACT(YEAR FROM order_date) AS sales_year,
    EXTRACT(QUARTER FROM order_date) AS sales_quarter,
    EXTRACT(MONTH FROM order_date) AS sales_month,
    SUM(gross_revenue) AS total_revenue,
    COUNT(order_id) AS total_orders

FROM public.capstone_sales_staging

GROUP BY
    EXTRACT(YEAR FROM order_date),
    EXTRACT(QUARTER FROM order_date),
    EXTRACT(MONTH FROM order_date)

ORDER BY
    sales_year,
    sales_month;

--  4: PRODUCT REVENUE RANKINGS

WITH product_sales AS
(
    SELECT
        p.category,
        p.product_name,
        SUM(s.gross_revenue) AS total_revenue

    FROM public.capstone_sales_staging s

    INNER JOIN public.capstone_products p
    ON s.product_sku = p.product_sku

    GROUP BY
        p.category,
        p.product_name
)

SELECT
    category,
    product_name,
    total_revenue,

    RANK() OVER
    (
        PARTITION BY category
        ORDER BY total_revenue DESC
    ) AS category_rank

FROM product_sales

ORDER BY
    category,
    category_rank;
	
