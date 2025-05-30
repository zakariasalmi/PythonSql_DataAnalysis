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
 select category,format(order_date, 'yyyy-MM') as order_year_month , sum(sale_price) as sales
 from df_orders
 group by category,format(order_date, 'yyyy-MM')
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

 -- catégorie avec la meilleure marge bénéficitaire moyenne en 2023
 -- category with the best average profit margin in 2023
 Select category, Sum(profit)/ NullIF(SUM(sale_price),0) AS profit_marge
 from df_orders
 where YEAR(order_date)= 2023
 group by category
 order by profit_marge DESC
 
 -- Croissance des ventes par region en 2023 
 -- Sales growth by region in 2023

 with yearly_sales as(
 select region, Year(order_date) AS order_year, SUM(sale_price) as sales
 from df_orders
 group by region, year(order_date)
 --order by year(order_date),sum(sale_price)
 )
 SELECT region, 
 sum( case when order_year= 2022 then sales else 0 END) AS sales_2022,
 sum( case when order_year= 2023 then sales else 0 END) AS sales_2023,
 (sum( case when order_year= 2023 then sales else 0 END) -sum( case when order_year= 2022 then sales else 0 END)) AS growth
 from yearly_sales
 group by region
 order by growth DESC

 --Tendance Analysis
 -- 3 Mois avec le plus de commandes en 2023
 -- 3 Months with the most orders in 2023
 select top 3 month(order_date) as order_month, count(*) as total_orders
 from df_orders
 where year(order_date)=2023
 group by month(order_date)
 order by total_orders
 
 -- Analyse des anomalies ou inefficacités
 -- Produits avec des ventes importantes mais peu de profit 
 -- Analysis of anomalies or inefficiencies
 -- Products with high sales but low profitability

SELECT product_id, SUM(sale_price) AS total_sales, SUM(profit) AS total_profit
FROM df_orders
GROUP BY product_id
HAVING SUM(sale_price) > 10000 AND SUM(profit) < 500

-- Commandes avec pertes financiers (profit<0)
-- Orders with financial loss (profit<0)
Select order_id, order_date, product_id, profit
from df_orders
where profit<0
order by profit ASC

-- Analyse prédective (via tendances)
-- Predictive analysis (via trends) 

-- Prévision naïve des ventes de janvier 2024 basée sur la moyenne des trois derniers mois de 2023 
-- Naive sales forecast for January 2024 based on the average of the last three months of 2023 
select AVG(sale_price) as forcast_sales_2024
from df_orders
where order_date BETWEEN '2023-10-01' AND '2023-12-31'