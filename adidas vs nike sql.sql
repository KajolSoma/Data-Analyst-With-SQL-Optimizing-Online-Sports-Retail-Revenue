CREATE TABLE info
(
    product_name VARCHAR(100),
    product_id VARCHAR(11) PRIMARY KEY,
    description VARCHAR(700)
);


CREATE TABLE finance
(
    product_id VARCHAR(11) PRIMARY KEY,
    listing_price FLOAT,
    sale_price FLOAT,
    discount FLOAT,
    revenue FLOAT
);


CREATE TABLE reviews
(
    product_id VARCHAR(11) PRIMARY KEY,
    rating FLOAT,
    reviews FLOAT
);



CREATE TABLE traffic
(
    product_id VARCHAR(11) PRIMARY KEY,
    last_visited TIMESTAMP
);



CREATE TABLE brands
(
    product_id VARCHAR(11) PRIMARY KEY,
    brand VARCHAR(7)
);

1.Counting missing valuess
SELECT COUNT(info) as total_rows,
COUNT(info.description) as count_description, 
COUNT(finance.listing_price) as count_listing_price,
COUNT(traffic.last_visited) as count_last_visited
FROM info
INNER JOIN traffic
ON traffic.product_id = info.product_id
INNEr JOIN finance
ON finance.product_id = info.product_id

2. Nike vs Adidas pricing

SELECT brands.brand, CAST(finance.listing_price AS INTEGER), 
COUNT (finance.product_id)
FROM brands
INNER JOIN finance
ON finance.product_id = brands.product_id
WHERE finance.listing_price > 0
GROUP BY brands.brand, finance.listing_price
ORDER BY finance.listing_price DESC

3. Labeling price ranges

SELECT b.brand, COUNT(f.*), SUM(f.revenue) as total_revenue,
CASE WHEN f.listing_price < 42 THEN 'Budget'
    WHEN f.listing_price >= 42 AND f.listing_price < 74 THEN 'Average'
    WHEN f.listing_price >= 74 AND f.listing_price < 129 THEN 'Expensive'
    ELSE 'Elite' END AS price_category
FROM finance AS f
INNER JOIN brands AS b 
    ON f.product_id = b.product_id
WHERE b.brand IS NOT NULL
GROUP BY b.brand, price_category
ORDER BY total_revenue DESC;

4.Calculate the average discount offered by brand.

select b.brand , avg(f.discount)*100 as average_discount 
from brands as b 
inner join finance as f
on b.product_id = f.product_id
where b.brand is not null
group by b.brand

5.Calculate the correlation between reviews and revenue.

SELECT CORR(reviews.reviews, revenue) AS review_revenue_corr
FROM reviews
INNER JOIN finance
ON finance.product_id = reviews.product_id

6.Split description into bins in increments of one hundred characters, 
and calculate average rating by for each bin.

SELECT TRUNC(LENGTH(i.description), -2) AS description_length,
    ROUND(AVG(r.rating::numeric), 2) AS average_rating
FROM info AS i
INNER JOIN reviews AS r 
    ON i.product_id = r.product_id
WHERE i.description IS NOT NULL
GROUP BY description_length
ORDER BY description_length;

7.Count the number of reviews per brand per month.

SELECT b.brand, DATE_PART('month', t.last_visited) AS month, COUNT(r.*) AS num_reviews
FROM brands AS b
INNER JOIN traffic AS t 
    ON b.product_id = t.product_id
INNER JOIN reviews AS r 
    ON t.product_id = r.product_id
GROUP BY b.brand, month
HAVING b.brand IS NOT NULL
    AND DATE_PART('month', t.last_visited) IS NOT NULL
ORDER BY b.brand, month;

8.Create the footwear CTE, then calculate the number of products and average revenue from these items.

WITH footwear AS
(
    SELECT i.description, f.revenue
    FROM info AS i
    INNER JOIN finance AS f 
        ON i.product_id = f.product_id
    WHERE i.description ILIKE '%shoe%'
        OR i.description ILIKE '%trainer%'
        OR i.description ILIKE '%foot%'
        AND i.description IS NOT NULL
)
SELECT COUNT(*) AS num_footwear_products, 
    percentile_disc(0.5) WITHIN GROUP (ORDER BY revenue) 
	AS median_footwear_revenue
FROM footwear;

9.Copy the code used to create footwear then use a filter to return only products that are not in the CTE.

WITH footwear AS
(
    SELECT i.description, f.revenue
    FROM info AS i
    INNER JOIN finance AS f 
        ON i.product_id = f.product_id
    WHERE i.description ILIKE '%shoe%'
        OR i.description ILIKE '%trainer%'
        OR i.description ILIKE '%foot%'
        AND i.description IS NOT NULL
)

SELECT COUNT(i.*) AS num_clothing_products, 
    percentile_disc(0.5) WITHIN GROUP (ORDER BY f.revenue) AS median_clothing_revenue
FROM info AS i
INNER JOIN finance AS f on i.product_id = f.product_id
WHERE i.description NOT IN (SELECT description FROM footwear);






















