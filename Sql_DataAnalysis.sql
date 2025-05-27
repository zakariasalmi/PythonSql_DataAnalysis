-- find top 10 highest revenue generating products
SELECT TOP 10 product_id, SUM(sale_price) as sales
from df_orders
group by product_id
order by sales DESC

-- find top 5 highest prducts in each region
with ct as(
SELECT  region, product_id, SUM(sale_price) as sales
from df_orders
group by  region, product_id)
select * from(
select *,
ROW_NUMBER() over(partition by region order by sales desc) as row_number
from ct) A
where row_number<=5

-- find month over month growth comparison for 2022 and 2023 sales eg: jan 2022 vs jan 2023
 with ct as (
 select year(order_date) as order_year, month(order_date) as order_month,SUM(sale_price) as sales
 from df_orders
 group by year(order_date),month(order_date)
 --order by year(order_date),month(order_date)
 )
 select order_month,
 sum(case when order_year= 2022 then sales else 0 end) as sales_2022,
 sum(case when order_year= 2023 then sales else 0 end) as sales_2023
 from ct
 group by order_month
 order by order_month
 
 -- for each category which month had highest sales
 
with ct as(  
 select category,format(order_date, 'yyyyMM') as order_year_month , sum(sale_price) as sales
 from df_orders
 group by category,format(order_date, 'yyyyMM')
 --order by category,format(order_date, 'yyyyMM')
 )
 select* from (
 select *,
 ROW_NUMBER() over(partition by category order by sales desc) as row_nbr
from ct) A
where row_nbr=1


 -- which sub category had highest growth by profit in 2023 compare to 2022
  with ct as (
 select sub_category, year(order_date) as order_year,SUM(sale_price) as sales
 from df_orders
 group by sub_category,year(order_date)
 --order by year(order_date),month(order_date)
 ), ct2 as(
 select sub_category,
 sum(case when order_year= 2022 then sales else 0 end) as sales_2022,
 sum(case when order_year= 2023 then sales else 0 end) as sales_2023
 from ct
 group by sub_category
 )
 select top 1 * ,
 (sales_2023-sales_2022) as growth
 from ct2
 order by (sales_2023-sales_2022) desc


