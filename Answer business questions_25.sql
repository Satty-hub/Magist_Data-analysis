USE magist;

# Combining the all the tech product together


SELECT product_category_name_enhglish, 
       CASE 
           WHEN product_category_name_english IN ('audio', 'consoles_games', 'eletrodomesticos', 'eletrodomesticos_2', 'eletronicos',
'eletroportateis', 'informatica_acessorios', 'instrumentos_musicais', 'pc_gamer',
'pcs', 'portateis_casa_forno_e_cafe', 'ar_condicionado', 'dvds_blu_ray',
'livros_tecnicos', 'telefonia', 'telefonia_fixa') 
           THEN 'Tech_products' 
           ELSE 'Others' 
       END AS category_group
FROM products_category_name_translation;




SELECT * FROM products;    



-- What percentage does that represent from the overall number of products sold?

SELECT COUNT(DISTINCT(product_id)) AS product_sold FROM order_items;
SELECT 3390/32951;
-- therefore 10%

-- What’s the average price of the products being sold?

SELECT ROUND(AVG(price), 2) FROM order_items;

-- Are expensive tech products popular? * tips-- look at the function CASE WHEN to accomplish this task

SELECT COUNT(oi.product_id), 
	CASE 
		WHEN price > 500 THEN "Expensive"
		WHEN price > 100 THEN "Mid-range"
		ELSE "Cheap"
	END AS "price_range"
FROM order_items oi
LEFT JOIN products p
	ON p.product_id = oi.product_id
LEFT JOIN product_category_name_translation pt
	USING (product_category_name)
WHERE pt.product_category_name_english IN ("audio", "electronics", "computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony")
GROUP BY price_range
ORDER BY 1 DESC;


-- IN relation to the sellers//

-- How many months of data are included in the magist database?

SELECT 
    TIMESTAMPDIFF(MONTH,
        MIN(order_purchase_timestamp),
        MAX(order_purchase_timestamp))
FROM
    orders;
	-- 25 months
    
-- How many sellers are there?
SELECT 
    COUNT(DISTINCT seller_id)
FROM
    sellers;
	-- 3095

-- How many Tech sellers are there? 

SELECT 
    COUNT(DISTINCT seller_id)
FROM
    sellers
        LEFT JOIN
    order_items USING (seller_id)
        LEFT JOIN
    products p USING (product_id)
        LEFT JOIN
    product_category_name_translation pt USING (product_category_name)
WHERE
    pt.product_category_name_english IN ('audio' , 'electronics',
        'computers_accessories',
        'pc_gamer',
        'computers',
        'tablets_printing_image',
        'telephony');
        -- 454
        
        -- What percentage of overall sellers are Tech sellers?
        
        SELECT (454/3095)* 100;
        
        
-- What is the total amount earned by all sellers?
	-- we use price from order_items and not payment_value from order_payments as an order may contain tech and non tech product. With payment_value we can't distinguish between items in an order

SELECT 
    SUM(oi.price) AS total
FROM
    order_items oi
        LEFT JOIN
    orders o USING (order_id)
WHERE
    o.order_status NOT IN ('unavailable' , 'canceled');
    
    --- 13494400.74
    
    -- the average monthly income of all sellers?
    SELECT 13494400.74/ 3095 / 25;
    
    -- 174.40
    
    -- What is the total amount earned by all Tech sellers?

SELECT 
    SUM(oi.price) AS total
FROM
    order_items oi
        LEFT JOIN
    orders o USING (order_id)
        LEFT JOIN
    products p USING (product_id)
        LEFT JOIN
    product_category_name_translation pt USING (product_category_name)
WHERE
    o.order_status NOT IN ('unavailable' , 'canceled')
        AND pt.product_category_name_english IN ('audio' , 'electronics',
        'computers_accessories',
        'pc_gamer',
        'computers',
        'tablets_printing_image',
        'telephony');
        
        -- 1666211.2858879566
        
        -- the average monthly income of Tech sellers?
        
	SELECT 1666211.2858879566/454/25;
    
    -- 146.802756465899259912
    

-- In relation to the delivery time:

-- What’s the average time between the order being placed and the product being delivered?

SELECT AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)) FROM orders;

-- 12.5035 days

-- How many orders are delivered on time vs orders delivered with a delay?

SELECT 
    CASE 
        WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) > 0 THEN 'Delayed' 
        ELSE 'On time'
    END AS delivery_status, 
    COUNT(DISTINCT order_id) AS orders_count
FROM orders 
WHERE order_status = 'delivered'
    AND order_estimated_delivery_date IS NOT NULL
    AND order_delivered_customer_date IS NOT NULL
GROUP BY delivery_status;

-- on time 89805
    -- delayed 6665
 
 -- Is there any pattern for delayed orders, e.g. big products being delayed more often?
 
 SELECT
    CASE 
        WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) >= 100 THEN "> 100 day Delay"
        WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) >= 7 AND DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) < 100 THEN "1 week to 100 day delay"
        WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) > 3 AND DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) < 7 THEN "4-7 day delay"
        WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) >= 1  AND DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) <= 3 THEN "1-3 day delay"
        WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) > 0  AND DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) < 1 THEN "less than 1 day delay"
        WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) <= 0 THEN 'On time' 
    END AS "delay_range", 
    AVG(product_weight_g) AS weight_avg,
    MAX(product_weight_g) AS max_weight,
    MIN(product_weight_g) AS min_weight,
    SUM(product_weight_g) AS sum_weight,
    COUNT(DISTINCT a.order_id) AS orders_count
FROM orders a
LEFT JOIN order_items b
    USING (order_id)
LEFT JOIN products c
    USING (product_id)
WHERE order_estimated_delivery_date IS NOT NULL
AND order_delivered_customer_date IS NOT NULL
AND order_status = 'delivered'
GROUP BY delay_range;
    
    

    
        
    
    