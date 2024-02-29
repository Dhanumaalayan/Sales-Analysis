use sales ;

select * from transactions;
select * from customers;
select * from markets ;
select * from date;
select * from products;


-- Q1 : write a query to fetch the total_sales_amount

select sum(sales_amount) 
from transactions ;

-- Q2 : write a query to display all the distinct customer name

select distinct(customer_name)
from customers;

-- Q3 : write a query to fetch the total revenue of the market  = "Chennai"

select sum(sales_amount)
from transactions t
where t.market_code in
			 (select m.markets_code 
			  from markets m 
			  where m.markets_name = "Chennai");
              
-- Q4 : write a query to fetch the total revenue for all the year      

select b.year,sum(a.sales_amount) as total_sales
from
(select * from transactions t)a 
join
(select * from date d) b
on a.order_date = b.date
group by b.year ;

-- Q5 : write a query to display total reveue by the zone level for all the year 

select d.year , m.zone , sum(t.sales_amount) as total_sales
from transactions t 
join markets m 
on t.market_code = m.markets_code 
join date d 
on t.order_date = d.date 
group by d.year , m.zone 
order by d.year asc , m.zone asc;

-- Q6 : write a query to fetch the details of  all the customer having total_revenue in the zone "Central"

select b.customer_name,a.zone,sum(a.sales_amount) 
from 
	(select * 
	from transactions t
	join markets m
	on m.markets_code = t.market_code 
	join date d
	on t.order_date = d.date )a 
join 
	(select * from customers c) b
	on a.customer_code = b.customer_code 
	where a.zone = "Central"
	group by b.customer_name  ,a.zone
	order by b.customer_name asc;


-- Q7 : write a query to retrieve the customer_name who has total_sales more/better than the avg_sales by zone level
-- using cte 

with ts as 
	(select  c.customer_name,m.zone ,sum(t.sales_amount) as total_sales
	from transactions t 
	join customers c
	on t.customer_code = c.customer_code 
	join markets m 
	on t.market_code = m.markets_code 
	group by c.customer_name,m.zone),
av as
    (select avg(total_sales) as avg_sales from ts)
select * from ts
join av 
on ts.total_sales > av.avg_sales
order by total_sales desc ,ts.zone asc;

-- using subquery
select ts.customer_name,ts.zone ,ts.total_sales from 
	(select c.customer_name , m.zone , sum(t.sales_amount) as total_sales
	from transactions t 
	join markets m 
	on t.market_code = m.markets_code 
	join customers c
	on t.customer_code = c.customer_code 
	group by c.customer_name,m.zone ) ts
join 
	(select avg(total_sales) as avg_sales from 
	(select c.customer_name , m.zone , sum(t.sales_amount) as total_sales
	from transactions t 
	join markets m 
	on t.market_code = m.markets_code 
	join customers c
	on t.customer_code = c.customer_code 
	group by c.customer_name ,m.zone ) x) av
where ts.total_sales > av.avg_sales
group by ts.customer_name , ts.zone
order by total_sales desc , ts.zone asc;

-- Q8 : write a query to retrieve the customer name who has the highest revenue in each zone and rank them as "1"


select * from 
(select c.customer_name ,m.zone,sum(t.sales_amount),
rank() over (partition by m.zone  order by sum(sales_amount) desc ) as rank_
from transactions t 
join customers c
on t.customer_code = c.customer_code 
join markets m 
on t.market_code = m.markets_code 
group by c.customer_name , m.zone)x
where x.rank_  = 1;

-- Q9 : write a query to fetch the revenue contribution by all the markets

select b.markets_name , sum(a.sales_amount) as total_sales 
from 
  (select * from transactions ) a 
join 
  (select * from markets m ) b
on a.market_code = b.markets_code
group by b.markets_name
order by total_sales desc;

-- Q10 :  write a query to fetch the profit contribution by all the markets

select b.markets_name , round(sum(a.profit_margin)) as profit_contribution
from
(select * from transactions t) a
join 
(select * from markets m ) b
on a.market_code = b.markets_code 
group by b.markets_name 
order by profit_contribution desc;



