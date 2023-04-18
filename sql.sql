--1. How many pizzas were ordered?

SELECT COUNT(customer_id) AS total_ordered_pizzas
FROM customer_orders;


--2. How many unique customer orders were made

SELECT COUNT(DISTINCT order_id) AS unique_customers
FROM customer_orders;

--3. How many successful orders were delivered by each runner?

SELECT runner_id, COUNT(runner_id) AS successful_orders
FROM runner_orders
WHERE distance != 0
GROUP BY runner_id;

--4. How many of each type of pizza was delivered?

SELECT pizza_id, COUNT(c.pizza_id) AS delivered_pizzas
FROM customer_orders c
JOIN runner_orders r ON c.order_id = r.order_id
WHERE distance != 0
GROUP BY pizza_id;

--5. How many Vegetarian and Meatlovers were ordered by each customer?

SELECT c.customer_id, p.pizza_name, COUNT(p.pizza_name) AS total_orders
FROM customer_orders c
JOIN pizza_names p ON c.pizza_id = p.pizza_id
GROUP BY customer_id, pizza_name
ORDER BY customer_id;


--6. What was the maximum number of pizzas delivered in a single order?

WITH pizza_delivered_cte AS
(
	SELECT c.order_id, COUNT(c.pizza_id) AS count_of_pizzas
	FROM customer_orders c
	JOIN runner_orders r ON c.order_id = r.order_id
	WHERE r.distance <> 0
	GROUP BY c.order_id
)
SELECT MAX(count_of_pizzas) AS pizzas_delivered_single_order
FROM pizza_delivered_cte;

--7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT customer_id,
	SUM(CASE WHEN exclusions IS NOT NULL OR extras IS NOT NULL THEN 1 ELSE 0 END) AS change_1,
	SUM(CASE WHEN exclusions IS NULL OR extras IS NULL THEN 1 ELSE 0 END) AS no_change
FROM customer_orders c 
JOIN runner_orders r ON c.order_id = r.order_id
WHERE distance != 0
GROUP BY customer_id
ORDER BY customer_id;

	
-- 8. How many pizzas were delivered that had both exclusions and extras?

SELECT SUM(CASE WHEN exclusions IS NOT NULL AND extras IS NOT NULL THEN 1 ELSE 0 END) AS no_of_pizzas
FROM customer_orders c
JOIN runner_orders r ON c.order_id = r.order_id
WHERE r.cancellation IS NULL AND r.distance >= 1 AND extras IS NOT NULL;

--9. What was the total volume of pizzas ordered for each hour of the day?

SELECT DATEPART(HOUR, order_time) AS hour_of_order, COUNT(order_id) AS total_order_by_hour
FROM customer_orders
GROUP BY DATEPART(HOUR, order_time);

--10. What was the volume of orders for each day of the week?

SELECT DATEPART(DAY, order_time) AS day_of_the_week, COUNT(order_id) AS total_order_by_date
FROM customer_orders
GROUP BY DATEPART(DAY, order_time);
