/*
  En excluant les commandes annulées, quelles sont les commandes récentes de moins de 3 mois que les clients ont reçues avec au moins 3 jours de retard ?

*/

SELECT order_purchase_timestamp, order_delivered_customer_date, order_estimated_delivery_date
  FROM orders
  WHERE order_status != 'canceled'
  AND order_purchase_timestamp >=  DATE('now', '-3 months')
  AND order_delivered_customer_date >= date(order_estimated_delivery_date, '+3 days');

/*
  Qui sont les vendeurs ayant généré un chiffre d'affaires de plus de 100 000 Real sur des commandes livrées via Olist ?
*/
SELECT seller_id, SUM(price) AS total_revenue
FROM order_items
JOIN orders ON order_items.order_id = orders.order_id
WHERE orders.order_status = 'delivered'
GROUP BY seller_id
HAVING total_revenue > 100000;

/*
Qui sont les nouveaux vendeurs (moins de 3 mois d'ancienneté) qui sont déjà très engagés avec la plateforme (ayant déjà vendu plus de 30 produits) ?
*/
SELECT oi.seller_id,COUNT(oi.order_item_id) AS total_items_sold, MIN(o.order_purchase_timestamp) AS first_order_date
FROM
    order_items oi
JOIN
    orders o ON oi.order_id = o.order_id
GROUP BY
    oi.seller_id
HAVING
    first_order_date >= (
      SELECT DATE(MAX(order_purchase_timestamp), '-3 months')
      FROM orders
    )
    AND total_items_sold > 30;


/*
Question : Quels sont les 5 codes postaux, enregistrant plus de 30 reviews, avec le pire review score moyen sur les 12 derniers mois ?
*/
WITH recent_reviews AS (
  SELECT c.customer_zip_code_prefix as zip_code, review_score
  FROM order_reviews or2
  JOIN orders o on or2.order_id = o.order_id
  JOIN customers c on o.customer_id = c.customer_id
  WHERE o.order_purchase_timestamp >= (
    SELECT DATE(MAX(order_purchase_timestamp), '-12 months') FROM orders
  )
),
reviews_stats AS (
  SELECT zip_code, COUNT(*) as nbre_review, AVG(review_score) as score_moyen
  FROM recent_reviews
  GROUP BY zip_code
  HAVING nbre_review > 30
)
SELECT zip_code, nbre_review, score_moyen from reviews_stats
  ORDER BY score_moyen ASC
  LIMIT 5;