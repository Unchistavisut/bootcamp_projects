-- CREATE TABLE
-- Restaurant Owners
-- 1x Fact, 4x Dimension
-- search google, how to add foreign key
-- write SQL 3-5 queries analyze data
-- 1x subquery /with

-- START --
-- FACT TABLE --
CREATE TABlE orders(
    order_id INT PRIMARY KEY,
    order_date DATE,
    customer_id INT,
    menu_id INT,
    quantity INT,
    amount REAL,
    ordertype_id INT,
    payment_id INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (menu_id) REFERENCES menu(menu_id),
    FOREIGN KEY (ordertype_id) REFERENCES ordertype(ordertype_id),
    FOREIGN KEY (payment_id) REFERENCES payment(payment_id)
);

INSERT INTO orders VALUES
  (101, '2022-10-07', 1, 2, 1, 195, 1, 2),
  (102, '2022-10-07', 5, 3, 1, 295, 2, 2),
  (103, '2022-10-21', 2, 1, 1, 225, 2, 1),
  (104, '2022-10-21', 4, 5, 2, 310, 1, 2),
  (105, '2022-10-21', 3, 6, 2, 370, 2, 2),
  (106, '2022-10-28', 3, 7, 2, 370, 2, 2),
  (107, '2022-10-28', 6, 3, 1, 295, 1, 3),
  (108, '2022-10-28', 6, 7, 1, 185, 1, 3),
  (109, '2022-11-04', 2, 6, 1, 185, 2, 1),
  (110, '2022-11-11', 5, 4, 1, 255, 2, 3),
  (111, '2022-11-11', 5, 7, 2, 370, 2, 3),
  (112, '2022-11-18', 4, 3, 2, 590, 1, 2),
  (113, '2022-11-25', 1, 3, 1, 295, 1, 2),
  (114, '2022-11-25', 1, 2, 1, 195, 1, 2),
  (115, '2022-12-16', 2, 7, 1, 185, 1, 1),
  (116, '2022-12-16', 3, 5, 2, 310, 2, 3),
  (117, '2022-12-16', 3, 3, 1, 295, 2, 3),
  (118, '2022-12-23', 4, 3, 1, 295, 1, 2),
  (119, '2022-12-30', 6, 2, 1, 195, 1, 3),
  (120, '2022-12-30', 6, 5, 1, 155, 1, 3),
  (121, '2022-12-30', 6, 6, 1, 185, 1, 3);

-- DIMENTION TABLE --
-- customers --
CREATE TABLE customers(
    customer_id INT PRIMARY KEY,
    firstName TEXT,
    lastName TEXT,
    tel VARCHAR(10)
);

INSERT INTO customers VALUES
    (1 ,'Bobby', 'Swingers', '+6680 387 9393'),
    (2 ,'Betsy', 'Spellman', '+6664 659 6542'),
    (3 ,'Oscar', 'Peltzer', '+6692 288 8878'),
    (4 ,'Johnny', 'Suh', '+6665 599 5394'),
    (5 ,'Susie', 'McCallister', '+6663 872 8728'),
    (6 ,'Pajama', 'Pajimjams', '+6690 006 6090');

-- menu --
CREATE TABLE menu(
    menu_id INT PRIMARY KEY,
    menu_name TEXT,
    unit_price REAL  
);

INSERT INTO menu VALUES
    (1, 'Hawaiian Pizza', 225),
    (2, 'Margherita Pizza', 195),
    (3, 'Truffle Pizza', 295),
    (4, 'Spaghetti Shrimp Pesto', 255),
    (5, 'Spaghetti Sausage Garlic', 155),
    (6, 'Pepper Pork Steak', 185),
    (7, 'Grilled Spicy Chicken', 185);

-- order type --
CREATE TABLE ordertype(
    ordertype_id INT PRIMARY KEY,
    ordertype_name TEXT
);

INSERT INTO ordertype VALUES
    (1, 'Takeaway'),
    (2, 'Delivery');

-- payment --
CREATE TABLE payment(
    payment_id INT PRIMARY KEY,
    payment_type TEXT
);

INSERT INTO payment VALUES
    (1, 'Cash'),
    (2, 'Mobile payment'),
    (3, 'Credit Cards');
  
-- sqlite command
.mode markdown
.header on

  
-- Query --
--1. Top spender  --
WITH top_spender as (
	SELECT 
		  cus.customer_id,
  		cus.firstname AS Name,
  		menu.menu_name AS Menu,
  		ord.amount
	FROM orders AS ord
  	JOIN customers AS cus ON cus.customer_id = ord.customer_id
  	JOIN menu on menu.menu_id = ord.menu_id
)	

SELECT 
	  customer_id,
    Name, 
    SUM(amount)AS Amount
FROM top_spender
GROUP BY 1
HAVING SUM(amount) >= 1000
ORDER BY 3 DESC;


-- 2. Menu of the month --

WITH menu_month AS (
	  SELECT 
  		STRFTIME('%Y-%m', order_date) AS month_id,
  		menu.menu_id,
  		menu.menu_name AS Menu,
		  menu.unit_price AS unitPrice,
		  SUM(ord.quantity) AS frequency
	  FROM orders AS ord
    JOIN menu on menu.menu_id = ord.menu_id
    GROUP BY 1,2
)
SELECT 
	  month_id,
	  Menu AS Top_menu, 
    unitPrice, 
    MAX(frequency) AS frequency
FROM menu_month
GROUP BY 1
ORDER BY 1 ;


-- 3. what payment type do most customer use
SELECT 
  	pay.payment_type,
		COUNT(payment_type)  AS frequency_payment,
		ROUND(AVG(ord.amount), 2) AS average
FROM orders AS ord
JOIN payment AS pay 
  ON pay.payment_id = ord.payment_id    	
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;


-- 4. which food is the best seller --
WITH cate_ord_count AS (
	SELECT 
		  menu_name,
    	CASE
    		  WHEN menu_name LIKE '%Pizza' THEN 'Pizza'
        	WHEN menu_name LIKE 'Spaghetti%' THEN 'Spaghetti'
        	ELSE 'Steak'
    	END AS food,
  		ord.quantity AS quantity,
  		ord.amount AS amount
	FROM menu , orders AS ord
	WHERE menu.menu_id = ord.menu_id
)
SELECT 
	food,
    SUM(quantity) AS frequency,
  	SUM(amount) As total
FROM cate_ord_count
GROUP BY food
ORDER BY 3 DESC;


-- 5. Top 3 of menu for takeaway --
SELECT 
	  m.menu_name,
    m.unit_price,
    SUM(ord.quantity) AS frequency_order
FROM menu AS m ,orders AS ord , ordertype AS ordt
WHERE m.menu_id = ord.menu_id
AND ordt.ordertype_id = ord.ordertype_id
AND ordt.ordertype_name = 'Takeaway'
GROUP BY 1
ORDER BY 3 DESc
LIMIT 3;
