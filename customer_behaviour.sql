--ALTER TABLE customer
--RENAME COLUMN "purchase_amount_(usd)" TO purchase_amount;

-- 1. Revenue comparison: Male vs Female
SELECT gender, SUM(purchase_amount) AS revenue
FROM customer
GROUP BY gender;

-- 2. Customers who used a promo code and spent more than the average purchase amount
SELECT customer_id, purchase_amount
FROM customer
WHERE promo_code_used = 'Yes' AND purchase_amount > (SELECT AVG(purchase_amount)FROM customer);

-- 3. Top 5 products with highest average review rating
SELECT item_purchased,ROUND(CAST(AVG(review_rating)AS numeric), 2) AS avg_review
--used cast cuz round gives numeric values bt avg gives floating therfore've to explicitly cast to makke postgre understand
FROM customer
GROUP BY item_purchased
ORDER BY avg_review DESC
LIMIT 5;

-- 4. Average purchase amount by shipping type (Standard vs Express)
SELECT shipping_type,ROUND(AVG(purchase_amount), 2) AS avg_purchase_amount
FROM customer
WHERE shipping_type IN ('Standard', 'Express')
GROUP BY shipping_type;

-- 5. Average spend vs total revenue between subscribers and non-subscribers
select subscription_status, round(avg(purchase_amount),2) as avg_spend, 
round(sum(purchase_amount),2) as total_revenue
from customer
group by subscription_status;

-- 6. top 5 products with highest purchase % + promo_code_used
SELECT item_purchased, round(100.0*sum(case when promo_code_used='Yes' then 1 else 0 end)/count(*),2) as dis_rate
from customer
group by item_purchased
order by dis_rate DESC
limit 5;

-- 7. segmenting customers into new, RETURNING & loyal based on total no.of previous purchases and showing count of each segment.
SELECT CASE when previous_purchases<2 THEN 'NEW'
             when previous_purchases BETWEEN 2 and 10 THEN 'RETURNING'
	         ELSE 'LOYAL'
        END as customer_segment,
count(*) as customer_count
from customer
group by customer_segment;

-- 8. Top 3 most purchased products within each category
SELECT category, item_purchased, total_purchases
FROM (
    SELECT
        category,
        item_purchased,
        COUNT(*) AS total_purchases,
        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY COUNT(*) DESC
        ) AS rn
    FROM customer
    GROUP BY category, item_purchased
) t
WHERE rn <= 3;

-- 9. Are customers who are repeat buyers (more than 5 previous_purchases) also likely to subscribe?
select subscription_status, count (customer_id) as repeat_buyers
from customer
where previous_purchases>5
group by subscription_status;

-- 10. Revenue by age GROUP
select age_group,sum(purchase_amount) as total_revenue
from customer
group by age_group
order by total_revenue desc;
