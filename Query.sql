/* Music Store Data Analysis */

USE music_store;

/*	Q1: Who is the senior most employee based on job title? */

SELECT employee_id, first_name, last_name, title 
FROM employee
ORDER BY levels DESC
LIMIT 1;

/*	2. Which countries have the most Invoices?	*/

SELECT billing_country, COUNT(*) AS Number_of_invoices 
FROM invoice
GROUP BY billing_country
ORDER BY COUNT(*) DESC;

/*	What are top 3 values of total invoice?	*/

SELECT total 
FROM invoice
ORDER BY total DESC
LIMIT 3;

/*4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money.
 Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals	*/
 
 SELECT billing_city , SUM(total) AS invoice_totals
FROM invoice
GROUP BY billing_city
ORDER BY SUM(total) DESC
LIMIT 1;

/*	5. Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money	*/

SELECT i.customer_id , first_name, last_name, SUM(total) AS money_spent
FROM customer AS c
INNER JOIN invoice AS i ON i.customer_id = c.customer_id
GROUP BY i.customer_id, first_name, last_name
ORDER BY SUM(total) DESC
LIMIT 1;



/*	6. Write query to return the email, first name, last name, & Genre of all Rock Music listeners.
 Return your list ordered alphabetically by email starting with A */
 
 SELECT DISTINCT email, first_name, last_name, genre.name AS genre_name
 FROM customer
 INNER JOIN invoice ON invoice.customer_id = customer.customer_id
 INNER JOIN invoice_line ON invoice_line.invoice_id = invoice.invoice_id
 INNER JOIN track ON track.track_id = invoice_line.track_id
 INNER JOIN genre ON genre.genre_id = track.genre_id
 WHERE genre.name = 'Rock'
 ORDER BY email ;
 
 /*	7. Let's invite the artists who have written the most rock music in our dataset.
 Write a query that returns the Artist name and total track count of the top 10 rock bands */
 
 SELECT artist.name, COUNT(artist.artist_id) AS number_of_songs
 FROM artist
 INNER JOIN album ON album.artist_id = artist.artist_id
 INNER JOIN track ON track.album_id = album.album_id
 WHERE track.genre_id IN 
 (SELECT genre_id 
 FROM genre
 WHERE name = 'Rock')
 GROUP BY artist.name
 LIMIT 10;
 
 /*	8. Return all the track names that have a song length longer than the average song length. 
 Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first	*/
 
 SELECT name, milliseconds
 FROM track
 WHERE milliseconds > 
 (SELECT AVG(milliseconds)
 FROM track)
 ORDER BY milliseconds DESC;
 
 

/* Q9: Find how much amount spent by each customer on the highest selling artists? 
Write a query to return customer details, artist name and the amount spent by the customer on the artist? */


 WITH best_selling_artist AS
 (SELECT  artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*quantity) AS sales_total
 FROM artist 
 INNER JOIN album ON artist.artist_id = album.artist_id
 INNER JOIN track ON album.album_id = track.album_id
 INNER JOIN invoice_line ON track.track_id = invoice_line.track_id
 GROUP BY artist_id, artist.name
 ORDER BY sales_total DESC
 LIMIT 1)
 SELECT customer.customer_id, customer.first_name, customer.last_name, best_selling_artist.artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS amount_spent
 FROM customer
 INNER JOIN invoice ON customer.customer_id = invoice.customer_id
 INNER JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
 INNER JOIN track ON invoice_line.track_id = track.track_id
 INNER JOIN album ON track.album_id = album.album_id
 INNER JOIN best_selling_artist ON album.artist_id = best_selling_artist.artist_id
 GROUP BY customer.customer_id, customer.first_name, customer.last_name, best_selling_artist.artist_name 
 ORDER BY amount_spent DESC;
 
 
 /*	10. We want to find out the most popular music Genre for each country.We determine the most popular genre as the genre with the highest amount of purchases.
 Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres? */
 
 
 WITH popular_genre AS
 (SELECT billing_country ,genre.name AS genre_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS sales, 
 ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(invoice_line.unit_price*invoice_line.quantity) DESC) AS Row_Num
 FROM invoice
 INNER JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
 INNER JOIN track ON invoice_line.track_id = track.track_id
 INNER JOIN genre ON track.genre_id = genre.genre_id
 GROUP BY 1,2
 ORDER BY billing_country)
 SELECT  billing_country AS country,genre_name
 FROM popular_genre
 WHERE Row_Num =1;
 
 
 
 /*	11. Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer 
 and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount*/
 
 
 WITH most_valuable_customers AS
 (SELECT billing_country, customer_id, SUM(unit_price*quantity) AS amount_spent, 
 ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(unit_price*quantity) DESC) AS Row_Num
 FROM invoice 
 INNER JOIN invoice_line ON invoice_line.invoice_id = invoice.invoice_id
 GROUP BY billing_country, customer_id)
 SELECT billing_country AS country, first_name, last_name, amount_spent 
 FROM most_valuable_customers
 INNER JOIN customer ON customer.customer_id = most_valuable_customers.customer_id
 WHERE Row_Num = 1
 ORDER BY 1;
 
