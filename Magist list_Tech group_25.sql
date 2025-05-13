USE magist;
# How many products of these tech categories have been sold (within the time window of the database snapshot)? What percentage does that represent from the overall number of products sold?

SELECT COUNT(DISTINCT (oi.product_id)) AS tech_ptoduct_sold FROM order_items oi
LEFT JOIN products p 
    USING (product_id)
LEFT JOIN product_category_name_translation pt
USING (product_category_name) WHERE product_category_name_english = "audio"
OR product_category_name_english =  "electronics"
OR product_category_name_english =  "computers_accessories"
OR product_category_name_english =  "pc_gamer"
OR product_category_name_english =  "computers"
OR product_category_name_english =  "tablets_printing_image"
OR product_category_name_english =  "telephony";