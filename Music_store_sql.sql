/*Question Set 1 - Easy*/
	
/*Q1. Who is the senior most employee based on job title?*/
select * from employee 
order by levels desc 
limit 1;

/*Which countries have the most Invoices?*/

select count(*) as c, billing_country from invoice 
group by billing_country order by c desc;

/*What are top 3 values of total invoice*/
select total from invoice order by total desc limit 3;

/*Which city has the best customers? We would like to throw a promotional Music
Festival in the city we made the most money. Write a query that returns one city that
has the highest sum of invoice totals. Return both the city name & sum of all invoice
totals*/
select sum(total) as total_invoice, billing_city from invoice
group by billing_city order by total_invoice desc ;

/*Who is the best customer? The customer who has spent the most money will be
declared the best customer. Write a query that returns the person who has spent the
most money*/

select customer.customer_id, 
customer.first_name, customer.last_name, sum(invoice.total) as total from customer 
JOIN invoice ON customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total desc limit 1

/*Question Set 2 – Moderate*/
	
/*Write query to return the email, first name, last name, & Genre of all Rock Music
listeners. Return your list ordered alphabetically by email starting with A*/

Select distinct customer.email, customer.first_name, customer.last_name, genre.name from customer
inner join invoice on customer.customer_id = invoice.customer_id
inner join invoice_line on invoice.invoice_id = invoice_line.invoice_id
inner join track on invoice_line.track_id = track.track_id
inner join genre on track.genre_id = genre.genre_id 
where genre.name = 'Rock' 
order by customer.email asc;

/*Let's invite the artists who have written the most rock music in our dataset. Write a
query that returns the Artist name and total track count of the top 10 rock bands*/

select artist.artist_id,artist.name, count(track) as total_track from artist
inner join album on artist.artist_id = album.artist_id
inner join track on album.album_id = track.album_id
inner join genre on track.genre_id = genre.genre_id
where genre.name = 'Rock'
group by artist.artist_id
order by total_track desc limit 10;

/*Return all the track names that have a song length longer than the average song length.
Return the Name and Milliseconds for each track. Order by the song length with the
longest songs listed first*/

select name, milliseconds from track
where milliseconds >(Select avg(milliseconds) as avg_track_lenghth from track )
order by milliseconds desc;


/*Question Set 3 – Advance*/

/*Q1.Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent*/

With best_selling_artist as (
Select artist.artist_id as artist_id, artist.name as artist_name, 
Sum(invoice_line.unit_price * invoice_line.quantity) as total_sales
from invoice_line
inner join track on invoice_line.track_id = track.track_id
inner join album on track.album_id = album.album_id
inner join artist on album.artist_id = artist.artist_id
Group by 1
Order by 3 desc 
Limit 1
)

Select customer.customer_id, 
customer.first_name, customer.last_name, best_selling_artist.artist_name,
sum(invoice_line.unit_price*invoice_line.quantity) from customer
inner join invoice on customer.customer_id = invoice.customer_id
inner join invoice_line on invoice.invoice_id = invoice_line.invoice_id
inner join track on invoice_line.track_id = track.track_id
inner join album on track.album_id = album.album_id
inner join best_selling_artist on album.artist_id = best_selling_artist.artist_id
Group by 1,2,3,4
order by 5 desc;


/*Q2.We want to find out the most popular music Genre for each country. We determine the
most popular genre as the genre with the highest amount of purchases. Write a query
that returns each country along with the top Genre. For countries where the maximum
number of purchases is shared return all Genres*/

With popular_genre as(
Select count(invoice_line.quantity) as purchases, customer.country,  genre.name, genre.genre_id,
Row_number() Over(partition by customer.country Order by count(invoice_line.quantity)desc) as RowNo
from invoice_line
inner join invoice on invoice_line.invoice_id = invoice.invoice_id
inner join customer on customer.customer_id = invoice.customer_id
inner join track on track.track_id = invoice_line.track_id
inner join genre on track.genre_id = genre.genre_id
group by 2,3,4
Order by 2 asc, 1 desc
)

Select * from popular_genre where RowNo <= 1;


/*Q3.Write a query that determines the customer that has spent the most on music for each
country. Write a query that returns the country along with the top customer and how
much they spent. For countries where the top amount spent is shared, provide all
customers who spent this amount*/

With customer_with_country As(
Select customer.customer_id, customer.last_name, customer.first_name , invoice.billing_country,
sum(invoice.total) as total_spending, 
Row_Number() over( Partition by invoice.billing_country order by sum(invoice.total)desc) as RowNo from invoice
inner join customer on customer.customer_id = invoice.customer_id
group by 1,2,3,4 
order by 4 asc, 5 desc)
Select * from customer_with_country where RowNo <=1;















































