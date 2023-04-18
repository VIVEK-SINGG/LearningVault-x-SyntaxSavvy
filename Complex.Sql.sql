-- 1. What is the total amount each customer spent at the restaurant?

select
	sales.customer_id,
	sum(menu.price) as Total_Spend
from sales 
join menu on sales.product_id = menu.product_id
group by sales.customer_id
	
-- 2. How many days has each customer visited the restaurant?


select customer_id,count(distinct(order_date)) AS Total_Visiting_Days
from sales
group by customer_id

-- 3. What was the first item from the menu purchased by each customer?
WITH ordered_sales_cte AS
(
    SELECT 
        customer_id, 
        order_date, 
        product_name,
        DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS rank
    FROM dbo.sales AS s
    JOIN dbo.menu AS m
        ON s.product_id = m.product_id
)

SELECT 
    customer_id, 
    product_name
FROM ordered_sales_cte
WHERE rank = 1;


--4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT top 1
  product_name,
  COUNT(s.product_id) AS most_purchased
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY product_name
order by most_purchased desc
;

-- 5. Which item was the most popular for each customer?
WITH fav_item_cte AS
(
	SELECT 
    s.customer_id, 
    m.product_name, 
    COUNT(*) AS order_count,
		DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY COUNT(s.customer_id) DESC) AS rank
FROM dbo.menu AS m
JOIN dbo.sales AS s
	ON m.product_id = s.product_id
GROUP BY s.customer_id, m.product_name
)

SELECT 
   customer_id, 
  product_name, 
  order_count
FROM fav_item_cte 
WHERE rank = 1;

----6. Which item was purchased first by the customer after they became a member?


WITH first_purchased_cte AS
(
    SELECT 
        sales.customer_id,
        sales.order_date,
        sales.product_id,
        members.join_date,
        DENSE_RANK() OVER(PARTITION BY sales.customer_id ORDER BY sales.order_date) as dense_rank
    FROM sales 
    JOIN members ON sales.customer_id = members.customer_id
		WHERE sales.order_date>=members.join_date
)
SELECT 
    f.customer_id,
    f.order_date,
    menu.product_name
FROM first_purchased_cte f
JOIN menu ON f.product_id = menu.product_id
WHERE dense_rank = 1;

--7. Which item was purchased just before the customer became a member?
WITH prior_purchased_cte AS 
(
  SELECT 
    sales.customer_id, 
    sales.order_date, 
    sales.product_id,
	members.join_date, 
    DENSE_RANK() OVER(PARTITION BY sales.customer_id ORDER BY sales.order_date DESC)  AS rank
  FROM sales 
	JOIN members 
		ON sales.customer_id = members.customer_id
	WHERE sales.order_date < members.join_date
)

SELECT 
  p.customer_id, 
  p.order_date, 
  menu.product_name 
FROM prior_purchased_cte AS p
JOIN menu
	ON p.product_id = menu.product_id
WHERE rank = 1;






