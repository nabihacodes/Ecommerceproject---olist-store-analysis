 -- 1. Names of products starting with "p"
 select product_category_name as "Product Name"
from products
where product_category_name like 'p%';
 
-- 2.  State and City wise zip codes and average payment value
select * from customers;
select * from orders_payments;
SELECT 
    c.customer_state AS State,
    c.customer_city AS City,
    c.customer_zip_coe_prefix AS "Zip Code",
    round(avg(p.payment_value),2) AS "Average Payment Value"
FROM 
    customers c
INNER JOIN 
    orders o ON c.customer_id = o.customer_id
INNER JOIN 
    orders_payments op ON o.order_id = op.order_id
INNER JOIN 
    orders_payments p ON op.order_id = p.order_id
GROUP BY 
    c.customer_state, c.customer_city, c.customer_zip_coe_prefix;

 
 -- 3. Weekday Vs Weekend (order_purchase_timestamp) Payment Statistics
select case 
when weekday(order_purchase_timestamp) in (5,6) then  "weekend" 
else "weekday"
end 
as day,
concat(round(sum(payment_value),0), ' ' , "(" , 
round(sum(payment_value)/ (select sum(payment_value) from orders_payments)*100), ")","%") as total_amount
from orders inner join orders_payments  using( order_id) group by day ;


-- 4. Number of Orders with review score 5 and payment type as credit card.

select 
   payment_type, review_score, concat(round(count(DISTINCT r.order_id)/1000,0),'K') as No_of_orders
from orders_payments as op
join orders_reviews as r
on op.order_id = r.order_id
where review_score = 5 and  payment_type = "credit_card";


-- 5. max payment by payment sequential

SELECT 
    payment_sequential AS payment_type,
    MAX(payment_value) AS max_value
FROM 
    orders_payments
WHERE 
    payment_sequential NOT IN ('not_defined')
GROUP BY 
    payment_sequential
ORDER by max_value desc;

-- 6. max price by product_category
select * from orders_items;
SELECT 
    p.product_category_name AS product,
    MAX(od.price) AS maxprice
FROM 
    products p
INNER JOIN 
    orders_items od ON p.product_id = od.product_id
GROUP BY 
     product
ORDER BY 
    maxprice desc
    limit 1;

-- 7.conversion rate
SELECT COUNT(o.order_status) / NULLIF(COUNT(DISTINCT c.customer_id), 0) * 100 AS Conversion_Rate
FROM customers c
LEFT JOIN orders o ON 
c.customer_id = o.customer_id AND
 o.order_status = "delivered";
 
-- 8. product qty sold
CREATE VIEW PRODUCT_QUANTITIES_SOLD AS
 select p.product_category_name as products,sum(oi.order_item_id) as Qty_Sold
 from products p join orders_items oi
 on p.product_id = oi.product_id
 group by p.product_category_name;
 SELECT*FROM product_quantities_sold;
 
 
 -- 9. list of customers who last purchased in period between 2017 to 2018
SELECT
    customer_id,
    MAX(order_purchase_timestamp) AS last_purchase_date
FROM 
    orders
WHERE
    order_purchase_timestamp >= '2017-01-01'
    AND order_purchase_timestamp < '2019-01-01' 
GROUP BY
    customer_id
HAVING
    last_purchase_date < '2019-01-01';
    
    
    

