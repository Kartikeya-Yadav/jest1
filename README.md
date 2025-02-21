# jest1


select *
from bookstore_customers
where customer_id in (select customer_id
					  from bookstore_orders);

-- Task 2 - Books that not ordered.
select *
from bookstore_books
where book_id not in (select book_id
					  from bookstore_orders);

-- Task 3 - Books that out of stock.
select *
from bookstore_books
where quantity = 0;

-- Task 4 - View


-- Task 5 - Most Expencive Book.
select title, price
from bookstore_books
where price = (select max(price)
			   from bookstore_books);

