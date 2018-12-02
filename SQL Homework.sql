#1a
SELECT first_name , last_name FROM sakila.actor;

#1b
SELECT UPPER(concat(first_name, ' ' ,last_name)) AS 'Actor Name'
FROM sakila.actor;

#2a
SELECT first_name,last_name,actor_id
FROM sakila.actor
WHERE first_name = "Joe";

#2b
SELECT first_name,last_name,actor_id  FROM sakila.actor
WHERE last_name LIKE '%GEN%';

#2c
SELECT first_name,last_name,actor_id  FROM sakila.actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name,first_name;

#2d
SELECT country_id,country
FROM sakila.country
WHERE country IN ('Afghanistan','Bangladesh','China');

#3a
ALTER TABLE sakila.actor
ADD COLUMN description blob AFTER last_name;

#3b
ALTER TABLE sakila.actor
DROP COLUMN description;


#4a List the last names of actors, as well as how many actors have that last name.

SELECT last_name, count(last_name) AS 'last_name_frequency'
FROM sakila.actor
GROUP BY last_name
HAVING 'last_name_frequency'>= 0;

#4b List last names of actors and the number of actors who have that last name,
# but only for names that are shared by at least two actors

SELECT last_name, count(last_name) AS 'last_name_frequency'
FROM sakila.actor
GROUP BY last_name
HAVING 'last_name_frequency'>= '2';

#4cThe actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.

UPDATE sakila.actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO'
and last_name ='WILLIAMS';

#4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
#In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.

UPDATE sakila.actor
SET first_name =
CASE
  WHEN first_name = 'HARPO'
    THEN 'GROUCHO'
  ELSE 'MUCHO GROUCHO'
END
WHERE actor_id = 172;

#5a You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE sakila.address;

#6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address: 

USE sakila;

#6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address: 
SELECT s.first_name,s.last_name,a.address
FROM staff s
INNER JOIN address a
ON (s.address_id = a.address_id);

#6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT s.first_name,s.last_name,SUM(p.amount)
FROM staff AS s
INNER JOIN payment AS p
ON p.staff_id = s.staff_id
WHERE MONTH(p.payment_date) = 08 AND YEAR(p.payment_date) = 2005
GROUP BY s.staff_id;

#6c.List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT f.title,COUNT(fa.actor_id) AS 'Actors'
FROM film_actor AS fa
INNER JOIN film as f
ON f.film_id = fa.film_id
GROUP BY f.title
ORDER BY Actors desc;

#6d How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT title,COUNT(inventory_id) AS '# of copies'
FROM film
INNER JOIN inventory
USING (film_id)
WHERE title = 'Hunchback Impossible'
GROUP BY title;

#6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer.
# List the customers alphabetically by last name:

SELECT c.first_name,c.last_name,SUM(p.amount) AS 'Total Amount Paid'
FROM payment AS p
INNER JOIN customer AS c
ON p.customer_id = c.customer_id
GROUP BY c.customer_id
ORDER BY c.last_name;

#7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence,
# films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies
# starting with the letters K and Q whose language is English.
USE sakila;
SELECT title
FROM film
WHERE title LIKE 'K%'
OR title LIKE'Q%' 
AND language_id IN
(
  SELECT language_id
  FROM language
  WHERE name = 'English'
 );
 
#7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name,last_name
FROM actor
WHERE actor_id IN
( 
  SELECT actor_id
  FROM film_actor
  WHERE film_id =
   ( 
     SELECT film_id
     FROM film
     WHERE title = 'Alone Trip'
	)
);

#7c You want to run an email marketing campaign in Canada, for which you will need the names and 
#email addresses of all Canadian customers. Use joins to retrieve this information.

SELECT first_name,last_name,email,country
FROM customer cs
INNER JOIN address a
ON (cs.address_id = a.address_id)
INNER JOIN city cit
ON (a.city_id = cit.city_id)
INNER JOIN country ctr
ON (cit.country_id = ctr.country_id)
WHERE ctr.country = 'canada';

#7d Sales have been lagging among young families, and you wish to target all family movies for a promotion.
# Identify all movies categorized as family films.

SELECT title,c.name
FROM film f
INNER JOIN film_category fc
ON (f.film_id = fc.film_id)
INNER JOIN category c
ON (c.category_id = fc.category_id)
WHERE name = 'family';

#7eDisplay the most frequently rented movies in descending order.
SELECT title,COUNT(title) as 'Rentals'
FROM film
INNER JOIN inventory
ON (film.film_id = inventory.film_id)
INNER JOIN rental
ON (inventory.inventory_id = rental.inventory_id)
GROUP BY title
ORDER BY rentals desc;

#7f. Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id, SUM(amount) AS Gross
FROM payment p
INNER JOIN rental r
ON (p.rental_id = r.rental_id)
INNER JOIN inventory i
ON (i.inventory_id = r.inventory_id)
INNER JOIN store s
ON (s.store_id = i.store_id)
GROUP BY s.store_id;

#7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id,city,country
FROM store s
INNER JOIN address a
ON(s.address_id = a.address_id)
INNER JOIN city cit
ON (cit.city_id = a.city_id)
INNER JOIN country ctr
ON(cit.country_id = ctr.country_id);

#7h List the top five genres in gross revenue in descending order. 
#(Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT SUM(amount) AS 'Total Sales',c.name AS 'Genre'
FROM payment p
INNER JOIN rental r
ON (p.rental_id = r.rental_id)
INNER JOIN inventory i
ON(r.inventory_id = i.inventory_id)
INNER JOIN film_category fc
ON (i.film_id = fc.film_id)
INNER JOIN category c
ON(fc.category_id = c.category_id)
GROUP BY c.name
ORDER BY SUM(amount) DESC;

#8a In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
#Use the solution from the problem above to create a view. 
#If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW top_five_genres AS
SELECT SUM(amount) AS 'Total Sales',c.name AS 'Genre'
FROM payment p
INNER JOIN rental r
ON (p.rental_id = r.rental_id)
INNER JOIN inventory i
ON (r.inventory_id = i.inventory_id)
INNER JOIN film_category fc
ON (i.film_id = fc.film_id)
INNER JOIN category c
ON (fc.category_id = c.category_id)
GROUP BY c.name
ORDER BY SUM(amount) DESC
LIMIT 5;

#8bHow would you display the view that you created in 8a?
SELECT * FROM top_five_genres;

#8c You find that you no longer need the view top_five_genres. Write a query to delete it.

DROP VIEW top_five_genres;