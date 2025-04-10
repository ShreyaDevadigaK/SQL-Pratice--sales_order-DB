-- Problem Statements
select * from products;
select * from customers;
select * from employees;
select * from sales_order;

-- 1. Identify the total no of products sold
SELECT SUM(quantity) AS TOTAL_NO_OF_PRODUCTS
FROM sales_order
WHERE status='Completed';

-- 2.Other than Completed, display the available delivery status's
SELECT status
FROM sales_order
WHERE status !='Completed'; --does still display status =completed

SELECT status
FROM sales_order
WHERE status NOT IN('Completed','completed');

SELECT status
FROM sales_order
WHERE LOWER(status)!='completed';

-- 3.Display the order id, order_date and product_name for all the completed orders.
SELECT order_id,order_date,p.name AS Product_name
FROM sales_order s
JOIN products p ON s.prod_id=p.id
WHERE LOWER(status)='completed';

-- 4.Sort the above query to show the earliest orders at the top. Also display the customer who purchased these orders.
SELECT order_id,order_date,p.name AS Product_name, c.name AS Customer_name
FROM sales_order s
JOIN products p ON s.prod_id=p.id
JOIN customers c ON s.customer_id=c.id
WHERE LOWER(status)='completed'
ORDER BY order_date;

-- 5.Display the total no of orders corresponding to each delivery status
SELECT status, COUNT (*) AS Total_orders
FROM sales_order
GROUP BY status;

select * from products;
select * from customers;
select * from employees;
select * from sales_order;

-- 6. For orders purchasing more than 1 item, how many are still not completed?
SELECT COUNT (*) AS Not_completed_orders
FROM sales_order
WHERE quantity>1 AND LOWER(status) <>'completed';

-- 7.Find the total no of orders corresponding to each delivery status by ignoring the case in delivery status.
-- Status with highest no of orders should be at the top
SELECT updated_status, COUNT (*) AS Total_orders
FROM (SELECT status,
		CASE WHEN status='completed'
				THEN 'Completed'
			ELSE status
		END AS updated_status
	FROM sales_order) sq
GROUP BY updated_status;

-- other solution
SELECT LOWER(status) AS status, COUNT (*) AS Total_orders
FROM sales_order
GROUP BY lower(status);

-- 8.Write a query to identify the total products purchased by each customer
SELECT c.name AS customer,SUM(quantity) AS TOTAL_PRODUCTS_PURCHASE
FROM sales_order s
RIGHT JOIN customers c ON s.customer_id= c.id   --OR JUST USE JOIN
GROUP BY c.name;

-- 9.Display the total sales and average sales done for each day.
SELECT order_date,SUM(price*quantity) AS total_sales,AVG(price*quantity) AS average_sales
FROM sales_order s
JOIN products p ON s.prod_id=p.id
GROUP BY order_date
ORDER BY order_date;

-- 10.Display the customer name, employee name and total sale amount of all orders which are either on hold or pending.
select * from products;
select * from customers;
select * from employees;
select * from sales_order;

SELECT c.name AS customer, e.name as employee , SUM(p.price * s.quantity) AS total_sale_amount
from sales_order s
JOIN customers c ON s.customer_id=c.id
JOIN employees e ON s.emp_id=e.id 
JOIN products p ON s.prod_id=p.id
WHERE s.status IN ('On Hold','Pending')
GROUP BY c.name, e.name;

-- 11.Fetch all the orders which were neither completed/pending or were handled by the employee Abrar.
-- Display employee name and all details or order.
SELECT e.name,s.*
FROM sales_order s
JOIN employees e ON  s.emp_id=e.id
WHERE LOWER(s.status) NOT IN ('completed','pending')
OR LOWER(e.name) LIKE '%abrar%';

-- 12.Fetch the orders which cost more than 2000 but did not include the macbook pro. Print the total sale amount as well
SELECT s.* ,(s.quantity * p.price) AS total_sale
FROM sales_order s
JOIN products p ON s.prod_id=p.id
WHERE (s.quantity * p.price) >2000 AND p.name NOT LIKE '%Macbook';

-- 13. Identify the customers who have not purchased any product yet.
SELECT *
FROM  customers
WHERE id NOT IN (SELECT DISTINCT customer_id
							FROM sales_order);

-- 14.Write a query to identify the total products purchased by each customer. 
-- Return all customers irrespective of wether they have made a purchase or not. 
-- Sort the result with highest no of orders at the top.
SELECT c.name as customer , COALESCE (SUM(s.quantity),0) AS total_purchase
FROM sales_order s 
RIGHT JOIN customers c ON s.customer_id=c.id
GROUP BY c.name
ORDER BY total_purchase DESC;

-- 15.Corresponding to each employee, display the total sales they made of all the completed orders.
-- Display total sales as 0 if an employee made no sales yet.
SELECT e.name as employees, COALESCE(SUM (s.quantity * p.price),0) AS total_sale
FROM sales_order s
JOIN products p ON p.id= s.prod_id 
RIGHT JOIN employees e ON e.id=s.emp_id AND LOWER(s.status)='completed'
GROUP BY e.name;

-- 16. Re-write the above query so as to display the total sales made by each employee corresponding to each customer.
-- If an employee has not served a customer yet then display "-" under the customer.
SELECT e.name as employees,COALESCE (c.name,'-') as customer, COALESCE(SUM (s.quantity * p.price),0) AS total_sale
FROM sales_order s
JOIN products p ON p.id= s.prod_id 
JOIN customers c ON c.id=s.customer_id
RIGHT JOIN employees e ON e.id=s.emp_id AND LOWER(s.status)='completed'
GROUP BY e.name,c.name
ORDER BY 1,2;

-- 17.Re-write above query so as to display only those records where the total sales is above 1000
SELECT e.name as employees,COALESCE (c.name,'-') as customer, COALESCE(SUM (s.quantity * p.price),0) AS total_sale
FROM sales_order s
JOIN products p ON p.id= s.prod_id 
JOIN customers c ON c.id=s.customer_id
RIGHT JOIN employees e ON e.id=s.emp_id AND LOWER(s.status)='completed'
GROUP BY e.name,c.name
HAVING COALESCE(SUM (s.quantity * p.price),0) >1000
ORDER BY 1,2;

-- 18.Identify employees who have served more than 2 customer
SELECT e.name as employees, COUNT(DISTINCT c.name) AS customer 
FROM sales_order s
JOIN  employees e ON e.id=s.emp_id
JOIN customers c ON c.id=s.customer_id
GROUP BY e.name
HAVING COUNT(DISTINCT c.name) > 2
ORDER BY 1;

--19.Identify the customers who have purchased more than 5 products
SELECT c.name as customer ,SUM(s.quantity) AS total_purchase
FROM sales_order s 
JOIN customers c ON s.customer_id=c.id
GROUP BY c.name
HAVING SUM(s.quantity) > 5;

--20. Identify customers whose average purchase cost exceeds the average sale of all the orders.
SELECT c.name as customer,AVG(price*quantity)
FROM sales_order s
JOIN customers c ON s.prod_id=c.id
JOIN products p ON p.id= s.prod_id
GROUP BY c.name
HAVING AVG(price*quantity) > (SELECT AVG(quantity * price)
								FROM sales_order s
								JOIN products p ON p.id= s.prod_id);

