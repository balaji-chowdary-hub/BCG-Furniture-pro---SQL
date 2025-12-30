create database bcg;
use bcg;

select * from orders;

alter table orders 
change `ï»¿Row ID` row_id int;

select * from customers;

select * from districts;

select * from products;

select * from regionheads;

select * from  returns;

select * from salespersons;

	--   total sales = sales-returns
    
select sum(`sales amount`) total_sales from(select o.*, r.returned 
from orders as o 
left join returns r on o.`order id` = r.`order id`) abc where returned is null;

						--    profigt margin  		--  
                        
select round((sum(profit) / sum(`sales amount`))*100,2)  `profit margin` from orders;

					--   regions , segments and categories with highest sales and lowest sales
                    
select region, segment ,category, min(`sales amount`) lowest_sales, max(`sales amount`) highest_sales 
from orders o 
left join products p on  o.`product id` = p.`product id`
group by region, segment , category;


			  -- which products are being returned the most  
              
select `product name`, count(*) from 
(select o.*, r.returned,p.category,p.`product name` from orders o 
left join returns r on o.`order id` = r.`order id` 
left join products p on o.`product id` = p.`product id` where r.returned = 'yes' and p.`product name` is not zznull)abc 
group by `product name`
order by  count(*) desc;

				--   frequency of the customers
                
select `customer id`, count(distinct(`order id`)) frequency
from orders
group by `customer id`
order by frequency desc;

				--    amount spent by customer on each order

select `customer id`, `order id` , sum(`sales amount`) from orders group by `customer id`,`order id`;

				--    segment wise best salesperson 
                
select segment , salesperson , sum(`sales amount`) as total_sales
from orders 
group by segment, salesperson 
having sum(`sales amount`) = (select max(total_sales)
from (select segment as seg , salesperson as sp , sum(`sales amount`)as total_sales
from orders
group by segment,salesperson) as t where t.seg = orders.segment)
order by segment ;

					--    top 5 performing sales persons for each yar , segment , state level and city level
                    
with ranked_sales as
(select year, segment , state , city, salesperson, sum(`sales amount`) total_sales,
round(avg(discount)*100,2)  avg_dicount_percent,
row_number() over(partition by year, segment, state, city
order by sum(`sales amount`)desc) as rank_no
from orders
group by year , segment, state, city, salesperson)
select * from ranked_sales
where rank_no <= 5
order by year, segment, state , city, total_sales  desc;

				--     new customers who purchased from the clients in year 2021, their sales amount ,
						-- quantity purchased by them , discounts offered to them
                        
  with first_purchase as (
select `customer id`, min(year(str_to_date(`order date`, '%Y-%m-%d'))) as year_of_first_purchase
from orders
group by `customer id`)
select
count(distinct o.`customer id`) as new_customers_2021,
sum(o.`sales amount`) as total_sales_in_2021,
sum(o.quantity) as total_quantity_sold_in_2021,
sum(o.`sales amount` * o.discount) as total_discount_amount
from orders o
join first_purchase fp
on o.`customer id` = fp.`customer id`
where fp.year_of_first_purchase = 2021
and year(str_to_date(o.`order date`, '%Y-%m-%d')) = 2021 ;
                
                